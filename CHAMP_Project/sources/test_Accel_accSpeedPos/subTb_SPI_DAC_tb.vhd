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

entity subTb_SPI_DAC_tb is
end entity;

Architecture arch_tb of subTb_SPI_DAC_tb is

	signal clock50_stub	: std_logic := '0';
	signal clock1k_stub	: std_logic := '1';
	signal key_stub			: std_logic_vector(3 downto 0);
	signal gpio_stub		: std_logic_vector(35 downto 0);
	signal acc_oe_stub	: std_logic;
	signal acc_in_stub	: std_logic_vector(15 downto 0);
	signal spd_oe_stub	: std_logic;
	signal spd_in_stub	:	std_logic_vector(15 downto 0); 
	signal pos_oe_stub	: std_logic;
	signal pos_in_stub	: std_logic_vector(15 downto 0);
	signal dac_oeO_stub	: std_logic;
	signal reset_stub		:	std_logic;
	
	
	
	type T_STATE is (IDLEst, INCREMTst);
	signal stbState : T_STATE;
		
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
	clock1k_stub	<= not clock1k_stub after 500000 ns;		-- freq. of 1KHz allow to simulate data rate of acceleromter
	reset_stub		<= '0', '1' after 97.0 ns;
	
	asp_spiD: ASP_spi_DAC
		port map
		(
			CLOCK_50   		=> clock50_stub,
			KEY    				=> key_stub,
			GPIO_SPI_CLK	=> gpio_stub(0),
			GPIO_SPI_SS		=> gpio_stub(1),
			GPIO_SPI_SDIO	=> gpio_stub(2),
			RECV_DATA			=> acc_in_stub,
			DAC_OE_INPUT	=> acc_oe_stub,
			DAC_SPEED_DATA=> spd_in_stub,
			DAC_SPD_OE_IN	=> spd_oe_stub,
			DAC_POS_DATA	=> pos_in_stub,
			DAC_POS_OE_IN	=> pos_oe_stub,
			DAC_OE_OUTPUT	=> dac_oeO_stub,
			RESET_SIGNAL 	=> reset_stub
		);
		
	IncrmtStub: process(reset_stub, clock50_stub) is
		begin
			if reset_stub = '0' then
				
				acc_oe_stub <= '0';
				spd_oe_stub	<= '0';
				pos_oe_stub	<= '0';
				acc_in_stub	<= (others => '0');
				spd_in_stub	<= (others => '0');
				pos_in_stub	<= (others => '0');
				
				stbState <= IDLEst;
				
			elsif rising_edge(clock50_stub) or falling_edge(clock50_stub)then            
				
				case stbState is
					
					when IDLEst =>
							
						if clock1k_stub'event AND clock1k_stub = '1' then
							acc_oe_stub <= '1';
							spd_oe_stub	<= '1';
							pos_oe_stub	<= '1';
							stbState <= INCREMTst;
						else
							stbState <= IDLEst;
						end if;
							
					when INCREMTst =>
							
						acc_in_stub <= std_logic_vector(to_signed(to_integer(signed(acc_in_stub)) + 1, acc_in_stub'length));
						spd_in_stub	<= std_logic_vector(to_signed(to_integer(signed(spd_in_stub)) + 1, spd_in_stub'length));
						pos_in_stub	<= std_logic_vector(to_signed(to_integer(signed(pos_in_stub)) + 1, pos_in_stub'length));
						acc_oe_stub <= '0';
						spd_oe_stub	<= '0';
						pos_oe_stub	<= '0';
						
						stbState <= IDLEst;
							
					when others =>
						stbState <= IDLEst;
				end case;			
			end if;
	end process IncrmtStub;
	
end arch_tb;