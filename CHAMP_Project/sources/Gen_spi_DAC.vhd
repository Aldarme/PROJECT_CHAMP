-- Quartus II VHDL Template
-- Binary Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;

package PortAsArray is
	type INARRAY is array (natural range <>) of std_logic_vector;
	type INSTDARRAY is array (natural range <>) of std_logic;
end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;
use work.PortAsArray.all;

entity Gen_spi_DAC is
	GENERIC
	(
		NBROFMODULE : INTEGER
	);
	PORT
	(
		CLOCK_50   		:  IN STD_LOGIC;
		KEY    				:  IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		GPIO_SPI_CLK	:	INOUT STD_LOGIC;
		GPIO_SPI_SS		:	INOUT STD_LOGIC;
		GPIO_SPI_SDIO	:	INOUT STD_LOGIC;
		RECV_DATA			:	IN INARRAY(0 to NBROFMODULE-1)(15 downto 0);
		DAC_OE_INPUT	:	IN INSTDARRAY(0 to NBROFMODULE-1);
		DAC_OE_OUTPUT	:	OUT STD_LOGIC;
		RESET_SIGNAL 	:	IN STD_LOGIC
	);
end entity;

architecture dac_Archi of Gen_spi_DAC is

--SPI master component
COMPONENT spi_master
  GENERIC(
    slaves  : INTEGER := 4;  --number of spi slaves
    d_width : INTEGER := 2
	 ); --data bus width
  PORT(
    clock   : IN     STD_LOGIC;                             --system clock
    reset_n : IN     STD_LOGIC;                             --asynchronous reset
    enable  : IN     STD_LOGIC;                             --initiate transaction
    cpol    : IN     STD_LOGIC;                             --spi clock polarity
    cpha    : IN     STD_LOGIC;                             --spi clock phase
    cont    : IN     STD_LOGIC;                             --continuous mode command
    clk_div : IN     INTEGER;                               --system clock cycles, based on 1/2 period of clock (~10MHz -> 3 ; 100K -> 250)
    addr    : IN     INTEGER;                               --address of slave
    tx_data : IN     STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);	--data to transmit
    sclk    : BUFFER STD_LOGIC;                             --spi clock
    ss_n    : BUFFER STD_LOGIC_VECTOR(slaves-1 DOWNTO 0);   --slave select
    busy    : OUT    STD_LOGIC;                             --busy / data ready signal
    rx_data : OUT    STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);	--data received
	 MISOMOSI: INOUT	STD_LOGIC
	);
END COMPONENT;

--Clock Divider
COMPONENT clockDivider
	GENERIC
		(
			mainClock	: integer := 0;
			wishedClock : integer := 0
		);
	 PORT
		(
			clockIn  : in std_logic;
			clockOut : out std_logic;
			reset		: in std_logic
		);
END COMPONENT;

--FIFO component
COMPONENT FIFO_Asynch
	GENERIC
	(
		f_deep	: integer :=0;	--FIFO's depth
		f_wLgth	: integer :=0		--word's length
	);
	PORT
	(
		f_clock 	: in std_logic;
		f_oeW			:	in std_logic;
		f_dataIn	:	in std_logic_vector(f_wLgth-1 downto 0);
		f_oeR			:	in std_logic;
		f_dataOut	:	out std_logic_vector(f_wLgth-1 downto 0);
		emptyFlag	:	out std_logic;
		fullFlag	: out std_logic;
		f_reset		: in std_logic
	);
END COMPONENT;

signal reset_n : STD_LOGIC;
signal SampKey : STD_LOGIC_VECTOR(3 DOWNTO 0);

signal ss_n       : STD_LOGIC_VECTOR(0 DOWNTO 0); 
signal spi_enable : STD_LOGIC;
signal spi_ss_n   : STD_LOGIC_VECTOR(0 DOWNTO 0); 
signal spi_busy   : STD_LOGIC;
signal spi_pbusy  : STD_LOGIC;
signal spi_sclk   : STD_LOGIC;
signal spi_txdata : STD_LOGIC_VECTOR(23 DOWNTO 0);
signal spi_rxdata : STD_LOGIC_VECTOR(23 DOWNTO 0);

type   T_SPISTATE is (CHECKINst, INCREMENTst, WAITst, TRANSMITCONFst, TRANSMITst, WAITENDTRANSst, FWRITEst, FWCONFst, FLUSHWst);
signal cState_0    : T_SPISTATE;
signal cState_1    : T_SPISTATE;

