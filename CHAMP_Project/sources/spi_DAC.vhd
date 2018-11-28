-- Quartus II VHDL Template
-- Binary Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;

entity spi_DAC is
	PORT
	(
		CLOCK_50   		:  IN STD_LOGIC;
		KEY    				:  IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		GPIO_SPI_CLK	:	INOUT STD_LOGIC;
		GPIO_SPI_SS		:	INOUT STD_LOGIC;
		GPIO_SPI_SDIO	:	INOUT STD_LOGIC;
		RECV_DATA			:	IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		DAC_OE_INPUT	:	IN STD_LOGIC;
		DAC_OE_OUTPUT	:	OUT STD_LOGIC;
		RESET_SIGNAL 	:	IN STD_LOGIC
	);

end entity;


---------------------------------------------------------
--
--	Archi with personnal FIFO
--
---------------------------------------------------------
architecture dac_handMaidFifo of spi_DAC is

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

 type   T_SPISTATE is ( WAITst, TRANSMITCONFst, TRANSMITst, WAITENDTRANSst);
 signal cState     : T_SPISTATE;

 type    T_WORD_ARR is array (natural range <>) of std_logic_vector;

 constant WRITEnUPDATE  	: std_logic_vector(3 downto 0) := 4x"3";
 constant DAC_ADDRESS		: std_logic_vector(3 downto 0) := 4x"0";

 constant SPI_CONFIG : T_WORD_ARR:= (
			WRITEnUPDATE,
			DAC_ADDRESS			
			);

 constant CLOCK_50_FREQ : real:=50.0E6;
 constant SPI_READ_FREQ : real:=1.0E3;
 constant SPI_READ_NCLK : natural:=natural( ceil(CLOCK_50_FREQ/SPI_READ_FREQ) );

 signal   spi_read_cpt  : natural range 0 to SPI_READ_NCLK;
 signal   spi_read_cpt_zero :  std_logic;

 signal	previous	: std_logic := '0';
 signal	cpt_spiClock : integer := 24;
 signal	current	: std_logic := '0';

--FIFO SIGNAL
 signal fifo_write : std_logic_vector(15 downto 0);
 signal fifo_oe_w  : std_logic :='0';
 signal fifo_read  : std_logic_vector(15 downto 0) := (others => '0');
 signal fifo_oe_r  : std_logic :='0';
 signal fifo_rdStop: std_logic := '0';


begin

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
    cpha     => '1',                  --spi clock phase
    cont     => '0',                  --continuous mode command
    clk_div  => 5,										--system clock cycles, based on 1/2 period of clock (~10MHz -> 3 ; 100K -> 250)
    addr     => 0,                    --address of slave
    tx_data  => spi_txdata,           --data to transmit
    sclk     => spi_sclk,             --spi clock
    ss_n     => spi_ss_n,             --slave select
    busy     => spi_busy,             --busy / data ready signal
    rx_data  => spi_rxdata,						--data received
	 MISOMOSI => GPIO_SPI_SDIO 					--GPIO(6)
	);

