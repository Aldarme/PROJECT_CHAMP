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
	
END ENTITY;

----------------------------------------------------------------
--
--	Filter
--	Return input
--
----------------------------------------------------------------
architecture trivial_ftl of filter is
 type   T_SPISTATE is ( RESETst, WAITst, TREATMENTst);
 signal cState     : T_SPISTATE;
 
 signal reset  :  std_logic;
 
 begin
 
 flt: process(RESET_SIGNAL, CLOCK_50) is
  begin
  if RESET_SIGNAL = '0' then
    FLT_OE_OUTPUT <= '0';
    cState <= WAITst;
    
  elsif rising_edge(CLOCK_50) then
    case cstate is
		
      when WAITst    =>
        FLT_OE_OUTPUT <= '0';
        if(FLT_OE_INPUT = '0') then
          cState <= WAITst;
        else
          cState <= TREATMENTst;
        end if;
      
      when TREATMENTst =>        
        TSMT_TOANALOG <= RCV_TOFILTER(19 downto 4);
        FLT_OE_OUTPUT <= '1';
        cState <= WAITst;
      
      when others  =>
        cState <= WAITst;
        
    end case;
  end if;
 end process flt;


end trivial_ftl;

----------------------------------------------------------------
--
--	Filter
--	Return positive value & sup to 1g from accéléro
--
----------------------------------------------------------------
architecture filter_arch of filter is

 constant G 			: integer := 131072;	--131071
 constant in_min	: integer := 0;				
 constant in_max	: integer := 1048575;	--19 bits at '1';
 constant out_min	: integer := 0;
 constant out_max	: integer := 65535;		--15 bits at '1';

 type   T_SPISTATE is ( IDLEst, Testst, CALIBst, Mapst, TRANSMITst);
 signal cState	: T_SPISTATE;
 
 signal tmpData : integer;
 
 component HexDisplay
	port
	(
		hex_4		: out	std_logic_vector(6 downto 0);
		hex_5		: out	std_logic_vector(6 downto 0);
		inNumb	: in	integer;
		reset		: in std_logic
	);
 end component;
 
 begin
 
 sevDisp : HexDisplay
	port map
	(
		hex_4		=> HEX4Disp,
		hex_5		=> HEX5Disp,
		inNumb	=> to_integer(signed(SWITCH)),
		reset		=> RESET_SIGNAL
	);
 
 
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
					--tmpData <= to_integer(signed(RCV_TOFILTER)) - G;
					tmpData <= to_integer(signed(RCV_TOFILTER));
					cState	<= CALIBst;
				end if;
				
			when CALIBst	=>
				
				if tmpData < 0 then
					cState <= IDLEst;
				else
					if to_integer(signed(SWITCH)) = 0 then
						cState <= IDLEst;
					else
						tmpData <= tmpData / to_integer(signed(SWITCH));
						cState <= MAPst;
					end if;
					
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

