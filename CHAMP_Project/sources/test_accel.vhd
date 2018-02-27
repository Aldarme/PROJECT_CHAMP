-- Quartus II VHDL Template
-- Binary Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;

entity test_accel is
	PORT
	(
		CLOCK_50   	:   IN STD_LOGIC; 
		CLOCK2_50  	:   IN STD_LOGIC; 
		CLOCK3_50  	:   IN STD_LOGIC; 
		LEDG    		:   OUT STD_LOGIC_VECTOR(8 DOWNTO 0); 
		LEDR    		:   OUT STD_LOGIC_VECTOR(24 DOWNTO 0); 
		KEY    		:   IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
		SW    		:   IN STD_LOGIC_VECTOR(17 DOWNTO 0); 
		HEX0    		:   OUT STD_LOGIC_VECTOR(6 DOWNTO 0); 
		HEX1    		:   OUT STD_LOGIC_VECTOR(6 DOWNTO 0); 
		HEX2    		:   OUT STD_LOGIC_VECTOR(6 DOWNTO 0); 
		HEX3    		:   OUT STD_LOGIC_VECTOR(6 DOWNTO 0); 
		HEX4    		:   OUT STD_LOGIC_VECTOR(6 DOWNTO 0); 
		HEX5    		:   OUT STD_LOGIC_VECTOR(6 DOWNTO 0); 
		HEX6    		:   OUT STD_LOGIC_VECTOR(6 DOWNTO 0); 
		HEX7    		:   OUT STD_LOGIC_VECTOR(6 DOWNTO 0); 
		LCD_BLON    :   OUT STD_LOGIC; 
		LCD_DATA    :   INOUT STD_LOGIC_VECTOR(7 DOWNTO 0); 
		LCD_EN    	:   OUT STD_LOGIC; 
		LCD_ON    	:   OUT STD_LOGIC; 
		LCD_RS    	:   OUT STD_LOGIC; 
		LCD_RW    	:   OUT STD_LOGIC; 
		UART_CTS    :   IN STD_LOGIC; 
		UART_RTS    :   OUT STD_LOGIC; 
		UART_RXD    :   IN STD_LOGIC; 
		UART_TXD    :   OUT STD_LOGIC; 
		GPIO    		:   INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)	 
	);

end entity;

architecture rtl of test_accel is

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
    --miso    : IN     STD_LOGIC;                             --master in, slave out
    sclk    : BUFFER STD_LOGIC;                             --spi clock
    ss_n    : BUFFER STD_LOGIC_VECTOR(slaves-1 DOWNTO 0);   --slave select
    --mosi    : OUT    STD_LOGIC;                             --master out, slave in
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
--signal spi_mosi   : STD_LOGIC;
--signal spi_miso   : STD_LOGIC;
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

constant ADXL_DATAZ1_ADD  : std_logic_vector(6 downto 0):=7x"10";--10
constant ADXL_DATAZ2_ADD  : std_logic_vector(6 downto 0):=7x"0F";--0F
constant ADXL_DATAZ3_ADD  : std_logic_vector(6 downto 0):=7x"0E";

constant SPI_ADD_FIELD    : std_logic_vector(15 downto 8):=(others=>'0');
constant SPI_DATA_FIELD   : std_logic_vector(7 downto 0):=(others=>'0');

constant ACCEL_CONFIG : T_WORD_ARR:= (
			7x"2D" & ADXL_WRITE_REG & 8x"01",	--initiate protocol to configure registers (standby <- 1 : standby mode)
			7x"2C" & ADXL_WRITE_REG & 8x"03",
			7x"2D" & ADXL_WRITE_REG & 8x"02"		--End protocol to configure registers (standby mode <- 0 : mesurement mode)
			);
			
constant ACCEL_READ : T_WORD_ARR:= (
			ADXL_DATAZ1_ADD & ADXL_READ_REG & x"00", -- DATAZ1 (LSB)
			ADXL_DATAZ2_ADD & ADXL_READ_REG & X"00", -- DATAZ2
			ADXL_DATAZ3_ADD & ADXL_READ_REG & X"00"  -- DATAZ3 (MSB)
			);

