-- Quartus Prime VHDL Template
-- Basic Shift Register

library ieee;
use ieee.std_logic_1164.all;

entity test_accel_tb is
end entity;

architecture rtl of test_accel_tb is
	signal CLOCK_50     : std_logic := '0';
	signal rst, reset_n : std_logic;
	signal GPIO		    : STD_LOGIC_VECTOR(35 DOWNTO 0);

	signal adxl_ss_n   : STD_LOGIC;
	signal adxl_sclk   : STD_LOGIC;
	signal adxl_mosi   : STD_LOGIC;
	signal adxl_miso   : STD_LOGIC;

COMPONENT test_accel
	PORT
	(
		CLOCK_50		:	 IN STD_LOGIC;
		CLOCK2_50		:	 IN STD_LOGIC;
		CLOCK3_50		:	 IN STD_LOGIC;
		LEDG		:	 OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		LEDR		:	 OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		KEY		:	 IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		SW		:	 IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		HEX0		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX1		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX2		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX3		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX4		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX5		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX6		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX7		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		LCD_BLON		:	 OUT STD_LOGIC;
		LCD_DATA		:	 INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		LCD_EN		:	 OUT STD_LOGIC;
		LCD_ON		:	 OUT STD_LOGIC;
		LCD_RS		:	 OUT STD_LOGIC;
		LCD_RW		:	 OUT STD_LOGIC;
		UART_CTS		:	 IN STD_LOGIC;
		UART_RTS		:	 OUT STD_LOGIC;
		UART_RXD		:	 IN STD_LOGIC;
		UART_TXD		:	 OUT STD_LOGIC;
		GPIO		:	 INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)
	);
END COMPONENT;

COMPONENT adxl355_beh
	PORT
	(
		SCLK		:	 IN STD_LOGIC;
		CSB		:	 IN STD_LOGIC;
		SDI		:	 IN STD_LOGIC;
		SDO		:	 OUT STD_LOGIC
	);
END COMPONENT;

begin

	CLOCK_50 <= not CLOCK_50 after 10.0 ns;
	rst    <= '1', '0' after 331.3 ns;
	GPIO   <= ( others=>'Z' );

	dut: test_accel
	PORT MAP 
	(
		CLOCK_50		=> CLOCK_50,
		CLOCK2_50		=> CLOCK_50,
		CLOCK3_50		=> CLOCK_50,
		-- LEDG		:	 OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		-- LEDR		:	 OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		KEY				=> ( 3=> reset_n, others=>'0' ),
		SW				=> ( others=>'0' ),
		-- HEX0		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		-- HEX1		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		-- HEX2		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		-- HEX3		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		-- HEX4		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		-- HEX5		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		-- HEX6		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		-- HEX7		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		-- LCD_BLON		:	 OUT STD_LOGIC;
		-- LCD_DATA		:	 INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		-- LCD_EN		:	 OUT STD_LOGIC;
		-- LCD_ON		:	 OUT STD_LOGIC;
		-- LCD_RS		:	 OUT STD_LOGIC;
		-- LCD_RW		:	 OUT STD_LOGIC;
		UART_CTS		=> '0',
		-- UART_RTS		:	 OUT STD_LOGIC;
		UART_RXD		=> '0',
		-- UART_TXD		:	 OUT STD_LOGIC;
		GPIO			=> GPIO
	);

	adxl_sclk <= GPIO( 1 );
	adxl_mosi <= GPIO( 2 );
	adxl_ss_n <= GPIO( 3 );
	GPIO( 0 ) <= adxl_miso;
	
	acc: adxl355_beh
	PORT MAP
	(
		SCLK	=> adxl_sclk,
		CSB		=> adxl_ss_n,
		SDI		=> adxl_mosi,
		SDO		=> adxl_miso
	);
end rtl;