fifo_c: FIFO
	GENERIC MAP
	(
		f_deep => 12,
		f_wLgth => 16
	)
	PORT MAP
	(
		f_clock	=> CLOCK_50,
		--Write
		f_write	=> fifo_write,
		f_oeW		=> fifo_oe_w,
		--Read
		f_read	=> fifo_read,
		f_oeR		=> fifo_oe_r,
		f_rdStop	=> fifo_rdStop,
		f_reset	=> RESET_SIGNAL
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
	-- SPI DAC state machine
	--
	statep: process( reset_n, CLOCK_50 )
	
		variable risgEdge : std_logic := '0';
		variable risgEdgeCpt : std_logic := '0';
	
	begin
		if reset_n='0' then
			spi_enable <= '0';
			spi_pbusy <= '1';
			cState <= WAITst;
			
		elsif rising_edge( CLOCK_50) then
			
			case cState is
					
				when WAITst =>
					fifo_oe_w		<= '0';
					
					if DAC_OE_INPUT = '1' then
						fifo_oe_w <= '1';
						fifo_write <= RECV_DATA;
						if cpt_spiClock = 24 then
							risgEdge := '1';
						end if;
					end if;
					
					if fifo_rdStop = '0' then					
						if cpt_spiClock = 24 AND risgEdge = '1' AND spi_ss_n(0) = '1' then						
							cState <= TRANSMITCONFst;
						end if;
					else
						cState <= WAITst;
					end if;
				
				when TRANSMITCONFst =>
					cpt_spiClock <= 0;
					fifo_oe_w		<= '0';
					fifo_oe_r		<= '1';
					cState <= TRANSMITst;
				
				when TRANSMITst =>
					--fifo_oe_r 		<= '0';
					spi_enable		<= '1';
					DAC_OE_OUTPUT	<= '1';
					spi_txdata(15 downto 0)	 <= fifo_read;
					spi_txdata(19 downto 16) <= SPI_CONFIG(1);
					spi_txdata(23 downto 20) <= SPI_CONFIG(0);
					cState <= WAITENDTRANSst;
				
				when WAITENDTRANSst =>
					
					fifo_oe_r 		<= '0';
					spi_enable 		<= '0';
					DAC_OE_OUTPUT	<= '0';
					
					if DAC_OE_INPUT = '1' then
						fifo_oe_w <= '1';
						fifo_write <= RECV_DATA;
					end if;
					
					current <= spi_sclk;
					previous <= current;
					
					if (current = '1' AND previous = '0') then
						cpt_spiClock <= cpt_spiClock + 1;
					end if;
					
					if cpt_spiClock <= 23 then
						cState <= WAITENDTRANSst;
					else
						cState <= WAITst;
					end if;				
					
				when others	=>
					cState <= WAITst;
					
			end case;
		end if;
		
	end process statep;

end dac_handMaidFifo;



---------------------------------------------------------
--
--	Archi with IP catalog FIFO
--
---------------------------------------------------------
architecture dac_IPFifo of spi_DAC is

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
COMPONENT IP_FIFO
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q				: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
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

type   T_SPISTATE is ( IDLEst, WRITEst, TRANSMITCONFst, TRANSMITst, WAITENDTRANSst);
signal cState     : T_SPISTATE;

type    T_WORD_ARR is array (natural range <>) of std_logic_vector;

constant WRITEnUPDATE  	: std_logic_vector(3 downto 0) := 4x"3";
constant DAC_ADDRESS		: std_logic_vector(3 downto 0) := 4x"0";

constant SPI_CONFIG : T_WORD_ARR:= (
			WRITEnUPDATE,
			DAC_ADDRESS			
			);

signal	previous			: std_logic 	:= '0';
signal	current				: std_logic			:= '0';
signal	cpt_spiClock	: integer 	:= 0;

--FIFO SIGNAL
signal fifo_write : std_logic_vector(15 downto 0);
signal fifo_oe_w  : std_logic :='0';
signal fifo_read  : std_logic_vector(15 downto 0) := (others => '0');
signal fifo_oe_r  : std_logic :='0';
signal isEmpty		:	std_logic :='0';
signal isFull			: std_logic :='0';

begin
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
    cpha     => '1',                  --spi clock phase
    cont     => '0',                  --continuous mode command
    clk_div  => 5,										--system clock cycles, based on 1/2 period of clock (~10MHz -> 3 ; 100K -> 250)
    addr     => 0,                    --address of slave
    tx_data  => spi_txdata,           --data to transmit
    sclk     => spi_sclk,             --spi clock
    ss_n     => spi_ss_n,             --slave select
    busy     => spi_busy,             --busy / data ready signal
    rx_data  => spi_rxdata,						--data received
	 MISOMOSI => GPIO_SPI_SDIO 					--GPIO(6)
	);

