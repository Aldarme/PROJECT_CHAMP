

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spiDac_tb is
end entity;

architecture arch of spiDac_tb is
	
	signal CLOCK_50_tb    	: std_logic := '0';
	signal clock1k		: std_logic := '1';
	signal reset_n		: std_logic;
	signal GPIO_tb     : std_logic_vector(35 DOWNTO 0);
	signal KEY_tb		: std_logic_vector(3 downto 0);
	signal ss_tb		: std_logic;
	signal clk			: std_logic;
	signal sdio_tb		: std_logic;
	signal dataIn		: std_logic_vector(15 downto 0);
	signal oe_in_tb		: std_logic;
	signal oe_out_tb	: std_logic;
	
	signal cpt 	: integer := 0;
	signal V_incr : std_logic_vector(15 downto 0);	
	
	component spi_DAC is
		PORT
		(
			CLOCK_50   		:  IN STD_LOGIC;
			KEY    			:  IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			GPIO_SPI_CLK	:	INOUT STD_LOGIC;
			GPIO_SPI_SS		:	INOUT STD_LOGIC;
			GPIO_SPI_SDIO	:	INOUT STD_LOGIC;
			RECV_DATA		:	IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			DAC_OE_INPUT	:	IN STD_LOGIC;
			DAC_OE_OUTPUT	:	OUT STD_LOGIC;
			RESET_SIGNAL 	:	IN STD_LOGIC
		);
	end component;
	
	begin
	
	CLOCK_50_tb <= not CLOCK_50_tb after 10.0 ns;
	clock1k <= not clock1k after 0.5 ms;
	GPIO_tb   <= ( others=>'Z' );
	reset_n <= '0', '1' after 97.0 ns;
	
	spiDac: entity work.spi_DAC(dac_IPFifo)
		port map
		(
			CLOCK_50   		  => CLOCK_50_tb,
			KEY    			  => KEY_tb,
			GPIO_SPI_CLK	  => clk,
			GPIO_SPI_SS		  => ss_tb,
			GPIO_SPI_SDIO	  => sdio_tb,
			RECV_DATA		  => dataIn,
			DAC_OE_INPUT	  => oe_in_tb,
			DAC_OE_OUTPUT	  => oe_out_tb,
			RESET_SIGNAL 	  => reset_n
		);
	
	ipfif: process(clock1k) is
	begin
		if rising_edge(clock1k) then
			oe_in_tb 	<= '1';
			dataIn		<= V_incr;
			
		else
			oe_in_tb 	<= '0';
			cpt <= cpt + 1;
			V_incr <= std_logic_vector(to_signed(cpt, dataIn'length));
			
		end if;
	end process ipfif;

end arch;