-- Quartus II VHDL Template
-- Binary Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;
use work.PortAsArray.all;

entity GenEntity is
	port
	(
		TOP_CLOCK_50	:	IN STD_LOGIC;
		TOP_LEDG			:  OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		TOP_LEDR			:  OUT STD_LOGIC_VECTOR(24 DOWNTO 0);
		TOP_KEY 			:  IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
		TOP_GPIO			:  INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		TOP_HSMC			:	INOUT STD_LOGIC_VECTOR(15 downto 0)
	);
end entity;

architecture GenEntity of GenEntity is

-- ACCELEROMETER
 COMPONENT Gen_spi_accel
	PORT
	(
		CLOCK_50   		:  IN STD_LOGIC;
--	LEDG    			:  OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
--	LEDR    			:  OUT STD_LOGIC_VECTOR(24 DOWNTO 0);
--	KEY    				:  IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		GPIO_SPI_CLK	:	INOUT STD_LOGIC;
		GPIO_SPI_SS		:	INOUT STD_LOGIC;
		GPIO_SPI_SDIO	:	INOUT STD_LOGIC;
		DATA_TODAC		:	out STD_LOGIC_VECTOR(15 DOWNTO 0);
		DATA_ENABLE		:	out STD_LOGIC;
		RESET_SIGNAL	:	in STD_LOGIC
	);
  END COMPONENT;
  
-- FILTER
 COMPONENT Gen_filter
	PORT
	(
		CLOCK_50   		:  IN STD_LOGIC;
		FLT_OE_INPUT	:	IN STD_LOGIC;
		RCV_TOFILTER	:	IN STD_LOGIC_VECTOR( 15 downto 0);
		FLT_OE_OUTPUT	:	OUT STD_LOGIC;		
		TSMT_TOANALOG	:  OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		RESET_SIGNAL	:	IN STD_LOGIC
	);
 END COMPONENT;
 
-- DAC
 COMPONENT Gen_spi_DAC
	GENERIC
	(
		NBROFMODULE : INTEGER
	);
	PORT
	(
		CLOCK_50   		:  IN STD_LOGIC;
		KEY    				:  IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		GPIO_SPI_CLK	:	INOUT STD_LOGIC;
		GPIO_SPI_SS		:	INOUT STD_LOGIC;
		GPIO_SPI_SDIO	:	INOUT STD_LOGIC;
		RECV_DATA			:	IN INARRAY(0 to 11)(15 downto 0);
		DAC_OE_INPUT	:	IN INSTDARRAY(0 to 11);
		DAC_OE_OUTPUT	:	OUT STD_LOGIC;
		RESET_SIGNAL 	:	IN STD_LOGIC		
	);
 END COMPONENT;
 
------------------ SIGNAL -----------------------------------------------

	type   T_SPISTATE is (RESETst, WAITSt, TREATMENTst, TOANALOGst);
	signal cState0	: T_SPISTATE;
	signal cState1	: T_SPISTATE;
	signal cState2	: T_SPISTATE;
	signal cState3	: T_SPISTATE;
	signal cState4 	: T_SPISTATE;
	signal cState5 	: T_SPISTATE;
	signal cState6 	: T_SPISTATE;
	signal cState7 	: T_SPISTATE;
	signal cState8 	: T_SPISTATE;
	signal cState9 	: T_SPISTATE;
	signal cState10 : T_SPISTATE;
	signal cState11 : T_SPISTATE;
	
	
	constant nbrOfGenerate : integer := 12;
	
	type accel_dataz_tab is array (0 to nbrOfGenerate-1) of std_logic_vector(15 downto 0);
	type accel_oe_tab		is array (0 to nbrOfGenerate-1) of std_logic;
	
	signal accel_dataz	:	accel_dataz_tab;
	signal accel_oe		:	accel_oe_tab;
	
	signal flt_oe_output	: INSTDARRAY(0 to 11);
	signal filter_toDac	: INARRAY(0 to 11)(15 downto 0);
	
	signal dac_output	:	std_logic;
	
	signal reset_all	:	STD_LOGIC := '0';
 
