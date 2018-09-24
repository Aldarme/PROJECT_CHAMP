----------------------------------------------------------------------
--																																	--
-- TestBench to simulate filter & SPI_DAC module to validate:				--
--	> full time acceleration average & delete of this acc. average	--
--	> acceleration integration & data send to SPI_DAC								--
--	> speed integration & data sent to SPI_DAC											--
--																																	--
-- Author : ROMET Pierre - September 2018														--
--																																	--
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_accSpeedPos is
end entity;

Architecture arch_tb of tb_accSpeedPos is

	signal clock50_stub	: std_logic;
	signal clock1k_stub	: std_logic;
	signal flt_oe_stub	: std_logic;
	signal flt_data_stub: std_logic_vector(19 downto 0);
	signal tsmt_stub		: std_logic_vector(15 downto 0);
	signal spd_oe_stub	: std_logic;
	signal spd_out_stub	:	std_logic_vector(15 downto 0);
	signal spd_cnt_stub	:	integer;
	signal pos_oe_stub	: std_logic;
	signal pos_data_stub: std_logic_vector(15 downto 0);
	signal pos_cnt_stub	: integer;
	signal sw_stub			:	std_logic_vector(17 downto 0);
	signal hex4_stub		: std_logic_vector(6 downto 0);
	signal hex5_stub		: std_logic_vector(6 downto 0);
	signal reset_stub		:	std_logic;
	
	type T_STATE is (IDLEst, INCREMTst);
	signal stbState : T_STATE;
	
	component filter
		port
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
	end component;
	
	begin
	
	clock50_stub 	<= not clock50_stub after 10 ns;		-- system clock
	clock1k_stub	<= not clock1k_stub after 1  ms;		-- freq. of 1KHz allow to simulate data rate of acceleromter
	sw_stub				<= (others => '0');
	reset_stub		<= '0', '1' after 97.0 ns;
	
	flt: filter
		port map
		(
			CLOCK_50   		=> clock50_stub,
			FLT_OE_INPUT	=> flt_oe_stub,
			RCV_TOFILTER	=> flt_data_stub,
			FLT_OE_OUTPUT	=> flt_oe_stub,
			TSMT_TOANALOG	=> tsmt_stub,
			SPD_OE_OUTPUT	=> spd_oe_stub,
			SPD_OUTPUT		=> spd_out_stub,
			SPD_COUNT			=> spd_cnt_stub,
			POS_OE_OUTPUT	=> pos_oe_stub,
			POS_OUTPUT		=> pos_data_stub,
			POS_COUNT			=> pos_cnt_stub,
			SWITCH				=> sw_stub,
			HEX4Disp			=> hex4_stub,
			HEX5Disp			=> hex5_stub,
			RESET_SIGNAL	=> reset_stub
		);
		
	IncrmtStub: process(reset_stub, clock1k_stub) is
		begin
			if reset_stub = '0' then
				
				flt_oe_stub 	<= '0';
				flt_data_stub	<= (others => '0');
				
				stbState <= IDLEst;
				
			elsif rising_edge(clock1k_stub) then
				
				case stbState is
					
					when IDLEst =>
						
						flt_oe_stub <= '1';
						stbState <= INCREMTst;
						
					when INCREMTst =>
						
						flt_data_stub <= std_logic_vector(to_signed(to_integer(signed(flt_data_stub)) + 1, flt_data_stub'length));
						stbState <= IDLEst;
						
					when others =>
						stbState <= IDLEst;
				end case;			
			end if;
	end process IncrmtStub;
	
end arch_tb;