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
		CLOCK_50   	:   IN STD_LOGIC;
		LEDG    		:   OUT STD_LOGIC_VECTOR(8 DOWNTO 0); 
		LEDR    		:   OUT STD_LOGIC_VECTOR(24 DOWNTO 0); 
		KEY    		:   IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		GPIO    		:   INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		RECV_DATA	:	 INOUT STD_LOGIC_VECTOR(24 DOWNTO 0);
		ACKNOLEDGE	:	 IN STD_LOGIC
	);

end entity;

architecture myArchi of spi_DAC is

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

signal reset_n : STD_LOGIC;
signal SampKey : STD_LOGIC_VECTOR(3 DOWNTO 0);

signal ss_n       : STD_LOGIC_VECTOR(0 DOWNTO 0); 
signal spi_enable : STD_LOGIC;
signal spi_ss_n   :  STD_LOGIC_VECTOR(0 DOWNTO 0); 
signal spi_busy   : STD_LOGIC;
signal spi_pbusy  : STD_LOGIC;
signal spi_sclk   : STD_LOGIC;
signal spi_txdata : STD_LOGIC_VECTOR(24 DOWNTO 0);
signal spi_rxdata : STD_LOGIC_VECTOR(15 DOWNTO 0);

type   T_SPISTATE is ( RESETst, WAITst, TRANSMITst);
signal cState     : T_SPISTATE;

type    T_WORD_ARR is array (natural range <>) of std_logic_vector;

constant WRITEnUPDATE  : std_logic_vector(3 downto 0):=4x"3";
constant DAC_ADDRESS	  : std_logic_vector(3 downto 0):=4x"0";

constant SPI_CONFIG : T_WORD_ARR:= (
			WRITEnUPDATE & DAC_ADDRESS	--initiate protocol to configure registers (standby <- 1 : standby mode)
			);

constant CLOCK_50_FREQ : real:=50.0E6;
constant SPI_READ_FREQ : real:=3.0E3; 
constant SPI_READ_NCLK : natural:=natural( ceil(CLOCK_50_FREQ/SPI_READ_FREQ) );
signal   spi_read_cpt  : natural range 0 to SPI_READ_NCLK;
signal   spi_read_cpt_zero :  std_logic;


begin
LEDG( 4 ) <= not KEY(1);
LEDG( 5 ) <= not KEY(2);

LEDG( 6 ) <= not spi_busy;

reset_n <= KEY(2);

GPIO( 5 ) <= spi_sclk;
GPIO( 6 ) <= spi_ss_n(0);

LEDR(19 downto 0 ) <= RECV_DATA(15 downto 0);


sm: entity work.spi_master(SPI_DAC)

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
	 MISOMOSI => GPIO(4)
	);

	samp: process(reset_n, CLOCK_50) is 
	-- Declaration(s) 
	begin 
		if(reset_n = '0') then
			SampKey <= ( others=> '1' );
		elsif(rising_edge(CLOCK_50)) then
			SampKey <= KEY;

		end if;
	end process samp;

	--
	-- Accelerometer state machine
	--
	statep: process( reset_n, CLOCK_50 )
	begin
		if reset_n='0' then
			cState <= RESETst;
			spi_enable <= '0';
			spi_pbusy <= '1';
			
			
		elsif rising_edge(CLOCK_50) then	--RESETst, WAITst, TRANSMITst
			
			case cState is
				
				when RESETst =>
					spi_enable <= '0';
					cState <= WAITst;
					
				when WAITst =>
					spi_enable <= '0';
					if ACKNOLEDGE = '0' then
						cState <= WAITst;
					else						
						cState <= SPI_CONFIG & TRANSMITst;
					end if;
				
				when TRANSMITst =>
					spi_enable <= '1';
					spi_txdata <= RECV_DATA;
					cState <= WAITst;		
				
			end case;
			
			if cState=RESETst then
				spi_pbusy  <= '0';
			else
				spi_pbusy  <= spi_busy;
			end if;
		end if;
		
	end process statep;

end myArchi;