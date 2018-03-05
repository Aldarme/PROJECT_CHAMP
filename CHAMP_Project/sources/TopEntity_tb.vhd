library ieee;
use ieee.std_logic_1164.all;

entity TopEntity_tb is
end entity;

architecture arch of TopEntity is

	signal CLOCK_50    : std_logic := '0';
	signal reset_n		 : std_logic;
	signal GPIO        : STD_LOGIC_VECTOR(35 DOWNTO 0); 
	signal adxl_ss_n   : STD_LOGIC;
	signal adxl_sclk   : STD_LOGIC;
	signal adxl_mosi   : STD_LOGIC;
	signal adxl_miso   : STD_LOGIC;
	
 COMPONENT TopEntity
	PORT
	(
		TOP_CLOCK_50:	IN STD_LOGIC;
		TOP_LEDG		:   OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		TOP_LEDR		:   OUT STD_LOGIC_VECTOR(24 DOWNTO 0);
		TOP_KEY 		:   IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
		TOP_GPIO		:   INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)
	);
 END COMPONENT;

 COMPONENT adxl355_beh
	PORT
	(
		SCLK : in  STD_LOGIC;	--SPI clock
	   CSB  : in  STD_LOGIC;	--slave selection
	   SDI  : in  STD_LOGIC;	--MOSI
	   SDO  : out STD_LOGIC		--MISO
	);
 END COMPONENT;

 begin

 CLOCK_50 <= not CLOCK_50 after 10.0 ns;
 GPIO   <= ( others=>'Z' );

 tent: TopEntity
	PORT MAP
	(
		TOP_CLOCK_50 => CLOCK_50,
      TOP_KEY 		 => ( 3=> reset_n, others=>'0' ),
      TOP_GPIO		 => GPIO
	);	

 adxl_sclk <= GPIO( 1 );
 adxl_mosi <= GPIO( 2 );
 adxl_ss_n <= GPIO( 3 );
 GPIO( 0 ) <= adxl_miso;
 
 accel:adxl355_beh
	PORT MAP
	(
		SCLK => adxl_sclk,
	   CSB  => adxl_ss_n,
	   SDI  => adxl_mosi,
		SDO  => adxl_miso
	);

end arch;