type SPI_CONF is array (0 to 15) of std_logic_vector (3 downto 0);
signal DAC_COMMAND	: SPI_CONF;
signal DAC_ADRS		: SPI_CONF;

signal	current				: std_logic := 'Z';
signal	previous			: std_logic := 'Z';
signal	cpt_spiClock  : integer := 0;

--FIFO SIGNAL
type f_stLgVect is array (0 to NBROFMODULE-1) of std_logic_vector(23 downto 0);
type f_stdLG 	 is array (0 to NBROFMODULE-1) of std_logic;

signal fifo_write : f_stLgVect;
signal fifo_oe_w  : f_stdLG;
signal fifo_read  : f_stLgVect;
signal fifo_oe_r  : f_stdLG;
signal fifo_emtFlg: f_stdLG;
signal fifo_fulFlg: f_stdLG;

--Clock Divider
signal clockDiv 		: std_logic := '0';

----------------------------
begin
----------------------------

 DAC_COMMAND(0)		<= "0000"; --Write code to n
 DAC_COMMAND(1)		<= "1000"; --write code to all
 DAC_COMMAND(2)		<= "0110"; --write Span to n
 DAC_COMMAND(3)		<= "1110"; --write Span to n
 DAC_COMMAND(4)		<= "0001"; --Update n (power Up)
 DAC_COMMAND(5)		<= "1001"; --Update all (power Up)
 DAC_COMMAND(6)		<= "0011"; --Write code to n, Update n (power Up)
 DAC_COMMAND(7)		<= "0010"; --Write code to n, Update all (power Up)
 DAC_COMMAND(8)		<= "1010"; --Write code to all, Update all (power Up)
 DAC_COMMAND(9)		<= "0100"; --power down n
 DAC_COMMAND(10) 	<= "0101";--power down chip
 DAC_COMMAND(11) 	<= "1011";--Minitor Mux
 DAC_COMMAND(12) 	<= "1100";--toggle select
 DAC_COMMAND(13) 	<= "1101";--global toggle
 DAC_COMMAND(14) 	<= "0111";--Config
 DAC_COMMAND(15) 	<= "1111";--No Operation

 DAC_ADRS(0)  <= "0000";		--DAC 0
 DAC_ADRS(1)	<= "0001";		--DAC 1
 DAC_ADRS(2)	<= "0010";		--DAC 2
 DAC_ADRS(3)	<= "0011";		--DAC 3
 DAC_ADRS(4)	<= "0100";		--DAC 4
 DAC_ADRS(5)	<= "0101";		--DAC 5
 DAC_ADRS(6)	<= "0110";		--DAC 6
 DAC_ADRS(7)	<= "0111";		--DAC 7
 DAC_ADRS(8)	<= "1000";		--DAC 8
 DAC_ADRS(9)	<= "1001";		--DAC 9
 DAC_ADRS(10)	<= "1010";		--DAC 10
 DAC_ADRS(11)	<= "1011";		--DAC 11
 DAC_ADRS(12)	<= "1100";		--DAC 12
 DAC_ADRS(13)	<= "1101";		--DAC 13
 DAC_ADRS(14)	<= "1110";		--DAC 14
 DAC_ADRS(15)	<= "1111";		--DAC 15

 reset_n <= RESET_SIGNAL;

 GPIO_SPI_CLK	<= spi_sclk;			--GPIO( 5 )
 GPIO_SPI_SS		<= spi_ss_n(0);	--GPIO( 7 )

