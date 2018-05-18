-- Quartus II VHDL Template
-- Binary Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;

entity filter is
	PORT
	(
		CLOCK_50   		: IN STD_LOGIC;
		FLT_OE_INPUT	:	IN STD_LOGIC;
		RCV_TOFILTER	:	IN STD_LOGIC_VECTOR(19 downto 0);
		FLT_OE_OUTPUT	:	OUT STD_LOGIC;		
		TSMT_TOANALOG	: OUT STD_LOGIC_VECTOR(15 downto 0);
		RESET_SIGNAL	:	IN STD_LOGIC
	);
	
END ENTITY;

----------------------------------------------------------------
--
-- test archi
--	return the input filter
--
----------------------------------------------------------------
architecture filter_arch of filter is

 constant G 			: integer := 131072;
 constant in_min	: integer := 0;
 constant in_max	: integer := 1048575;	--19 bits at '1';
 constant out_min	: integer := 0;
 constant out_max	: integer := 65536;		--15 bits at '1';

 type   T_SPISTATE is ( IDLEst, Testst, CALIBst, Mapst, TRANSMITst);
 signal cState	: T_SPISTATE;
 
 signal tmpData : integer;
 
 begin
 
 flt: process(RESET_SIGNAL, CLOCK_50) is
  begin
	if RESET_SIGNAL = '0' then
		tmpData <= 0;
		FLT_OE_OUTPUT <= '0';
		cState <= IDLEst;
		
	elsif rising_edge(CLOCK_50) then
		
		case cstate is
			
			when IDLEst		=>
				
				FLT_OE_OUTPUT <= '0';
				
				if(FLT_OE_INPUT = '0') then
					cState <= IDLEst;
				else
					cState 	<= Testst;
				end if;
				
			when Testst =>
				
				if RCV_TOFILTER(19) = '1' then
					cState <= IDLEst;
				else
					tmpData <= to_integer(signed(RCV_TOFILTER)) - G;
					cState	<= CALIBst;
				end if;
				
			when CALIBst	=>
				
				if tmpData < 0 then
					cState <= IDLEst;
				else
					cState <= MAPst;
				end if;
				
			when Mapst =>
				
				tmpData <= (tmpData - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
				cState	<= TrANSMITst;
				
			when TRANSMITst =>
				
				TSMT_TOANALOG <= std_logic_vector(to_signed(tmpData, TSMT_TOANALOG'length));
				FLT_OE_OUTPUT <= '1';
				cState	<= IDLEst;
				
			when others	=>
				cState <= IDLEst;
				
		end case;
	end if;
 end process flt;

end filter_arch;

-----------------------------------------------
--
-- Average filter
--
-----------------------------------------------
--architecture filter_arch of filter_avg is
--
-- constant G : integer := 10;
--
-- type   T_SPISTATE is ( IDLEst, STCKst, AVGst, CALIBst, RGHTSHIFTst, SLIDINGst, TRANSMITst);
-- signal cState	: T_SPISTATE;
-- 
-- type		myArray is array (0 to 2) of std_logic_vector(23 downto 0);
-- signal myStock : myArray;
-- 
-- signal reset		:	std_logic;
-- signal cptData : integer;
-- signal average	:	signed(23 downto 0);
-- signal tmpData : std_logic_vector(23 downto 0);
-- 
-- begin
-- 
-- reset <= RESET_SIGNAL;
-- 
-- flt: process(reset, CLOCK_50) is
--  begin
--	if reset = '0' then
--	
--		FLT_OE_OUTPUT <= '0';
--		cptData				<= 0;
--		tmpData				<= (others => '0');		
--		cState <= IDLEst;
--		
--	elsif rising_edge(CLOCK_50) then
--		
--		case cstate is
--			
--			when IDLEst		=>
--				
--				FLT_OE_OUTPUT <= '0';
--				if(FLT_OE_INPUT = '0') then
--					cState <= STCKst;
--				else
--					cState 	<= RGHTSHIFTst;
--				end if;
--				
--			when STCKst =>
--				
--				myStock(cptData) <= RCV_TOFILTER;
--				if cptData < 2 then
--					cptData <= cptData +1;
--					cState	<= IDLEst;
--				else
--					cptData <= 0;
--					cState	<= AVGst;
--				end if;				
--				
--			when AVGst =>				
--				
--				average <= (signed(myStock(0)) + signed(myStock(1)) + signed(myStock(2)))/3 ;
--				cState	<= RGHTSHIFTst;
--				
--			when CALIBst	=>
--				
--				tmpData <= std_logic_vector(average - G);
--				
--			when RGHTSHIFTst =>
--				
--				tmpData <= std_logic_vector(shift_right(signed(RCV_TOFILTER), 2));
--				cState	<= SLIDINGst;
--				
--			when SLIDINGst =>
--				
--				tmpData <= std_logic_vector(signed(tmpData)+32768);
--				cState	<= TRANSMITst;
--				
--			when TRANSMITst =>
--				
--				TSMT_TOANALOG <= tmpData;
--				FLT_OE_OUTPUT <= '1';
--				cState <= IDLEst;
--				
--			when others	=>
--				cState <= IDLEst;
--				
--		end case;
--	end if;
-- end process flt;
--
--end filter_arch;