--signal ConfAddress: integer range 0 to ( maximum(ACCEL_CONFIG'LENGTH, ACCEL_READ'LENGTH) -1);
signal ConfAddress: natural;

constant CLOCK_50_FREQ : real:=50.0E6;
constant SPI_READ_FREQ : real:=3.0E3; 
constant SPI_READ_NCLK : natural:=natural( ceil(CLOCK_50_FREQ/SPI_READ_FREQ) );
signal   spi_read_cpt  : natural range 0 to SPI_READ_NCLK;
signal   spi_read_cpt_zero :  std_logic;
signal   spi_read_restart  : std_logic;

begin
LEDG( 0 ) <= not KEY(0);
LEDG( 3 ) <= not KEY(3);

LEDG( 1 ) <= not spi_busy;

reset_n <= KEY(3);
--spi_addr <= 0; -- DEVID
--spi_enable <= not KEY(0);

--spi_txdata <= ( X"80" or X"2c" ) & X"0F";
--spi_txdata <= ( SW(0) & "000" & X"0" or X"2c" ) & X"0F";

--spi_miso <= GPIO( 0 ); -- SDO
GPIO( 1 ) <= spi_sclk;
--GPIO( 2 ) <= spi_mosi;
GPIO( 3 ) <= spi_ss_n(0);


LEDR(19 downto 0 ) <= spi_dataz;
LEDR(24) <= new_accel_data; -- juste pour préserver le signal à la synthèse

sm: spi_master

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
    --miso     => spi_miso,                    --master in, slave out
    sclk     => spi_sclk,                    --spi clock
    ss_n     => spi_ss_n,                		--slave select
    --mosi     => spi_mosi,                    --master out, slave in
    busy     => spi_busy,                    --busy / data ready signal
    rx_data  => spi_rxdata,						--data received
	 MISOMOSI => GPIO(0)
	);

	samp: process(reset_n, CLOCK_50) is 
		-- Declaration(s) 
	begin 
		if(reset_n = '0') then
			SampKey <= ( others=> '1' );
		elsif(rising_edge(CLOCK_50)) then
			SampKey <= KEY;
--			spi_enable <= not KEY(0) and SampKey(0);

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
					ConfAddress <= 0;
					spi_enable <= '0';
					cState <= CONFst;
					spi_dataz <= ( others=> '0');
					new_accel_data <= '0';
					spi_read_restart <= '0';
					
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
					ConfAddress <= 0;
					spi_enable <= '0';
					if spi_read_cpt_zero='1' then
						cState <= READst;
						spi_read_restart <= '1';
					end if;
					new_accel_data <= '0';
					
				when READst =>
					spi_read_restart <= '0';
					spi_enable <= '1';
					spi_txdata <= ACCEL_READ(ConfAddress);
					cState <= READBUSYst;
				
				when READBUSYst =>
					spi_enable <= '0';
					if spi_busydn='1' then
					
						case spi_txdata( SPI_ADD_FIELD'RANGE ) is
							when ADXL_DATAZ1_ADD & ADXL_READ_REG =>
								spi_dataz(  7 downto 0 ) <= spi_rxdata( 7 downto 0 );				-- 8 bits sur le mot bas, mais bit 0 toujours à zéro
								
							when ADXL_DATAZ2_ADD & ADXL_READ_REG =>
								spi_dataz( 15 downto 8 ) <= spi_rxdata( 7 downto 0 );		

							when ADXL_DATAZ3_ADD & ADXL_READ_REG =>
								spi_dataz( 19 downto 16 ) <= spi_rxdata( 7 downto 4 );
								--spi_dataz( 23 downto 20 ) <= ( others => '0' );						--4 bits reserved defines into the datasheet
								
							when others =>
								null; --modif null to delete latch
						end case;
						
						if ConfAddress=ACCEL_READ'LENGTH-1 then
							cState <=  IDLEst;
							new_accel_data <= '1';
						else
							ConfAddress <= ConfAddress+1;
							cState <= READst;
						end if;
					else
						cState <= READBUSYst;
					end if;

				when others =>
					null;
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