------------------------------------------------------
--
-- intantiation of components
--
------------------------------------------------------

 sm_dac: entity work.spi_master(SPI_DAC)
  GENERIC MAP (
    slaves  => 1,
    d_width => 24
	 )
  PORT MAP(
    clock    	=> CLOCK_50,
    reset_n  	=> reset_n,
    enable   	=> spi_enable,
    cpol     	=> '1',
    cpha     	=> '1',                         --spi clock phase
    cont     	=> '0',                         --continuous mode command
    clk_div  	=> 5,									--system clock cycles, based on 1/2 period of clock (~10MHz -> 3 ; 100K -> 250)
    addr     	=> 0,                           --address of slave
    tx_data		=> spi_txdata,                	--data to transmit
    sclk     	=> spi_sclk,                    --spi clock
    ss_n     	=> spi_ss_n,                		--slave select
    busy     	=> spi_busy,                    --busy / data ready signal
    rx_data  	=> spi_rxdata,						--data received
	 MISOMOSI		=> GPIO_SPI_SDIO 					--GPIO(6)
	);
	
 cloclDiv : clockDivider
	GENERIC MAP
	(
		mainClock		=> 50000000,	--main clock frequency <= 50 MHz
		wishedClock => 2000      	--synchronised with the read frequency of the ADXL355 - new data each 1kHz, but due to reset of acquitement, multi freq x2 
	)
	PORT MAP
	(
		clockIn  	=> CLOCK_50,
		clockOut 	=> clockDiv,
		reset			=> RESET_SIGNAL
	);

 gen_FIFO : for I in 0 to NBROFMODULE-1 generate
 
	fifo_c: FIFO_Asynch
		GENERIC MAP
		(
			f_deep => 32,	--nbr of word to store into the FIFO
			f_wLgth => 24	--length of a word
		)
		PORT MAP
		(
			f_clock		=> CLOCK_50,
			f_oeW		=> fifo_oe_w(I),
			f_dataIn	=> fifo_write(I),
			f_oeR		=> fifo_oe_r(I),			
			f_dataOut	=> fifo_read(I),
			emptyFlag	=> fifo_emtFlg(I),
			fullFlag	=> fifo_fulFlg(I),
			f_reset		=> RESET_SIGNAL
	);
	
 end generate gen_FIFO;
 
 
------------------------------------------------------
--
-- SPI DAC: states machineS
--
------------------------------------------------------	
	
	--
	-- State machine: Check Input & Write
	-- 
	CheckINnW : process (reset_n, CLOCK_50) --clockDiv)
	
		begin
	
		if rising_edge(CLOCK_50) then
			
			for I in 0 to NBROFMODULE-1 loop
				if fifo_fulFlg(I) /= '1' then
					if DAC_OE_INPUT(I) = '1' then
						fifo_oe_w(I) <= '1';
						fifo_write(I) <= DAC_COMMAND(6) & DAC_ADRS(I) & RECV_DATA(I);
					end if;
				end if;
			end loop;		
		
		elsif falling_edge(CLOCK_50) then
			
			for I in 0 to NBROFMODULE-1 loop
					fifo_oe_w(I) <= '0';
			end loop;
			
		end if;
	end process CheckINnW;

	
	--
	-- State machine: Read FIFO
	--	
	FIFOR : process( reset_n, CLOCK_50) --clockDiv )
			
		variable index : integer := 0;
			
		begin
		
		if reset_n ='0' then
			index					:= 0;
			spi_enable		<= '0';
			DAC_OE_OUTPUT <= '0';
			spi_pbusy 		<= '1';
			cpt_spiClock	<= -1;
			for I in 0 to NBROFMODULE-1 loop
					fifo_oe_r(I)	<= '0';
			end loop;			
			cState_1 <= CHECKINst;
			
		elsif rising_edge(CLOCK_50) then
			
			case cState_1 is
					
				when CHECKINst =>
					
					index := 0;
					for I in 0 to NBROFMODULE-1 loop
						if fifo_emtFlg(I) /= '1' then
							fifo_oe_r(I)	<= '1';
						end if;
					end loop;					
					cState_1	<= TRANSMITst;
					
				when TRANSMITst =>
					
					if fifo_oe_r(index)	= '1' then
						DAC_OE_OUTPUT 		<= '1';
						spi_enable				<= '1';
						spi_txdata <= fifo_read(index);
						cState_1 <= TRANSMITCONFst;
					else
						cState_1 <= INCREMENTst;
					end if;
					
				when INCREMENTst =>
					
					index := index +1;
					if index <= 11 then
						cState_1 <= TRANSMITst;
					else
						cState_1 <= CHECKINst;
					end if;					
					
				when TRANSMITCONFst =>
					
					fifo_oe_r(index)	<= '0';
					spi_enable		<= '0';
					DAC_OE_OUTPUT <= '0';
					
					if GPIO_SPI_SDIO /= 'Z' then
						cState_1 <= WAITENDTRANSst;
					else
						cState_1 <= TRANSMITCONFst;
					end if;
					
				when WAITENDTRANSst =>
				
					current <= spi_sclk;
					previous <= current;					
					
					if (current = '1' AND previous = '0') then
						cpt_spiClock <= cpt_spiClock + 1;
					end if;
					
					if cpt_spiClock < 23 then
						
						cState_1 <= WAITENDTRANSst;
					else
						cpt_spiClock <= -1;
						cState_1 <= INCREMENTst;
					end if;
					
				when others	=>
					null;				
			end case;
		end if;		
	end process FIFOR;
	
end dac_Archi;
