--test ebch for module
--compose of: SPI accel & filter & SPI DAC

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filterTb is
end entity;

architecture arch of filterTb is

	signal CLOCK_50    	: std_logic := '0';
	signal clock1k			:	std_logic := '1';
	signal reset_n		 	: std_logic;
	signal GPIO       	: STD_LOGIC_VECTOR(35 DOWNTO 0); 
	signal adxl_ss_n 		: STD_LOGIC;
	signal adxl_sclk 		: STD_LOGIC;
	signal tbHex4				:	STD_LOGIC_VECTOR(6 DOWNTO 0);
	signal tbHex5				:	STD_LOGIC_VECTOR(6 DOWNTO 0);
	
	signal accel_enable	: std_logic	:= '0';
	signal accel_dataz	:	std_logic_vector(19 downto 0);
	signal flt_oe_output: std_logic	:= '0';
	signal filter_toDac	:	std_logic_vector(15 downto 0);
	
	signal incrmt	: integer := 0;
	signal V_incr : std_logic_vector(19 downto 0);
	
	
 --FILTER
 COMPONENT filter
	PORT
	(
		CLOCK_50   		:	IN STD_LOGIC;
		FLT_OE_INPUT	:	IN STD_LOGIC;
		RCV_TOFILTER	:	IN STD_LOGIC_VECTOR(19 downto 0);
		FLT_OE_OUTPUT	:	OUT STD_LOGIC;		
		TSMT_TOANALOG	:	OUT STD_LOGIC_VECTOR(15 downto 0);
		SWITCH				:	IN STD_LOGIC_VECTOR(17 downto 0);
		HEX4Disp			: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX5Disp			: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		RESET_SIGNAL	:	IN STD_LOGIC
	);
 END COMPONENT;

 begin

 CLOCK_50 <= not CLOCK_50 after 10.0 ns;
 clock1k <= not clock1k after 40 ns;
 GPIO   <= ( others=>'Z' );
 reset_n <= '0', '1' after 97.0 ns;
 
	f_flt: entity work.filter(filter_mapBit)--filter_mapFct/filter_mapBit
		PORT MAP
		(
			CLOCK_50   		=> CLOCK_50,
			FLT_OE_INPUT	=> accel_enable,
			RCV_TOFILTER	=> accel_dataz,
			FLT_OE_OUTPUT	=> flt_oe_output,
			TSMT_TOANALOG	=> filter_toDac,
			SWITCH				=> 18x"1",
			HEX4Disp			=> tbHex4,
			HEX5Disp			=> tbHex5,
			RESET_SIGNAL	=> reset_n
		);
	
	-- st_machine: process (reset_all, TOP_CLOCK_50) is 
	-- begin
		-- FLT_OE_INPUT <= '1'
		-- RCV_TOFILTER <= mydata
		-- wait 1 ms;

	-- end process st_machine;
		
	st_m1k: process (clock1k) is
	begin
		if rising_edge(clock1k) then
			accel_enable <= '1';
			accel_dataz	 <= V_incr;
		else
			incrmt <= incrmt +1;
			V_incr <= std_logic_vector(to_signed(incrmt, accel_dataz'length));
		end if;
	end process st_m1k;
	
end arch;