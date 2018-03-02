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
		CLOCK_50   		:  IN STD_LOGIC;
		FLT_OE_INPUT	:	INOUT STD_LOGIC;
		RCV_TOFILTER	:	INOUT STD_LOGIC_VECTOR( 15 downto 0);
		FLT_OE_OUTPUT	:	INOUT STD_LOGIC;		
		TSMT_TOANALOG	:  INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		--add reset signal
	);
	
END ENTITY;

architecture filter_arch of filter is

 type   T_SPISTATE is ( RESETst, WAITst, TREATMENTst);
 signal cState     : T_SPISTATE;

 type    T_WORD_ARR is array (natural range <>) of std_logic_vector;
 signal reset	:	std_logic := '0';
 
 signal tmp : std_logic_vector(15 downto 0);
 signal toSend: std_logic_vector(15 downto 0);
 
 begin
 
 flt: process(reset, CLOCK_50)
  
  begin	
	if reset = '0' then 
		FLT_OE_INPUT <= '0';
		FLT_OE_OUTPUT <= '0';
		RCV_TOFILTER <= (others => '0');
		TSMT_TOANALOG <= (others => '0');
		cState <= RESETst;
		
	elsif rising_edge(CLOCK_50) then
		case cstate is		
			when RESETst	=>
				cState <= WAITst;
			
			when WAITst		=>
				FLT_OE_OUTPUT <= '0';
				if(FLT_OE_INPUT = '0') then
					cState <= WAITst;
				else
					cState <= TREATMENTst;
				end if;
			
			when TREATMENTst =>
				tmp <= RCV_TOFILTER;
				TSMT_TOANALOG <= tmp;
				FLT_OE_OUTPUT <= '1';
				cState <= WAITst;
			
			when others	=>
				null;
				
		end case;
	end if;
 end process flt;


end filter_arch;


