--test ebch for module
--compose of: SPI accel & filter & SPI DAC

library ieee;
use ieee.std_logic_1164.all;

entity GenEntity_tb is
end entity;

architecture arch of GenEntity_tb is

	constant nbrOfGen	: integer := 12;
	
	signal CLOCK_50   : std_logic := '0';
	signal reset_n		: std_logic;
	signal GPIO       : STD_LOGIC_VECTOR(35 DOWNTO 0);
	signal HSMC			: std_logic_vector(15 downto 0);
		
 COMPONENT GenEntity
	PORT
	(
		TOP_CLOCK_50	:	IN STD_LOGIC;
		TOP_LEDG			:  OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		TOP_LEDR			:  OUT STD_LOGIC_VECTOR(24 DOWNTO 0);
		TOP_KEY 			:  IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
		TOP_GPIO			:  INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		TOP_HSMC			:	INOUT STD_LOGIC_VECTOR(15 downto 0)
	);
 END COMPONENT;

 COMPONENT adxl355_beh
	PORT
	(
		SCLK	: in  STD_LOGIC;		--SPI clock
	   CSB	: in  STD_LOGIC;		--slave selection
	   SDI_O : INOUT  STD_LOGIC	--MOSI/Miso
	);
 END COMPONENT;
 
 COMPONENT LTC2668_16_beh
	PORT
	(
		CLOCK_50	:	IN STD_LOGIC;
		LTC_SS	:	IN  STD_LOGIC;
		LTC_SCLK	:	IN STD_LOGIC;
		LTC_SDI	:	IN STD_LOGIC
	);
 END COMPONENT;

 begin

 CLOCK_50 <= not CLOCK_50 after 10.0 ns;
 GPIO   <= ( others=>'Z' );
 reset_n <= '0', '1' after 97.0 ns;

----------------------------------------------------------------
--
-- GenEntity composition:
--	 generate of : spi_accel / filter
--	 spi_Dac
--
----------------------------------------------------------------
 gen_ent: GenEntity
	PORT MAP
	(
		TOP_CLOCK_50 => CLOCK_50,
		TOP_KEY 		 => ( 3=> reset_n, others=>'0' ),
		TOP_GPIO		 => GPIO,
		TOP_HSMC		 => HSMC
	); 
 
----------------------------------------------------------------
--
-- generate of Emulate accelerometer - ADXL355
--
----------------------------------------------------------------
 gen_ADXL355_beh : for I in 0 to nbrOfGen-1 generate
	
	accel:adxl355_beh
	PORT MAP
	(
		SCLK 	=> GPIO(3*I),
	  CSB  	=> GPIO((3*I)+1),
	  SDI_O => GPIO((3*I)+2)
	);
	
 end generate gen_ADXL355_beh;
	
 ltc : LTC2668_16_beh
	PORT MAP
	(
		CLOCK_50	=> CLOCK_50,
		LTC_SS	=> HSMC(1),
		LTC_SCLK	=> HSMC(0),
		LTC_SDI 	=> HSMC(2)
	);
	
end arch;