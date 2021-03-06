--------------------------------------------------------------------------------
--
-- FileName:         ASP_spi_DAC.vhd
-- Dependencies:     none
-- Design Software:  Quartus II Version 17.1.0
--
-- This file provide an architecture to serialize tree different types of data
--  throught the SPI link.
-- Those data are:
--	Acceleration
--	Speed
--	Position
-- 
-- Version History
-- Version 1.0 21/11/2018 - Pierre ROMET
--	functional architecture - satisfactory ModelSim modelisation
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity ASP_spi_DAC is
	PORT
	(
		CLOCK_50   		: IN STD_LOGIC;
		KEY    				: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		GPIO_SPI_CLK	:	INOUT STD_LOGIC;										-- SPI clock
		GPIO_SPI_SS		:	INOUT STD_LOGIC;										-- SPI select slave
		GPIO_SPI_SDIO	:	INOUT STD_LOGIC;										-- SPI bi-directionnal pipe
		RECV_DATA			:	IN STD_LOGIC_VECTOR(15 DOWNTO 0);		-- acceleration data supply by filter
		DAC_OE_INPUT	:	IN STD_LOGIC;												-- acceleration data oenable input
		DAC_SPEED_DATA: IN STD_LOGIC_VECTOR(15 DOWNTO 0);		-- speed data supply by filter
		DAC_SPD_OE_IN	: IN STD_LOGIC;												-- speed data oenable input
		DAC_POS_DATA	: IN STD_LOGIC_VECTOR(15 downto 0);		-- position data supply by filter
		DAC_POS_OE_IN	: IN STD_LOGIC;												-- position data oenable input
		DAC_OE_OUTPUT	:	OUT STD_LOGIC;											-- Master state machine oenable
		RESET_SIGNAL 	:	IN STD_LOGIC
	);

end entity;

---------------------------------------------------------
--
--	Archi with IP catalog FIFO
--
---------------------------------------------------------
architecture dac_IPFifo of ASP_spi_DAC is

--SPI master component
 COMPONENT ASP_spi_master
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
COMPONENT IP_FIFO_24
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q				: OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
END COMPONENT;

type T_SPISTATE 		is (IDLEst, WRITEst, TRANSMITCONFst, TRANSMITst, WAITENDTRANSst, CPDATAst, INCREMTst, RESETst);
type T_WORD_ARR			is array (natural range <>) of std_logic_vector;
type SPI_CONF 			is array (0 to 15) of std_logic_vector (3 downto 0);
type fifo_stLgVect	is array (0 to 3) of std_logic_vector(23 downto 0);		-- Four words of 24 bits to write fifos
type fifo_nbrW 			is array (0 to 3) of STD_LOGIC_VECTOR (9 downto 0);		-- Four words of 10 bits to know nbr of word into fifo

constant WRITEnUPDATE  	: std_logic_vector(3 downto 0) := 4x"3";
constant DAC_ADDRESS		: std_logic_vector(3 downto 0) := 4x"0";

constant SPI_CONFIG : T_WORD_ARR:= (
			WRITEnUPDATE,
			DAC_ADDRESS);

signal cState     	: T_SPISTATE;
signal cStateRnW    : T_SPISTATE;
signal cStateSpi    : T_SPISTATE;

signal reset_n : STD_LOGIC;
signal SampKey : STD_LOGIC_VECTOR(3 DOWNTO 0);

--SPI
signal ss_n       : STD_LOGIC_VECTOR(0 DOWNTO 0); 
signal spi_enable : STD_LOGIC;
signal spi_ss_n   : STD_LOGIC_VECTOR(0 DOWNTO 0); 
signal spi_busy   : STD_LOGIC;
signal spi_pbusy  : STD_LOGIC;
signal spi_sclk   : STD_LOGIC;
signal spi_rxdata : STD_LOGIC_VECTOR(23 DOWNTO 0);

--FIFO SIGNALs
signal fifo_write : fifo_stLgVect;
signal fifo_read  : fifo_stLgVect;
signal fSpi_read	: std_logic_vector(23 downto 0);

signal fifo_oe_w	: std_logic_vector(0 to 2);
signal fifo_oe_r	: std_logic_vector(0 to 2);
signal fSpi_oe_w	:	std_logic;
signal fSpi_oe_r	: std_logic;

