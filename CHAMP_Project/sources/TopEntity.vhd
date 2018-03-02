-- Quartus II VHDL Template
-- Binary Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;

entity TopEntity is
	port
	(
		TOP_CLOCK_50:	IN STD_LOGIC;
		TOP_LEDG		:   OUT STD_LOGIC_VECTOR(8 DOWNTO 0); 
		TOP_LEDR		:   OUT STD_LOGIC_VECTOR(24 DOWNTO 0); 
		TOP_KEY 		:   IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
		TOP_GPIO		:   INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)
	);
end entity;

architecture topArchi of TopEntity is

 --ACCELEROMETER
 COMPONENT spi_accel
	PORT
	(
		CLOCK_50   	:   IN STD_LOGIC;		
		LEDG    		:   OUT STD_LOGIC_VECTOR(8 DOWNTO 0); 
		LEDR    		:   OUT STD_LOGIC_VECTOR(24 DOWNTO 0); 
		KEY    		:   IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
		GPIO    		:   INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		DATA_TODAC	:	 out STD_LOGIC_VECTOR(15 DOWNTO 0);
		DATA_ENABLE	:	 out STD_LOGIC
	);
  END COMPONENT;
  
 --FILTER
 COMPONENT filter
	PORT
	(
		CLOCK_50   		:  IN STD_LOGIC;
		FLT_OE_INPUT	:	INOUT STD_LOGIC;
		RCV_TOFILTER	:	INOUT STD_LOGIC_VECTOR( 15 downto 0);
		FLT_OE_OUTPUT	:	INOUT STD_LOGIC;		
		TSMT_TOANALOG	:  INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
 END COMPONENT;
 
 --DAC
 COMPONENT spi_DAC
	PORT
	(
		CLOCK_50   	:   IN STD_LOGIC;
		KEY    		:   IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		GPIO    		:   INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		RECV_DATA	:	 INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		DAC_OE_INOUT:	 IN STD_LOGIC;
		DAC_OE_OUTPUT:	 IN STD_LOGIC
	);
 END COMPONENT;
 
------------------ SIGNAL
	type   T_SPISTATE is (RESETst, WAITSt, TREATMENTst, TOANALOGst);
	signal cState     : T_SPISTATE;
 
	signal accel_dataz	:	std_logic_vector(15 downto 0);
	signal accel_enable	:	std_logic;
	
	signal flt_oe_input	:	std_logic;
	signal filter_dataz	:	std_logic_vector(15 downto 0);
	signal flt_oe_output	:	std_logic;
	signal filter_toDac	:	std_logic_vector(15 downto 0);	
	
	signal dac_dataz		:	std_logic_vector(15 downto 0);
	signal dac_oe_input	:	std_logic;
	signal dac_oe_output	:	std_logic;	
	
	signal reset_SM	:	STD_LOGIC;	
 
------------------ INSTANTIATION
 begin
 
 s_accel: spi_accel
	PORT MAP
	(
		CLOCK_50   	=>  TOP_CLOCK_50,	
		LEDG    		=>  TOP_LEDG,
		LEDR    		=>  TOP_LEDR,
		KEY    		=>  TOP_KEY,
		GPIO    		=>  TOP_GPIO,
		DATA_TODAC	=>  accel_dataz,
		DATA_ENABLE	=>	 accel_enable
	);
	
 f_flt: filter
	PORT MAP
	(
		CLOCK_50   		=> TOP_CLOCK_50,
		FLT_OE_INPUT	=> flt_oe_input,	--
		RCV_TOFILTER	=>	filter_dataz,	--
		FLT_OE_OUTPUT	=>	flt_oe_output,		
		TSMT_TOANALOG	=> filter_toDac
	);
	
 s_dac: spi_DAC
	PORT MAP
	(
		CLOCK_50   		=>	 TOP_CLOCK_50,
		KEY    			=>  TOP_KEY,
		GPIO    			=>  TOP_GPIO,
		RECV_DATA		=>	 dac_dataz,		--
		DAC_OE_INOUT	=>	 dac_oe_input,	--
		DAC_OE_OUTPUT	=>	 dac_oe_output
	);
 
------------------ PROCESS

 st_machine: process (reset_SM, TOP_CLOCK_50) is
 
 begin
	if reset_SM = '1' then
		--TODO
		
	elsif rising_edge(TOP_CLOCK_50) then
		case cState is
			
			when RESETst =>
			
				accel_enable	<= '0';
				accel_dataz		<= (others => '0');
				
				flt_oe_input	<= '0';	
				filter_dataz	<= (others => '0');
				flt_oe_output	<= '0';		
				filter_toDac	<= (others => '0');
				
				dac_oe_input	<= '0';	
				dac_dataz		<= (others => '0');
				dac_oe_output  <= '0';	
				cState <= WAITSt	;
				
			when WAITSt	=>
				if (accel_enable = '0') then
					cState <= WAITst;
				else
					filter_dataz <= accel_dataz;
					flt_oe_input <= accel_enable;
					cState <= TREATMENTst;
				end if;
			
			when TREATMENTst =>
				if flt_oe_input = '0' then
					cState <= TREATMENTst;
				else
					dac_dataz <= filter_toDac;
					dac_oe_input <= flt_oe_output;
					cState <= TOANALOGst;
				end if;
			
			when TOANALOGst =>
				if dac_oe_output = '0' then
					cState <= TOANALOGst;
				else
					cState <= WAITst;
				end if;
			
			when others	=>
				null;
		end case;
	end if;
 end process st_machine;
 
 
end topARchi;