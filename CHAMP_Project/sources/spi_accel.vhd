-- Quartus II VHDL Template
-- Binary Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;

entity spi_accel is
	PORT
	(
		CLOCK_50   		:  IN STD_LOGIC;
		LEDG    			:  OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		LEDR    			:  OUT STD_LOGIC_VECTOR(24 DOWNTO 0);
		KEY    				:  IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
		GPIO_SPI_CLK	:	INOUT STD_LOGIC;
		GPIO_SPI_SS		:	INOUT STD_LOGIC;
		GPIO_SPI_SDIO	:	INOUT STD_LOGIC;
		DATA_OUT			:	out STD_LOGIC_VECTOR(19 DOWNTO 0);
		DATA_ENABLE		:	out STD_LOGIC;
		RESET_SIGNAL	:	in STD_LOGIC
	);

end entity;

architecture rtl of spi_accel is

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
signal spi_busydn : STD_LOGIC;
signal spi_sclk   : STD_LOGIC;
signal spi_txdata : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal spi_rxdata : STD_LOGIC_VECTOR(15 DOWNTO 0);
alias  spi_rxbyte is spi_rxdata( 7 downto 0);
signal spi_dataz  : STD_LOGIC_VECTOR(19 DOWNTO 0);
signal new_accel_data  : STD_LOGIC;

-- signal spi_start_button : STD_LOGIC;

type   T_SPISTATE is ( RESETst, CONFst, CONFBUSYst, IDLEst, READst, READBUSYst );
signal cState     : T_SPISTATE;

type    T_WORD_ARR is array (natural range <>) of std_logic_vector;

---
--- ADXL355 Registers addresses
---
constant ADXL_READ_REG    : std_logic := '1';
constant ADXL_WRITE_REG   : std_logic := '0';

constant ADXL_DATAZ1_ADD  : std_logic_vector(6 downto 0):=7x"0E";
constant ADXL_DATAZ2_ADD  : std_logic_vector(6 downto 0):=7x"0F";
constant ADXL_DATAZ3_ADD  : std_logic_vector(6 downto 0):=7x"10";

constant SPI_ADD_FIELD    : std_logic_vector(15 downto 8):=(others=>'0');
constant SPI_DATA_FIELD   : std_logic_vector(7 downto 0):=(others=>'0');

constant ACCEL_CONFIG : T_WORD_ARR:= (
			7x"2D" & ADXL_WRITE_REG & 8x"01",		--initiate protocol to configure registers (standby <- 1 : standby mode)
			7x"2F" & ADXL_WRITE_REG & 8x"52",		--Power-on reset, code 0x52
			7x"2C" & ADXL_WRITE_REG & 8x"03",		--G range [+-8g : 3] ; [+- 4g : 2] ; [+-2g : 1] ; [disable : 0]
			7x"28" & ADXL_WRITE_REG & 8x"00",		--HPF [0.238 : 6] ; [0.954 : 5] ; [3.862 : 4]
			7x"2D" & ADXL_WRITE_REG & 8x"02"		--End protocol to configure registers (standby mode <- 0 : mesurement mode)
			);
			
constant ACCEL_READ : T_WORD_ARR:= (
			ADXL_DATAZ1_ADD & ADXL_READ_REG & 8x"00", -- DATAZ1 (MSB) - 2100
			ADXL_DATAZ2_ADD & ADXL_READ_REG & 8x"00", -- DATAZ2		 		- 1F00
			ADXL_DATAZ3_ADD & ADXL_READ_REG & 8x"00"  -- DATAZ3 (LSB)	- 1D00
			);
			
signal ConfAddress: natural;

constant CLOCK_50_FREQ : real:=50.0E6;
constant SPI_READ_FREQ : real:=1.0E3; 	--MODIFY FOR A SPEED ADAPT TO ADXL355 -> 1KHz		--old value 3.0E3;
constant SPI_READ_NCLK : natural:=natural( ceil(CLOCK_50_FREQ/SPI_READ_FREQ) );
signal   spi_read_cpt  : natural range 0 to SPI_READ_NCLK;
signal   spi_read_cpt_zero :  std_logic;
signal   spi_read_restart  : std_logic;

begin
LEDG( 0 ) <= not KEY(0);
LEDG( 3 ) <= not KEY(3);

LEDG( 1 ) <= not spi_busy;

reset_n <= RESET_SIGNAL;

