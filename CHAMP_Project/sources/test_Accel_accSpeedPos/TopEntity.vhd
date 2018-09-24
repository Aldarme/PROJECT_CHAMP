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
		TOP_LEDG		:	OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		TOP_LEDR		:	OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		TOP_KEY 		:	IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
		TOP_GPIO		:	INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		SW					: IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		HEX4				: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX5				: OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
end entity;

architecture topArchi of TopEntity is

 --ACCELEROMETER
 COMPONENT spi_accel
	PORT
	(
		CLOCK_50   		:	IN STD_LOGIC;
		LEDG    			:	OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		LEDR    			:	OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		KEY    				:	IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		GPIO_SPI_CLK	:	INOUT STD_LOGIC;
		GPIO_SPI_SS		:	INOUT STD_LOGIC;
		GPIO_SPI_SDIO	:	INOUT STD_LOGIC;
		DATA_OUT			:	out STD_LOGIC_VECTOR(19 DOWNTO 0);
		DATA_ENABLE		:	out STD_LOGIC;
		RESET_SIGNAL	:	in STD_LOGIC
	);
  END COMPONENT;
  
 --FILTER
 COMPONENT filter
	PORT
	(
		CLOCK_50   		:	IN	STD_LOGIC;
		FLT_OE_INPUT	:	IN 	STD_LOGIC;
		RCV_TOFILTER	:	IN 	STD_LOGIC_VECTOR(19 DOWNTO 0);
		FLT_OE_OUTPUT	:	OUT STD_LOGIC;		
		TSMT_TOANALOG	:	OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		SPD_OE_OUTPUT	: OUT STD_LOGIC;
		SPD_OUTPUT		:	OUT STD_LOGIC_VECTOR(15 DOWNTO 0);		-- Speed data, obtain by integration of acceleration
		SPD_COUNT			: OUT INTEGER;													-- Store the number of integration of acceleration since the beginning
		POS_OE_OUTPUT	:	OUT STD_LOGIC;
		POS_OUTPUT		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);		-- Position data, obtain by itegration of acceleration
		POS_COUNT			: OUT INTEGER;
		SWITCH				:	IN 	STD_LOGIC_VECTOR(17 DOWNTO 0);
		HEX4Disp			: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX5Disp			: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		RESET_SIGNAL	:	IN 	STD_LOGIC
	);
 END COMPONENT;
 
 --DAC
 COMPONENT spi_DAC
	PORT
	(
		CLOCK_50   		: IN STD_LOGIC;
		KEY    				: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		GPIO_SPI_CLK	:	INOUT STD_LOGIC;
		GPIO_SPI_SS		:	INOUT STD_LOGIC;
		GPIO_SPI_SDIO	:	INOUT STD_LOGIC;
		RECV_DATA			:	IN STD_LOGIC_VECTOR(15 DOWNTO 0);		-- acceleration data supply by filter
		DAC_OE_INPUT	:	IN STD_LOGIC;												-- acceleration data oenable input
		DAC_SPEED_DATA: IN STD_LOGIC_VECTOR(15 DOWNTO 0);		-- speed data supply by filter
		DAC_SPD_OE_IN	: IN STD_LOGIC;												-- speed data oenable input
		DAC_POS_DATA	: IN STD_LOGIC_VECTOR(15 downto 0);		-- position data supply by filter
		DAC_POS_OE_IN	: IN STD_LOGIC;												-- position data oenable input
		DAC_OE_OUTPUT	:	OUT STD_LOGIC;
		RESET_SIGNAL 	:	IN STD_LOGIC
	);
 END COMPONENT;
 
