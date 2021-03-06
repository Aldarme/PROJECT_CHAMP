--test ebch for module
--compose of: SPI accel & filter & SPI DAC

library ieee;
use ieee.std_logic_1164.all;

entity TopEntity_tb is
end entity;

architecture arch of TopEntity_tb is

	signal CLOCK_50   : STD_LOGIC := '0';
	signal reset_n		: STD_LOGIC;
	signal GPIO       : STD_LOGIC_VECTOR(35 DOWNTO 0); 
	signal adxl_ss_n  : STD_LOGIC;
	signal adxl_sclk  : STD_LOGIC;
	signal adxl_sdio	:	STD_LOGIC;
	signal SW_tb			: STD_LOGIC_VECTOR(17 DOWNTO 0);
	signal HEX4_tb	 	: STD_LOGIC_VECTOR(6 DOWNTO 0);
	signal HEX5_tb	  : STD_LOGIC_VECTOR(6 DOWNTO 0);
	
 COMPONENT TopEntity
	PORT
	(
		TOP_CLOCK_50:	IN STD_LOGIC;
		TOP_LEDG		:	OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		TOP_LEDR		:	OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		TOP_KEY 		:	IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
		TOP_GPIO		:	INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		SW					: IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		HEX4				: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX5				: OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
 END COMPONENT;

 COMPONENT adxl355_beh
	PORT
	(
		SCLK : in  STD_LOGIC;		--SPI clock
	   CSB  : in  STD_LOGIC;		--slave selection
	   SDI_O  : INOUT  STD_LOGIC	--MOSI/Miso
	);
 END COMPONENT;
 
 COMPONENT LTC2668_16_beh
	PORT
	(
		CLOCK_50		:	IN STD_LOGIC;
		LTC_SS		:	IN  STD_LOGIC;
		LTC_SCLK		:	IN STD_LOGIC;
		LTC_SDI		:	IN STD_LOGIC
	);
 END COMPONENT;

 begin

 CLOCK_50 <= not CLOCK_50 after 10.0 ns;
 GPIO   <= ( others=>'Z' );
 reset_n <= '0', '1' after 97.0 ns;

----------------------------------------------------------------
--
-- TopEntity composition:
--	spi_accel / filter / spi_Dac
--
----------------------------------------------------------------
 tent: TopEntity
	PORT MAP
	(
		TOP_CLOCK_50	=> CLOCK_50,
      TOP_KEY 		=> ( 3=> reset_n, others=>'0' ),
      TOP_GPIO		=> GPIO,
			SW	 				=> SW_tb,
			HEX4 				=> HEX4_tb,
			HEX5 				=> HEX5_tb
	); 
 
----------------------------------------------------------------
--
-- Emulate accelerometer - ADXL355
--
----------------------------------------------------------------
 adxl_sclk <= GPIO(31);
 adxl_ss_n <= GPIO(33);
 adxl_sdio <= GPIO(29);
 
 
 accel:adxl355_beh
	PORT MAP
	(
		SCLK 		=> adxl_sclk,
	   CSB  	=> adxl_ss_n,
	   SDI_O  => adxl_sdio
	);
	
 ltc : LTC2668_16_beh
	PORT MAP
	(
		CLOCK_50	=> CLOCK_50,
		LTC_SS		=> GPIO(7),
		LTC_SCLK	=> GPIO(5),
		LTC_SDI 	=> GPIO(6)
	);
	
end arch;