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

entity accSpeedPos_tb is
end entity;

Architecture arch_tb of accSpeedPos_tb is

	signal clock50_stub	: std_logic := '0';
	signal clock1k_stub	: std_logic := '1';
	signal flt_oeI_stub	: std_logic;
	signal flt_oeO_stub	: std_logic;
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
	signal key_stub			: std_logic_vector(3 downto 0);
	signal gpio_stub		: std_logic_vector(35 downto 0);
	signal dac_oeO_stub	: std_logic;
	
	type T_STATE is (IDLEst, INCREMTst);
	signal stbState : T_STATE;
	
	component ASP_filter
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
		
	component ASP_spi_DAC
		port
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
	end component;
	
	begin
	
	clock50_stub 	<= not clock50_stub after 10 ns;		-- system clock
	clock1k_stub	<= not clock1k_stub after 50000 ns;	-- freq. of 1KHz allow to simulate data rate of acceleromter, but need to accelerate freq to have a shorter simulation time (period of 0.1 ms). 
	sw_stub				<= (others => '0');
	reset_stub		<= '0', '1' after 97.0 ns;
	
	asp_flt: ASP_filter
		port map
		(
			CLOCK_50   		=> clock50_stub,
			FLT_OE_INPUT	=> flt_oeI_stub,
			RCV_TOFILTER	=> flt_data_stub,
			FLT_OE_OUTPUT	=> flt_oeO_stub,
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
		
	asp_spiD: ASP_spi_DAC
		port map
		(
			CLOCK_50   		=> clock50_stub,
			KEY    				=> key_stub,
			GPIO_SPI_CLK	=> gpio_stub(0),
			GPIO_SPI_SS		=> gpio_stub(1),
			GPIO_SPI_SDIO	=> gpio_stub(2),
			RECV_DATA			=> tsmt_stub,
			DAC_OE_INPUT	=> flt_oeO_stub,
			DAC_SPEED_DATA=> spd_out_stub,
			DAC_SPD_OE_IN	=> spd_oe_stub,
			DAC_POS_DATA	=> pos_data_stub,
			DAC_POS_OE_IN	=> pos_oe_stub,
			DAC_OE_OUTPUT	=> dac_oeO_stub,
			RESET_SIGNAL 	=> reset_stub
		);
		
	IncrmtStub: process(reset_stub, clock50_stub) is
		begin
			if reset_stub = '0' then
				
				flt_oeI_stub 	<= '0';
				flt_data_stub	<= (others => '0');
				
				stbState <= IDLEst;
				
			elsif rising_edge(clock50_stub) or falling_edge(clock50_stub)then            
				
				case stbState is
					
					when IDLEst =>
							
						if clock1k_stub'event AND clock1k_stub = '1' then
							flt_oeI_stub <= '1';
							stbState <= INCREMTst;
						else
							stbState <= IDLEst;
						end if;
							
					when INCREMTst =>
							
						flt_data_stub <= std_logic_vector(to_signed(to_integer(signed(flt_data_stub)) + 1, flt_data_stub'length));
						flt_oeI_stub <= '0';
						stbState <= IDLEst;
							
					when others =>
						stbState <= IDLEst;
				end case;			
			end if;
	end process IncrmtStub;
	
end arch_tb;