------------------ SIGNAL ---------------------------------------------

	type   T_SPISTATE is (RESETst, WAITSt, TREATMENTst, TOANALOGst);
	signal cState : T_SPISTATE;
 
	signal accel_dataz		:	std_logic_vector(19 downto 0);
	signal accel_enable		:	std_logic;
	
	signal flt_oe_output	:	std_logic;
	signal filter_toDac		:	std_logic_vector(15 downto 0);
	signal flt_spd_oe_out	: std_logic;
	signal flt_spd_out 		: std_logic_vector(15 downto 0);
	signal flt_std_cnt		: integer;
	signal flt_pos_oe_out	: std_logic;
	signal flt_pos_out		: std_logic_vector(15 downto 0);
	signal flt_pos_cnt		: integer;
	
	signal dac_output			:	std_logic;
	
	signal reset_all			:	STD_LOGIC := '0';
 
------------------ INSTANTIATION
 begin
 
reset_all <= TOP_KEY(3);
 
 s_accel: spi_accel
	PORT MAP
	(
		CLOCK_50   		=> TOP_CLOCK_50,
		LEDG    			=> TOP_LEDG,
		LEDR    			=> TOP_LEDR,
		KEY    				=> TOP_KEY,
		GPIO_SPI_CLK	=> TOP_GPIO(31),
		GPIO_SPI_SS		=> TOP_GPIO(33),
		GPIO_SPI_SDIO	=> TOP_GPIO(29),
		DATA_OUT			=> accel_dataz,
		DATA_ENABLE		=> accel_enable,
		RESET_SIGNAL	=> reset_all
	);

 f_flt: entity work.filter(filter_mapBitAvrgANDInteg)
	PORT MAP
	(
		CLOCK_50   		=> TOP_CLOCK_50,
		FLT_OE_INPUT	=> accel_enable,
		RCV_TOFILTER	=> accel_dataz,
		FLT_OE_OUTPUT	=> flt_oe_output,
		TSMT_TOANALOG	=> filter_toDac,
		SPD_OE_OUTPUT	=> flt_spd_oe_out,
		SPD_OUTPUT		=> flt_spd_out,						-- Speed data, obtain by integration of acceleration
		SPD_COUNT			=> flt_std_cnt,						-- Store the number of integration of acceleration since the beginning
		POS_OE_OUTPUT	=> flt_pos_oe_out,
		POS_OUTPUT		=> flt_pos_out,						-- Position data, obtain by integration of acceleration
		POS_COUNT			=> flt_pos_cnt,
		SWITCH				=> SW,
		HEX4Disp			=> HEX4,
		HEX5Disp			=> HEX5,
		RESET_SIGNAL	=> reset_all
	);
	
 s_dac: entity work.spi_DAC(dac_IPFifo)
	PORT MAP
	(
		CLOCK_50   			=> TOP_CLOCK_50,
		KEY    					=> TOP_KEY,
		GPIO_SPI_CLK		=> TOP_GPIO(5),
		GPIO_SPI_SS			=> TOP_GPIO(3),
		GPIO_SPI_SDIO		=> TOP_GPIO(1),
		RECV_DATA				=> filter_toDac,				-- acceleration data supply by filter
		DAC_OE_INPUT		=> flt_oe_output,				-- acceleration data oenable input
		DAC_SPEED_DATA	=> flt_spd_out,					-- speed data supply by filter
		DAC_SPD_OE_IN		=> flt_spd_oe_out,			-- speed data oenable input
		DAC_POS_DATA		=> flt_pos_out,					-- position data supply by filter
		DAC_POS_OE_IN		=> flt_pos_oe_out,			-- position data oenable input
		DAC_OE_OUTPUT		=> dac_output,
		RESET_SIGNAL 		=> reset_all
	);
 
------------------ PROCESS

 st_machine: process (reset_all, TOP_CLOCK_50) is
 
 begin
	if reset_all = '0' then
		
		cState <= RESETst;
		
	elsif rising_edge(TOP_CLOCK_50) then
		case cState is
			
			when RESETst =>
				
				cState <= WAITSt;
				
			when WAITSt	=>
				if (accel_enable = '0') then
					cState <= WAITst;
				else
					cState <= TOANALOGst;
				end if;
			
			when TOANALOGst =>
				if dac_output = '0' then
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