signal isEmpty		:	std_logic_vector(0 to 2);
signal isFull			: std_logic_vector(0 to 2);
signal fSpi_isEmp	: std_logic;
signal fSpi_isFull: std_logic;

signal fWord			: fifo_nbrW;
signal fSpi_fWord	: std_logic_vector(9 downto 0);

--DAC register format
signal DAC_COMMAND	: SPI_CONF;	--register config
signal DAC_ADRS			: SPI_CONF; --regsiter address

--signal process Read3Fifo
signal index : integer range 0 to 2:= 0; --Index variable into Read3Fifo process

begin

 reset_n <= RESET_SIGNAL;

 GPIO_SPI_CLK	<= spi_sclk;		--GPIO( 5 )
 GPIO_SPI_SS	<= spi_ss_n(0);	--GPIO( 7 )
 
 DAC_COMMAND(0)		<= "0000";--Write code to n
 DAC_COMMAND(1)		<= "1000";--write code to all
 DAC_COMMAND(2)		<= "0110";--write Span to n
 DAC_COMMAND(3)		<= "1110";--write Span to n
 DAC_COMMAND(4)		<= "0001";--Update n (power Up)
 DAC_COMMAND(5)		<= "1001";--Update all (power Up)
 DAC_COMMAND(6)		<= "0011";--Write code to n, Update n (power Up)
 DAC_COMMAND(7)		<= "0010";--Write code to n, Update all (power Up)
 DAC_COMMAND(8)		<= "1010";--Write code to all, Update all (power Up)
 DAC_COMMAND(9)		<= "0100";--power down n
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
 
 
 --SPI master declaration
 sm_dac: entity work.ASP_spi_master(SPI_DAC)

  GENERIC MAP (
    slaves  => 1,
    d_width => 24
	 )
  PORT MAP(
    clock    => CLOCK_50,
    reset_n  => reset_n,
    enable   => spi_enable,			-- new data available
    cpol     => '1',						-- spi clock polarity
    cpha     => '1',            -- spi clock phase
    cont     => '0',            -- continuous mode command
    clk_div  => 5,							-- system clock cycles, based on 1/2 period of clock (~10MHz -> 3 ; 100K -> 250)
    addr     => 0,              -- address of slave
    tx_data  => fSpi_read,      -- data to transmit
    sclk     => spi_sclk,       -- spi clock
    ss_n     => spi_ss_n,       -- slave select
    busy     => spi_busy,       -- busy / data ready signal
    rx_data  => spi_rxdata,			-- data received
		MISOMOSI => GPIO_SPI_SDIO 	-- GPIO(6)
	);

	-- fifo acceleration declaration
	fifoIpAcc: IP_FIFO_24																 
	PORT MAP                                           
	(
		clock	=> CLOCK_50,
		data	=> fifo_write(0),			-- fifo input data 
		rdreq	=> fifo_oe_r(0), 			-- fifo enable read
		wrreq	=> fifo_oe_w(0),			-- fifo enable write
		empty	=> isEmpty(0),				-- check if fifo is empty 0: Not-empty , 1: empty
		full	=> isFull(0),					-- check if fifo is full  0: Not-full  , 1: full
		q			=> fifo_read(0),			-- fifo output data
    usedw	=> fWord(0)						-- nbr of word into fifo
	);
	
	--fifo speed decalration
	fifoIpSpeed: IP_FIFO_24
	PORT MAP
	(
		clock	=> CLOCK_50,   
		data	=> fifo_write(1),
		rdreq	=> fifo_oe_r(1),
		wrreq	=> fifo_oe_w(1),
		empty	=> isEmpty(1),
		full	=> isFull(1),
		q			=> fifo_read(1),
    usedw	=> fWord(1)		
	);
	
	--fifo position declaration
	fifoIpPos: IP_FIFO_24
	PORT MAP
	(
		clock	=> CLOCK_50,   
		data	=> fifo_write(2),
		rdreq	=> fifo_oe_r(2),
		wrreq	=> fifo_oe_w(2),
		empty	=> isEmpty(2),
		full	=> isFull(2),
		q			=> fifo_read(2),
    usedw	=> fWord(2)
	);
	
	--fifo spi declaration
	fifoIpSpi: IP_FIFO_24
	PORT MAP
	(
		clock	=> CLOCK_50,   
		data	=> fifo_read(index),
		rdreq	=> fSpi_oe_r,
		wrreq	=> fSpi_oe_w,
		empty	=> fSpi_isEmp,
		full	=> fSpi_isFull,
		q			=> fSpi_read,  
    usedw	=> fSpi_fWord  
	);
	
	--
	-- Key reset process
	--
	samp: process(reset_n, CLOCK_50) is
	 
	begin
		if(reset_n = '0') then
			
			SampKey <= ( others=> '1' );
			
		elsif(rising_edge(CLOCK_50)) then
			
			SampKey <= KEY;
			 
		end if;
	end process samp;
	
	
	--
	--	Acceleration data store
	--
	fifo_write(0) <= DAC_COMMAND(6) & DAC_ADRS(0) & RECV_DATA;
	fifo_oe_w(0)	<= DAC_OE_INPUT;
	
	--
	--	Speed data store
	--
	fifo_write(1) <= DAC_COMMAND(6) & DAC_ADRS(1) & DAC_SPEED_DATA;
	fifo_oe_w(1)	<= DAC_SPD_OE_IN;
	
	--
	--	Position data store
	--
	fifo_write(2) <= DAC_COMMAND(6) & DAC_ADRS(2) & DAC_POS_DATA;
	fifo_oe_w(2) 	<= DAC_POS_OE_IN;
	
	--
	--	Read three fifo data and store into fifo_DAC
	--
	RnWFifos : process(reset_n, CLOCK_50) is
			
		begin
			
			if reset_n = '0' then
				
				fifo_oe_r(0)	<= '0';
				fifo_oe_r(1) 	<= '0';
				fifo_oe_r(2)	<= '0';
				index 				<= 0;
				
				cStateRnW <= IDLEst;
				
			elsif rising_edge(CLOCK_50) then
					
				case cStateRnW is
					
					when IDLEst =>
							
						fSpi_oe_w	<= '0';
							
						if isEmpty(index) = '0' then
							fifo_oe_r(index) <= '1';		--enable fifo read for acceleration, speed, position
							cStateRnW <= CPDATAst;
						else
							cStateRnW <= INCREMTst;
						end if;
							
					when CPDATAst =>
							
						fSpi_oe_w		 		 <= '1';			--enable fifo write for FIFO_spi
						fifo_oe_r(index) <= '0';
							
						if index <= 2 then
							cStateRnW <= INCREMTst;
						else
							cStateRnW <= IDLEst;
						end if;
							
					when INCREMTst =>
						
						fSpi_oe_w	<= '0';
						
						if index < 2 then
							index <= index +1;
							cStateRnW <= IDLEst;
						else
							index <= 0;
							cStateRnW <= IDLEst;
						end if;
							
					when others =>
						cStateRnW <= IDLEst;
						
				end case;
			end if;
	end process RnWFifos;
	
	--
	-- Read SPI_FIFO
	--
	R_spiFifo : process (reset_n, CLOCK_50)
	
		begin
				
			if reset_n = '0' then
					
				fSpi_oe_r 		<= '0';
			  spi_enable		<= '0';
				DAC_OE_OUTPUT	<= '0';
				cStateSpi 		<= IDLEst;
					
			elsif rising_edge(CLOCK_50) then
					
				case cStateSpi is
						
					when IDLEst =>
							
						spi_enable		<= '0';
						DAC_OE_OUTPUT	<= '0';
							
						if spi_busy = '0' AND spi_enable = '0' then
							if fSpi_isEmp = '0' then
								fSpi_oe_r		 	<= '1';
								cStateSpi 		<= CPDATAst;
							else
								cStateSpi <= IDLEst;
							end if;
						else
							cStateSpi <= IDLEst;
						end if;
							
					when CPDATAst =>
							
						fSpi_oe_r			<= '0';
						DAC_OE_OUTPUT	<= '1';
						spi_enable		<= '1';
						cStateSpi 		<= IDLEst;
						
					when others =>
						cStateSpi <= IDLEst;
				end case;
			end if;
			
	end process R_spiFifo;
end dac_IPFifo;