------------------ INSTANTIATION -----------------------------------------------
 begin
 
 TOP_LEDG( 0 ) <= not TOP_KEY(0);
 TOP_LEDG( 3 ) <= not TOP_KEY(3);
 
 reset_all <= TOP_KEY(3);
 
 gen_module : for I in 0 to nbrOfGenerate-1 generate
	 
	s_accel: Gen_spi_accel
		PORT MAP
		(
			CLOCK_50   		=> TOP_CLOCK_50,
--		LEDG    			=> TOP_LEDG,
--		LEDR    			=> TOP_LEDR,
--		KEY    				=> TOP_KEY,
			GPIO_SPI_CLK	=> TOP_GPIO(3*I),
			GPIO_SPI_SS		=> TOP_GPIO((3*I)+1),
			GPIO_SPI_SDIO	=> TOP_GPIO((3*I)+2),
			DATA_TODAC		=> accel_dataz(I),
			DATA_ENABLE		=> accel_oe(I),
			RESET_SIGNAL	=> reset_all
		);

	f_flt: entity work.Gen_filter(filter_arch)
		PORT MAP
		(
			CLOCK_50   		=> TOP_CLOCK_50,
			FLT_OE_INPUT	=> accel_oe(I),
			RCV_TOFILTER	=> accel_dataz(I),
			FLT_OE_OUTPUT	=> flt_oe_output(I),
			TSMT_TOANALOG	=> filter_toDac(I),
			RESET_SIGNAL	=> reset_all
		);	
 end generate gen_module;
	
 s_dac: Gen_spi_DAC
	GENERIC MAP
	(
		NBROFMODULE => nbrOfGenerate
	)
	PORT MAP
	(
		CLOCK_50   		=> TOP_CLOCK_50,
		KEY    				=> TOP_KEY,
		GPIO_SPI_CLK	=> TOP_HSMC(0),	--Need to use HSMC connectors to have more GPIO
		GPIO_SPI_SS		=> TOP_HSMC(1),
		GPIO_SPI_SDIO	=> TOP_HSMC(2),
		RECV_DATA			=> filter_toDac,
		DAC_OE_INPUT	=> flt_oe_output,
		DAC_OE_OUTPUT	=>	dac_output,
		RESET_SIGNAL 	=>	reset_all		
	);
 
