--------------------------------------------------------------------------------------------------
-- Autor		:	ROMET Pierre
-- Date		:	19/03/2018
-- FileName :  LTC2668-16_beh.vhd
-- License  :	Code under license creative commun BY-SA, that define
--					Attribution :	Licensees may copy, distribute, display and perform 
--										the work and make derivative works and remixes based on it only if
--										they give the author or licensor the credits (attribution) in the 
--										manner specified by these.--					
--					Share-alink :	Licensees may distribute derivative works only under a license 
--										identical ("not more restrictive") to the license that governs the 
--										original work. (See also copyleft.) Without share-alike, derivative
--										works might be sublicensed with compatible but more restrictive
--										license clauses, e.g. CC BY to CC BY-NC.)
--------------------------------------------------------------------------------------------------

Library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.MATH_REAL.all;

entity LTC2668_16_beh is
	port
	(
		CLOCK_50		:	IN STD_LOGIC;
		LTC_SS		:	IN  STD_LOGIC;
		LTC_SCLK		:	IN STD_LOGIC;
		LTC_SDI		:	IN STD_LOGIC
	);
end entity;

architecture LTC_beh of LTC2668_16_beh is

 type   T_SPISTATE is ( UNSERIALst, TRANSMITst);
 signal cState     : T_SPISTATE;

 constant factor : integer := 16;
 signal d_out : std_logic_vector(15 downto 0);
 
 
 begin

 level_I : process (LTC_SS, LTC_SCLK) is
	
	variable cpt : integer :=0;
	variable tmp : integer :=0;
	variable tmp_I_out : integer := 0;
	variable buf : std_logic := '0';
	variable I_out : std_logic_vector(15 downto 0) := (others => 'Z');
	
	begin
	if LTC_SS = '1' then
		d_out <= (others => '0');
		cpt	:= 0;
		
	elsif rising_edge(LTC_SCLK) then
	
		if LTC_SDI /= 'Z' then
			for i in 1 to 15 loop
				d_out(0) <= LTC_SDI;
				d_out(i) <= d_out(i-1);
			end loop;
			
			cpt := cpt + 1;
			if cpt = 24 then
				tmp := to_integer(signed(d_out));
				tmp_I_out := factor * tmp;
				I_out := std_logic_vector(to_signed(tmp_I_out, 16));
			end if;
		end if;
	end if;
 end process level_I;

end LTC_beh;