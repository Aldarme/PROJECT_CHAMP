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
--	Filter - All amplitude data
--	Map with bit manipulation
--
----------------------------------------------------------------
architecture filter_mapBit of filter is
 
 signal offset : signed(16 downto 0) := 17x"08000";

 type   T_SPISTATE is ( IDLEst, Testst, CALIBst, Mapst, TRANSMITst);
 signal cState	: T_SPISTATE;
 
 signal tmp17b		: signed(16 downto 0);
 signal signedTmp	: signed(16 downto 0);
 
 
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
		inNumb	=> to_integer(unsigned(SWITCH)),
		reset		=> RESET_SIGNAL
	);
 
 
 flt: process(RESET_SIGNAL, CLOCK_50) is
  begin
	if RESET_SIGNAL = '0' then
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
				
				tmp17b <= shift_right(resize(signed(RCV_TOFILTER(19 downto 4)), tmp17b'length),to_integer(unsigned(SWITCH(3 downto 0))));
				cState 	<= CALIBst;
				
			when CALIBst	=>
				
				signedTmp <= tmp17b + offset;
				cState 	<= TRANSMITst;
				
			when TRANSMITst =>
				
				FLT_OE_OUTPUT <= '1';
				TSMT_TOANALOG <= std_logic_vector(unsigned(signedTmp(15 downto 0)));
				cState 	<= IDLEst;
				
			when others	=>
				cState <= IDLEst;
				
		end case;
	end if;
 end process flt;

end filter_mapBit;