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
		KEY    			:  IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		GPIO_SPI_CLK	:	INOUT STD_LOGIC;
		GPIO_SPI_SS		:	INOUT STD_LOGIC;
		GPIO_SPI_SDIO	:	INOUT STD_LOGIC;
		RECV_DATA		:	IN INARRAY(0 to 11)(15 downto 0);
		DAC_OE_INPUT	:	IN INSTDARRAY(0 to 11);
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

--FIFO component
COMPONENT FIFO
	GENERIC
	(
		f_deep	: integer := 0;
		f_wLgth	: integer := 0
	);
	PORT
	(
		f_clock	: in std_logic;
		--Write
		f_write	: in std_logic_vector(f_wLgth-1 downto 0);
		f_oeW		: in std_logic;
		--Read
		f_read	: out std_logic_vector(f_wLgth-1 downto 0);
		f_oeR		: in std_logic;
		f_rdStop	: out std_logic;
		f_reset	: IN STD_LOGIC
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

type   T_SPISTATE is ( WAITst, TRANSMITCONFst, TRANSMITst, WAITENDTRANSst, FWRITEst, FWCONFst);
signal cState_0    : T_SPISTATE;
signal cState_1    : T_SPISTATE;

type SPI_CONF is array (0 to 15) of std_logic_vector (3 downto 0);
signal DAC_COMMAND	: SPI_CONF;
signal DAC_ADRS		: SPI_CONF;

constant CLOCK_50_FREQ : real:=50.0E6;
constant SPI_READ_FREQ : real:=3.0E3;
constant SPI_READ_NCLK : natural:=natural( ceil(CLOCK_50_FREQ/SPI_READ_FREQ) );

signal   spi_read_cpt  : natural range 0 to SPI_READ_NCLK;
signal   spi_read_cpt_zero :  std_logic;

signal	previous	: std_logic := '0';
signal	cpt_spiClock : integer := 24;
signal	current	: std_logic := '0';

type oeInputTab is array (0 to NBROFMODULE-1) of std_logic;
signal oeInputArray	: oeInputTab; --CHECKIN process
signal ackInArray			: oeInputTab; --WRITE FIFO process


signal index : integer := 0;

--FIFO SIGNAL
type f_stLgVect is array (0 downto NBROFMODULE-1) of std_logic_vector(23 downto 0);
type f_stdLG 	 is array (0 downto NBROFMODULE-1) of std_logic;

signal fifo_write : f_stLgVect;
signal fifo_oe_w  : f_stdLG
signal fifo_read  : f_stLgVect;
signal fifo_oe_r  : f_stdLG;
signal fifo_rdStop: f_stdLG;

begin

DAC_COMMAND(0)	<= "0000"; --Write code to n
DAC_COMMAND(1)	<= "1000"; --write code to all
DAC_COMMAND(2)	<= "0110"; --write Span to n
DAC_COMMAND(3)	<= "1110"; --write Span to n
DAC_COMMAND(4)	<= "0001"; --Update n (power Up)
DAC_COMMAND(5)	<= "1001"; --Update all (power Up)
DAC_COMMAND(6)	<= "0011"; --Write code to n, Update n (power Up)
DAC_COMMAND(7)	<= "0010"; --Write code to n, Update all (power Up)
DAC_COMMAND(8)	<= "1010"; --Write code to all, Update all (power Up)
DAC_COMMAND(9)	<= "0100"; --power down n
DAC_COMMAND(10) <= "0101";--power down chip
DAC_COMMAND(11) <= "1011";--Minitor Mux
DAC_COMMAND(12) <= "1100";--toggle select
DAC_COMMAND(13) <= "1101";--global toggle
DAC_COMMAND(14) <= "0111";--Config
DAC_COMMAND(15) <= "1111";--No Operation

DAC_ADRS(0)	<= "0000";	--DAC 0
DAC_ADRS(1)	<= "0001";	--DAC 1
DAC_ADRS(2)	<= "0010";	--DAC 2
DAC_ADRS(3)	<= "0011";	--DAC 3
DAC_ADRS(4)	<= "0100";	--DAC 4
DAC_ADRS(5)	<= "0101";	--DAC 5
DAC_ADRS(6)	<= "0110";	--DAC 6
DAC_ADRS(7)	<= "0111";	--DAC 7
DAC_ADRS(8)	<= "1000";	--DAC 8
DAC_ADRS(9)	<= "1001";	--DAC 9
DAC_ADRS(10)<= "1010";	--DAC 10
DAC_ADRS(11)<= "1011";	--DAC 11
DAC_ADRS(12)<= "1100";	--DAC 12
DAC_ADRS(13)<= "1101";	--DAC 13
DAC_ADRS(14)<= "1110";	--DAC 14
DAC_ADRS(15)<= "1111";	--DAC 15

reset_n <= RESET_SIGNAL;

GPIO_SPI_CLK	<= spi_sclk;		--GPIO( 5 )
GPIO_SPI_SS		<= spi_ss_n(0);	--GPIO( 7 )


sm_dac: entity work.spi_master(SPI_DAC)

  GENERIC MAP (
    slaves  => 1,
    d_width => 24
	 )
  PORT MAP(
    clock    => CLOCK_50,
    reset_n  => reset_n,
    enable   => spi_enable,
    cpol     => '1',
    cpha     => '1',                         --spi clock phase
    cont     => '0',                         --continuous mode command
    clk_div  => 5,									--system clock cycles, based on 1/2 period of clock (~10MHz -> 3 ; 100K -> 250)
    addr     => 0,                           --address of slave
    tx_data  => spi_txdata,                	--data to transmit
    sclk     => spi_sclk,                    --spi clock
    ss_n     => spi_ss_n,                		--slave select
    busy     => spi_busy,                    --busy / data ready signal
    rx_data  => spi_rxdata,						--data received
	 MISOMOSI => GPIO_SPI_SDIO 					--GPIO(6)
	);

 gen_ FIFO : for I in 0 to NBROFMODULE-1 generate
 
	fifo_c: FIFO
		GENERIC MAP
		(
			f_deep => 100,
			f_wLgth => 24
		)
		PORT MAP
		(
			f_clock	=> CLOCK_50,
			--Write
			f_write	=> fifo_write(I),
			f_oeW		=> fifo_oe_w(I),
			--Read
			f_read	=> fifo_read(I),
			f_oeR		=> fifo_oe_r(I),
			f_rdStop	=> fifo_rdStop(I),
			f_reset	=> RESET_SIGNAL
	);
	
 end generate gen_FIFO;
	
	--
	-- Key reset process
	--
	samp: process(reset_n, CLOCK_50) is
	
	 begin 
		if(reset_n = '0') then
			SampKey <= ( others=> '1' );
		elsif rising_edge(CLOCK_50)then
			SampKey <= KEY;

		end if;
	 end process samp;

	--
	-- SPI DAC: states machineS
	--
	
	-- State machine: Check Input
	CheckIn : process (reset_n, CLOCK_50)
	
	 begin
	
	 if reset_n = '0' then
		oeInputArray <= (others => '0');
	
	 elsif rising_edge(CLOCK_50) then
	
		for I in 0 to NBROFMODULE-1 loop	--For to generate HIGH level
			if DAC_OE_INPUT(I) = '1' then
				oeInputArray(I) <= '1';
			end if;
		end loop;
		
		for I in 0 to NBROFMODULE-1 loop	--For to generate LOW level
			if ackInArray(index) = '0' then
				oeInputArray(I) <= '0';
			end if;
		end loop;
	
	 end if;	
	 end process CheckIn;
	
	-- State machine: Write FIFO
	FIFOW : process (reset_n, CLOCK_50)
		
	 begin
	 
	 if reset_n = '0' then
		index <= 0;
		cState_0 <= WAITst;
	 elsif rising_edge(CLOCK_50) then
	 
		case cState_0 is
			when WAITst =>
				
				for I in 0 to NBROFMODULE-1 loop
					if oeInputArray(I) = '1' then
						ackInArray(I) <= '1';						
					end if;
				end loop;
--				cState_0 <= checkFWrite;
--				
--			when checkFWrite =>
--				
--				if ackInArray(index) = '1' then
--					cState_0 <= FWRITEst;
--				else
--					cState_0 <= WAITst;--------------
--				end if;
--				
--			when FWRITEst =>
--				
--				fifo_oe_w <= '1';
--				fifo_write <= DAC_COMMAND(6) & DAC_ADRS(index) & RECV_DATA(index);
--				ackInArray(index) <= '0';
--				cState_0 <= FWCONFst;
--				
--			when FWCONFst =>
--				
--				fifo_oe_w <= '0';
--				
--				if index >= NBROFMODULE then
--					index <= 0;
--				else
--					index <=  index +1;
--				end if;
--				
--				cState_0 <= checkFWrite;
				
			when others =>
				null;
		end case;
	 end if;	
	end process FIFOW;	
	
	-- State machine: Read FIFO
	FIFOR : process( reset_n, CLOCK_50 )
	
		variable risgEdge : std_logic := '0';
		variable risgEdgeCpt : std_logic := '0';
	
	 begin
		if reset_n ='0' then
			spi_enable <= '0';
			spi_pbusy <= '1';
			cState_1 <= WAITst;
			
		elsif rising_edge( CLOCK_50) then
			
			case cState_1 is
					
				when WAITst =>
					
					if fifo_rdStop = '0' then					
						if cpt_spiClock = 24 AND risgEdge = '1' AND spi_ss_n(0) = '1' then						
							cState_1 <= TRANSMITCONFst;
						end if;
					else
						cState_1 <= WAITst;
					end if;
				
				when TRANSMITCONFst =>
					cpt_spiClock <= 0;
					fifo_oe_r	 <= '1';
					cState_1 <= TRANSMITst;
				
				when TRANSMITst =>
					fifo_oe_r		<= '0';
					spi_enable		<= '1';
					DAC_OE_OUTPUT	<= '1';
					spi_txdata(23 downto 0) <= fifo_read;
					cState_1 <= WAITENDTRANSst;
				
				when WAITENDTRANSst =>
					
					spi_enable 		<= '0';
					DAC_OE_OUTPUT	<= '0';
					
					current <= spi_sclk;
					previous <= current;
				
					if (current = '1' AND previous = '0') then
						cpt_spiClock <= cpt_spiClock + 1;
					end if;
					
					if cpt_spiClock <= 23 then
						cState_1 <= WAITENDTRANSst;
					else
						cState_1 <= WAITst;
					end if;				
					
				when others	=>
				null;
				
			end case;
		end if;		
	end process FIFOR;
end dac_Archi;