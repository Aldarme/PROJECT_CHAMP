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
 
 constant positive_in_min		: integer := 0;				
 constant positive_in_max		: integer := 1048575;
 constant negative_in_min		: integer := 2097151;
 constant negative_in_max		: integer := 1048576;
 
 constant positive_out_max	: integer := 65535;
 constant positive_out_min	: integer := 32768;
 constant negative_out_max	: integer := 32767;
 constant negative_out_min	: integer := 0;
 

 type   T_SPISTATE is ( IDLEst, Testst, CALIBst, Mapst, TRANSMITst);
 signal cState	: T_SPISTATE;
 
 signal tmpData : integer;
 signal tmpArray: signed(15 downto 0);
 
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
				
				if RCV_TOFILTER(19) = '0' then
					
					tmpData <= ( to_integer(unsigned(RCV_TOFILTER)) - positive_in_min) * (positive_out_max - positive_out_min)	/ (positive_in_max - positive_in_min) + positive_out_min;
					
				else
					
					tmpData <= ( to_integer(unsigned(RCV_TOFILTER)) - negative_in_min) * (negative_out_max - negative_out_min)	/ (negative_in_max - negative_in_min) + negative_out_min;
					
				end if;
				
				cState	<= CALIBst;
				
			when CALIBst	=>
			
				if to_integer(unsigned(SWITCH)) = 0 then
					cState <= IDLEst;
				else
					tmpArray <= shift_right( signed( std_logic_vector( to_signed(tmpData, tmpArray'length) ) ) ,to_integer(unsigned(SWITCH)));
					cState <= TRANSMITst;
				end if;
				
			when TRANSMITst =>
				
				TSMT_TOANALOG <= std_logic_vector(tmpArray);
				FLT_OE_OUTPUT <= '1';
				cState	<= IDLEst;
				
			when others	=>
				cState <= IDLEst;
				
		end case;
	end if;
 end process flt;

end filter_arch;