GPIO_SPI_CLK	<= spi_sclk;		--GPIO(1)
GPIO_SPI_SS		<= spi_ss_n(0);	--GPIO(3)

LEDR(15 downto 0 ) <= spi_dataz(15 downto 0);


sm_accel: entity work.spi_master(SPI_ACCEL)

  GENERIC MAP (
    slaves  => 1,
    d_width => 16
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
	 MISOMOSI => GPIO_SPI_SDIO						--GPIO(2)
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

	rcpt: process(reset_n, CLOCK_50) is 
	-- Declaration(s) 
	begin 
		if(reset_n = '0') then
			spi_read_cpt      <= 0;
			spi_read_cpt_zero <= '1';
		elsif(rising_edge(CLOCK_50)) then
			if spi_read_restart='1' then
				spi_read_cpt <= SPI_READ_NCLK;
				spi_read_cpt_zero <= '0';
			else
				if spi_read_cpt/=0 then
					spi_read_cpt <= spi_read_cpt-1;
					spi_read_cpt_zero <= '0';
				else
					spi_read_cpt_zero <= '1';
				end if;
			end if;
		end if;
	end process rcpt;

	--
	-- Accelerometer state machine
	--
	statep: process( reset_n, CLOCK_50 )
	begin
		if reset_n='0' then
			cState <= RESETst;
			ConfAddress <= 0;
			spi_enable <= '0';
			spi_pbusy <= '1';
			spi_dataz <= ( others=> '0');
			new_accel_data <= '0';
			spi_read_restart <= '0';
			
		elsif rising_edge(CLOCK_50) then
			case cState is
				when RESETst =>
					DATA_ENABLE <= '0';
					ConfAddress <= 0;
					spi_enable <= '0';					
					spi_dataz <= ( others=> '0');
					new_accel_data <= '0';
					spi_read_restart <= '0';
					cState <= CONFst;
					
				when CONFst =>
					spi_enable <= '1';
					spi_txdata <= ACCEL_CONFIG(ConfAddress);
					cState <= CONFBUSYst;
				
				when CONFBUSYst =>
					spi_enable <= '0';
					if spi_busydn='1' then
						if ConfAddress=ACCEL_CONFIG'LENGTH-1 then
							cState <=  IDLEst;
						else
							ConfAddress <= ConfAddress+1;
							cState <= CONFst;
						end if;
					else
						cState <= CONFBUSYst;
					end if;
					
				when IDLEst =>
					DATA_ENABLE <= '0';
					ConfAddress <= 0;
					spi_enable <= '0';
					if spi_read_cpt_zero='1' then
						cState <= READst;
						spi_read_restart <= '1';
					end if;
					new_accel_data <= '0';
					
				when READst =>
					DATA_ENABLE <= '0';
					spi_read_restart <= '0';
					spi_enable <= '1';
					spi_txdata <= ACCEL_READ(ConfAddress);
					cState <= READBUSYst;
				
				when READBUSYst =>
					DATA_ENABLE <= '0';
					spi_enable <= '0';
					if spi_busydn='1' then
					
						case spi_txdata( SPI_ADD_FIELD'RANGE ) is
						
							when ADXL_DATAZ1_ADD & ADXL_READ_REG =>
								spi_dataz(19 downto 12)	<= spi_rxdata( 7 downto 0 );
								
							when ADXL_DATAZ2_ADD & ADXL_READ_REG =>
								spi_dataz(11 downto 4)	<= spi_rxdata( 7 downto 0 );
								
							when ADXL_DATAZ3_ADD & ADXL_READ_REG =>								
								spi_dataz(3 downto 0 )	<= spi_rxdata( 7 downto 4 );
								
							when others =>
								null; --modif null to delete latch
								
						end case;
						
						if ConfAddress=ACCEL_READ'LENGTH-1 then
							new_accel_data <= '1';
							DATA_ENABLE <= '1';
							DATA_OUT <= spi_dataz;
							cState <=  IDLEst;
						else
							ConfAddress <= ConfAddress+1;
							cState <= READst;
						end if;
					else
						cState <= READBUSYst;
					end if;
					
				when others =>
					cState <= RESETst;
					
			end case;
			
			if cState=RESETst then
				spi_pbusy  <= '0';
			else
				spi_pbusy  <= spi_busy;
			end if;
			spi_busydn <= not spi_busy and spi_pbusy;
		end if;
		
	end process statep;

end rtl;