------------------ PROCESS -----------------------------------------------

 st_mach_0: process (reset_all, TOP_CLOCK_50) is
 
 begin
	if reset_all = '0' then
		
		cState0 <= RESETst;
		
	elsif rising_edge(TOP_CLOCK_50) then
		case cState0 is
			
			when RESETst =>
				
				cState0 <= WAITSt;
				
			when WAITSt	=>
				if (accel_oe(0) = '0') then
					cState0 <= WAITst;
				else
					cState0 <= TOANALOGst;
				end if;
			
			when TOANALOGst =>
				if dac_output = '0' then
					cState0 <= TOANALOGst;
				else
					cState0 <= WAITst;
				end if;
			
			when others	=>
				null;
		end case;
	end if;
 end process st_mach_0;
 
 st_mach_1: process (reset_all, TOP_CLOCK_50) is
 
 begin
	if reset_all = '0' then
		
		cState1 <= RESETst;
		
	elsif rising_edge(TOP_CLOCK_50) then
		case cState1 is
			
			when RESETst =>
				
				cState1 <= WAITSt;
				
			when WAITSt	=>
				if (accel_oe(1) = '0') then
					cState1 <= WAITst;
				else
					cState1 <= TOANALOGst;
				end if;
			
			when TOANALOGst =>
				if dac_output = '0' then
					cState1 <= TOANALOGst;
				else
					cState1 <= WAITst;
				end if;
			
			when others	=>
				null;
		end case;
	end if;
 end process st_mach_1;
 
 st_mach_2: process (reset_all, TOP_CLOCK_50) is
 
 begin
	if reset_all = '0' then
		
		cState2 <= RESETst;
		
	elsif rising_edge(TOP_CLOCK_50) then
		case cState2 is
			
			when RESETst =>
				
				cState2 <= WAITSt;
				
			when WAITSt	=>
				if (accel_oe(2) = '0') then
					cState2 <= WAITst;
				else
					cState2 <= TOANALOGst;
				end if;
			
			when TOANALOGst =>
				if dac_output = '0' then
					cState2 <= TOANALOGst;
				else
					cState2 <= WAITst;
				end if;
			
			when others	=>
				null;
		end case;
	end if;
 end process st_mach_2;
 
 st_mach_3: process (reset_all, TOP_CLOCK_50) is
 
 begin
	if reset_all = '0' then
		
		cState3 <= RESETst;
		
	elsif rising_edge(TOP_CLOCK_50) then
		case cState3 is
			
			when RESETst =>
				
				cState3 <= WAITSt;
				
			when WAITSt	=>
				if (accel_oe(3) = '0') then
					cState3 <= WAITst;
				else
					cState3 <= TOANALOGst;
				end if;
			
			when TOANALOGst =>
				if dac_output = '0' then
					cState3 <= TOANALOGst;
				else
					cState3 <= WAITst;
				end if;
			
			when others	=>
				null;
		end case;
	end if;
 end process st_mach_3;
 
 st_mach_4: process (reset_all, TOP_CLOCK_50) is
 
 begin
	if reset_all = '0' then
		
		cState4 <= RESETst;
		
	elsif rising_edge(TOP_CLOCK_50) then
		case cState4 is
			
			when RESETst =>
				
				cState4 <= WAITSt;
				
			when WAITSt	=>
				if (accel_oe(4) = '0') then
					cState4 <= WAITst;
				else
					cState4 <= TOANALOGst;
				end if;
			
			when TOANALOGst =>
				if dac_output = '0' then
					cState4 <= TOANALOGst;
				else
					cState4 <= WAITst;
				end if;
			
			when others	=>
				null;
		end case;
	end if;
 end process st_mach_4;
 
 st_mach_5: process (reset_all, TOP_CLOCK_50) is
 
 begin
	if reset_all = '0' then
		
		cState5 <= RESETst;
		
	elsif rising_edge(TOP_CLOCK_50) then
		case cState5 is
			
			when RESETst =>
				
				cState5 <= WAITSt;
				
			when WAITSt	=>
				if (accel_oe(5) = '0') then
					cState5 <= WAITst;
				else
					cState5 <= TOANALOGst;
				end if;
			
			when TOANALOGst =>
				if dac_output = '0' then
					cState5 <= TOANALOGst;
				else
					cState5 <= WAITst;
				end if;
			
			when others	=>
				null;
		end case;
	end if;
 end process st_mach_5;
 
 st_mach_6: process (reset_all, TOP_CLOCK_50) is
 
 begin
	if reset_all = '0' then
		
		cState6 <= RESETst;
		
	elsif rising_edge(TOP_CLOCK_50) then
		case cState6 is
			
			when RESETst =>
				
				cState6 <= WAITSt;
				
			when WAITSt	=>
				if (accel_oe(6) = '0') then
					cState6 <= WAITst;
				else
					cState6 <= TOANALOGst;
				end if;
			
			when TOANALOGst =>
				if dac_output = '0' then
					cState6 <= TOANALOGst;
				else
					cState6 <= WAITst;
				end if;
			
			when others	=>
				null;
		end case;
	end if;
 end process st_mach_6;
 
 st_mach_7: process (reset_all, TOP_CLOCK_50) is
 
 begin
	if reset_all = '0' then
		
		cState7 <= RESETst;
		
	elsif rising_edge(TOP_CLOCK_50) then
		case cState7 is
			
			when RESETst =>
				
				cState7 <= WAITSt;
				
			when WAITSt	=>
				if (accel_oe(7) = '0') then
					cState7 <= WAITst;
				else
					cState7 <= TOANALOGst;
				end if;
			
			when TOANALOGst =>
				if dac_output = '0' then
					cState7 <= TOANALOGst;
				else
					cState7 <= WAITst;
				end if;
			
			when others	=>
				null;
		end case;
	end if;
 end process st_mach_7;
 
 st_mach_8: process (reset_all, TOP_CLOCK_50) is
 
 begin
	if reset_all = '0' then
		
		cState8 <= RESETst;
		
	elsif rising_edge(TOP_CLOCK_50) then
		case cState8 is
			
			when RESETst =>
				
				cState8 <= WAITSt;
				
			when WAITSt	=>
				if (accel_oe(8) = '0') then
					cState8 <= WAITst;
				else
					cState8 <= TOANALOGst;
				end if;
			
			when TOANALOGst =>
				if dac_output = '0' then
					cState8 <= TOANALOGst;
				else
					cState8 <= WAITst;
				end if;
			
			when others	=>
				null;
		end case;
	end if;
 end process st_mach_8;
 
 st_mach_9: process (reset_all, TOP_CLOCK_50) is
 
 begin
	if reset_all = '0' then
		
		cState9 <= RESETst;
		
	elsif rising_edge(TOP_CLOCK_50) then
		case cState9 is
			
			when RESETst =>
				
				cState9 <= WAITSt;
				
			when WAITSt	=>
				if (accel_oe(9) = '0') then
					cState9 <= WAITst;
				else
					cState9 <= TOANALOGst;
				end if;
			
			when TOANALOGst =>
				if dac_output = '0' then
					cState9 <= TOANALOGst;
				else
					cState9 <= WAITst;
				end if;
			
			when others	=>
				null;
		end case;
	end if;
 end process st_mach_9;
 
 st_mach_10: process (reset_all, TOP_CLOCK_50) is
 
 begin
	if reset_all = '0' then
		
		cState10 <= RESETst;
		
	elsif rising_edge(TOP_CLOCK_50) then
		case cState10 is
			
			when RESETst =>
				
				cState10 <= WAITSt;
				
			when WAITSt	=>
				if (accel_oe(10) = '0') then
					cState10 <= WAITst;
				else
					cState10 <= TOANALOGst;
				end if;
			
			when TOANALOGst =>
				if dac_output = '0' then
					cState10 <= TOANALOGst;
				else
					cState10 <= WAITst;
				end if;
			
			when others	=>
				null;
		end case;
	end if;
 end process st_mach_10;
 
 st_mach_11: process (reset_all, TOP_CLOCK_50) is
 
 begin
	if reset_all = '0' then
		
		cState11 <= RESETst;
		
	elsif rising_edge(TOP_CLOCK_50) then
		case cState11 is
			
			when RESETst =>
				
				cState11 <= WAITSt;
				
			when WAITSt	=>
				if (accel_oe(11) = '0') then
					cState11 <= WAITst;
				else
					cState11 <= TOANALOGst;
				end if;
			
			when TOANALOGst =>
				if dac_output = '0' then
					cState11 <= TOANALOGst;
				else
					cState11 <= WAITst;
				end if;
			
			when others	=>
				null;
		end case;
	end if;
 end process st_mach_11;
 
end GenEntity;