fifo_ip: IP_FIFO
	PORT MAP
	(
		clock	=> CLOCK_50,
		data	=> fifo_write,
		rdreq	=> fifo_oe_r, 
		wrreq	=> fifo_oe_w,
		empty	=> isEmpty,
		full	=> isFull,
		q			=> fifo_read
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
	-- SPI DAC state machine
	--

	statep: process( reset_n, CLOCK_50 )
	
	begin
		if reset_n = '0' then
			spi_enable <= '0';
			spi_pbusy <= '1';
			cState <= IDLEst;
			
		elsif rising_edge( CLOCK_50) then
			
			case cState is
					
				when IDLEst =>
--					cpt_spiClock <= 0;
					
					if DAC_OE_INPUT = '0' then
						cState <= IDLEst;						
					else
						if isFull = '0' then
							fifo_oe_w <= '1';
							cState		<= WRITEst;
						else
							cState <= IDLEst;
						end if;
					end if;
					
				when WRITEst =>
					fifo_write	<= RECV_DATA;
					fifo_oe_r		<= '1';
					spi_enable	<= '1';
					DAC_OE_OUTPUT	<= '1';
					
					cState			<= TRANSMITst;
					
				when TRANSMITst =>
					fifo_oe_w <= '0';
					spi_txdata(15 downto 0)	 <= fifo_read;
					spi_txdata(19 downto 16) <= SPI_CONFIG(1);
					spi_txdata(23 downto 20) <= SPI_CONFIG(0);
					
					cState <= TRANSMITCONFst;
					
				when TRANSMITCONFst =>
					
					fifo_oe_r			<= '0';
					spi_enable		<= '0';
					DAC_OE_OUTPUT	<= '0';
					
					cState <= IDLEst;
					
				when others	=>
					cState <= IDLEst;
					
			end case;
		end if;
		
	end process statep;

end dac_IPFifo;

















---------------------------------------------------------
--
--	test to debunk motor controler mode acceleration
--
---------------------------------------------------------
--architecture dac_MultIPFifo of spi_DAC is
--
----SPI master component
-- COMPONENT spi_master
--  GENERIC(
--    slaves  : INTEGER := 4;  --number of spi slaves
--    d_width : INTEGER := 2
--	 ); --data bus width
--  PORT(
--    clock   : IN     STD_LOGIC;                             --system clock
--    reset_n : IN     STD_LOGIC;                             --asynchronous reset
--    enable  : IN     STD_LOGIC;                             --initiate transaction
--    cpol    : IN     STD_LOGIC;                             --spi clock polarity
--    cpha    : IN     STD_LOGIC;                             --spi clock phase
--    cont    : IN     STD_LOGIC;                             --continuous mode command
--    clk_div : IN     INTEGER;                               --system clock cycles, based on 1/2 period of clock (~10MHz -> 3 ; 100K -> 250)
--    addr    : IN     INTEGER;                               --address of slave
--    tx_data : IN     STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);	--data to transmit
--    sclk    : BUFFER STD_LOGIC;                             --spi clock
--    ss_n    : BUFFER STD_LOGIC_VECTOR(slaves-1 DOWNTO 0);   --slave select
--    busy    : OUT    STD_LOGIC;                             --busy / data ready signal
--    rx_data : OUT    STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);	--data received
--	 MISOMOSI: INOUT	STD_LOGIC
--	);
-- END COMPONENT;
--
----FIFO component
--COMPONENT IP_FIFO
--	PORT
--	(
--		clock		: IN STD_LOGIC ;
--		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
--		rdreq		: IN STD_LOGIC ;
--		wrreq		: IN STD_LOGIC ;
--		empty		: OUT STD_LOGIC ;
--		full		: OUT STD_LOGIC ;
--		q				: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
--	);
--END COMPONENT;
--
--signal reset_n : STD_LOGIC;
--signal SampKey : STD_LOGIC_VECTOR(3 DOWNTO 0);
--
--signal ss_n       : STD_LOGIC_VECTOR(0 DOWNTO 0); 
--signal spi_enable : STD_LOGIC;
--signal spi_ss_n   : STD_LOGIC_VECTOR(0 DOWNTO 0); 
--signal spi_busy   : STD_LOGIC;
--signal spi_pbusy  : STD_LOGIC;
--signal spi_sclk   : STD_LOGIC;
--signal spi_txdata : STD_LOGIC_VECTOR(23 DOWNTO 0);
--signal spi_rxdata : STD_LOGIC_VECTOR(23 DOWNTO 0);
--
--type T_SPISTATE is ( IDLEst, WRITEst, TRANSMITCONFst, TRANSMITst, WAITENDTRANSst);
--signal cState     : T_SPISTATE;
--
--type SPI_CONF is array (0 to 15) of std_logic_vector (3 downto 0);
--signal DAC_COMMAND	: SPI_CONF;
--signal DAC_ADRS		: SPI_CONF;
--
--type T_WORD_ARR is array (natural range <>) of std_logic_vector;
--
--constant WRITEnUPDATE  	: std_logic_vector(3 downto 0) := 4x"3";
--constant DAC_ADDRESS		: std_logic_vector(3 downto 0) := 4x"0";
--
--constant SPI_CONFIG : T_WORD_ARR:= (
--			WRITEnUPDATE,
--			DAC_ADDRESS			
--			);
--
--signal	previous			: std_logic 	:= '0';
--signal	current				: std_logic			:= '0';
--signal	cpt_spiClock	: integer 	:= 0;
--
----FIFO SIGNAL
--signal fifo_write : std_logic_vector(15 downto 0);
--signal fifo_oe_w  : std_logic :='0';
--signal fifo_read  : std_logic_vector(15 downto 0) := (others => '0');
--signal fifo_oe_r  : std_logic :='0';
--signal isEmpty		:	std_logic :='0';
--signal isFull			: std_logic :='0';
--
--begin
--
-- DAC_COMMAND(0)		<= "0000"; --Write code to n
-- DAC_COMMAND(1)		<= "1000"; --write code to all
-- DAC_COMMAND(2)		<= "0110"; --write Span to n
-- DAC_COMMAND(3)		<= "1110"; --write Span to n
-- DAC_COMMAND(4)		<= "0001"; --Update n (power Up)
-- DAC_COMMAND(5)		<= "1001"; --Update all (power Up)
-- DAC_COMMAND(6)		<= "0011"; --Write code to n, Update n (power Up)
-- DAC_COMMAND(7)		<= "0010"; --Write code to n, Update all (power Up)
-- DAC_COMMAND(8)		<= "1010"; --Write code to all, Update all (power Up)
-- DAC_COMMAND(9)		<= "0100"; --power down n
-- DAC_COMMAND(10) 	<= "0101";--power down chip
-- DAC_COMMAND(11) 	<= "1011";--Minitor Mux
-- DAC_COMMAND(12) 	<= "1100";--toggle select
-- DAC_COMMAND(13) 	<= "1101";--global toggle
-- DAC_COMMAND(14) 	<= "0111";--Config
-- DAC_COMMAND(15) 	<= "1111";--No Operation
--
-- DAC_ADRS(0)  <= "0000";		--DAC 0
-- DAC_ADRS(1)	<= "0001";		--DAC 1
-- DAC_ADRS(2)	<= "0010";		--DAC 2
-- DAC_ADRS(3)	<= "0011";		--DAC 3
-- DAC_ADRS(4)	<= "0100";		--DAC 4
-- DAC_ADRS(5)	<= "0101";		--DAC 5
-- DAC_ADRS(6)	<= "0110";		--DAC 6
-- DAC_ADRS(7)	<= "0111";		--DAC 7
-- DAC_ADRS(8)	<= "1000";		--DAC 8
-- DAC_ADRS(9)	<= "1001";		--DAC 9
-- DAC_ADRS(10)	<= "1010";		--DAC 10
-- DAC_ADRS(11)	<= "1011";		--DAC 11
-- DAC_ADRS(12)	<= "1100";		--DAC 12
-- DAC_ADRS(13)	<= "1101";		--DAC 13
-- DAC_ADRS(14)	<= "1110";		--DAC 14
-- DAC_ADRS(15)	<= "1111";		--DAC 15
--
-- reset_n <= RESET_SIGNAL;
--
-- GPIO_SPI_CLK	<= spi_sclk;		--GPIO( 5 )
-- GPIO_SPI_SS		<= spi_ss_n(0);	--GPIO( 7 )
-- 
--------------------------------------------------------
----
---- intantiation of components
----
--------------------------------------------------------
--
-- sm_dac: entity work.spi_master(SPI_DAC)
--  GENERIC MAP (
--    slaves  => 1,
--    d_width => 24
--	 )
--  PORT MAP(
--    clock    => CLOCK_50,
--    reset_n  => reset_n,
--    enable   => spi_enable,
--    cpol     => '1',
--    cpha     => '1',                  --spi clock phase
--    cont     => '0',                  --continuous mode command
--    clk_div  => 5,										--system clock cycles, based on 1/2 period of clock (~10MHz -> 3 ; 100K -> 250)
--    addr     => 0,                    --address of slave
--    tx_data  => spi_txdata,           --data to transmit
--    sclk     => spi_sclk,             --spi clock
--    ss_n     => spi_ss_n,             --slave select
--    busy     => spi_busy,             --busy / data ready signal
--    rx_data  => spi_rxdata,						--data received
--	 MISOMOSI => GPIO_SPI_SDIO 					--GPIO(6)
--	);
--
-- gen_FIFO : for I in 0 to 2 generate	--3 fifo needed (accelaration, speed, position) 
--	fifo_ip: IP_FIFO
--		PORT MAP
--		(
--			clock	=>											CLOCK_50,	-----------------------
--			data	=> 											fifo_oe_w(I),
--			rdreq	=> 											fifo_write(I),
--			wrreq	=> 											fifo_oe_r(I),			
--			empty	=> 											fifo_read(I),
--			full	=> 											fifo_emtFlg(I),
--			q			=> 											fifo_fulFlg(I)
--	);
--
--------------------------------------------------------
----
---- SPI DAC: states machineS
----
--------------------------------------------------------	
--
--	checkInAndWrite: process( reset_n, CLOCK_50 )
--	
--	begin
--	
--		if rising_edge(CLOCK_50) then
--			
--			for I in 0 to 2 loop
--				if fifo_fulFlg(I) /= '1' then
--					if DAC_OE_INPUT(I) = '1' then
--						fifo_oe_w(I) <= '1';
--						fifo_write(I) <= DAC_COMMAND(6) & DAC_ADRS(I) & RECV_DATA(I);
--					end if;
--				end if;
--			end loop;		
--		
--		elsif falling_edge(CLOCK_50) then
--			
--			for I in 0 to NBROFMODULE-1 loop
--					fifo_oe_w(I) <= '0';
--			end loop;
--			
--		end if;		
--	end process checkInAndWrite;
--
--end dac_MultIPFifo;