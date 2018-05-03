-- Quartus II VHDL Template
-- Binary Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;

entity Gen_filter is
	PORT
	(
		CLOCK_50   		:  IN STD_LOGIC;
		FLT_OE_INPUT	:	IN STD_LOGIC;
		RCV_TOFILTER	:	IN STD_LOGIC_VECTOR( 23 downto 0);
		FLT_OE_OUTPUT	:	OUT STD_LOGIC;		
		TSMT_TOANALOG	:  OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		RESET_SIGNAL	:	IN STD_LOGIC
	);
	
END ENTITY;

----------------------------------------------------------------
--
-- test archi
--	return the input filter
--
----------------------------------------------------------------
architecture filter_arch of Gen_filter is

 type   T_SPISTATE is ( RESETst, WAITst, TREATMENTst);
 signal cState     : T_SPISTATE;
 
 signal reset	:	std_logic;
 
 begin
 
 reset <= RESET_SIGNAL;
 
 flt: process(reset, CLOCK_50) is
  begin
	if reset = '0' then
		FLT_OE_OUTPUT <= '0';
		--TSMT_TOANALOG <= (others => '0');
		cState <= RESETst;
		
	elsif rising_edge(CLOCK_50) then
		case cstate is
			when RESETst	=>
			FLT_OE_OUTPUT <= '0';
			--TSMT_TOANALOG <= (others => '0');
			cState <= WAITst;
			
			when WAITst		=>
				FLT_OE_OUTPUT <= '0';
				if(FLT_OE_INPUT = '0') then
					cState <= WAITst;
				else
					cState <= TREATMENTst;
				end if;
			
			when TREATMENTst =>				
				TSMT_TOANALOG <= RCV_TOFILTER(19) & 3x"0" & RCV_TOFILTER(18 downto 7);
				FLT_OE_OUTPUT <= '1';
				cState <= WAITst;
			
			when others	=>
				null;
				
		end case;
	end if;
 end process flt;

end filter_arch;

--------------------------------------------------------------
--
-- Finit Implulse Response archi
--	return input filter through FIR
--
--------------------------------------------------------------
--architecture FIR_Filt of filter is
--
--	type t_coef is array (0 to 3) of signed(15 downto 0);
--	type t_dataIn is array (0 to 3) of signed(15 downto 0);
--	type t_mult is array (0 to 3) of signed(31 downto 0);
--	type t_subAdd is array (0 to 3) of signed(16 downto 0);
--	
--	signal my_coef	 : t_coef;
--	signal my_dataIn: t_dataIn;
--	signal my_mult	 : t_mult;
--	signal my_subAdd: t_subAdd;
--	signal my_total: signed(16 downto 0);
--	
--begin
--
--	init: process(FLT_OE_INPUT, CLOCK_50)
--		begin
--			if FLT_OE_INPUT = '0' then
--				my_dataIn <= (others =>(others => '0'));
--				my_coef	 <= (others => (others => '0'));
--			
--			elsif rising_edge(CLOCK_50) then
--				my_dataIn(0) <= signed(RCV_TOFILTER);
--				my_dataIn(1) <= signed(RCV_TOFILTER);
--				my_dataIn(2) <= signed(RCV_TOFILTER);
--				my_dataIn(3) <= signed(RCV_TOFILTER);
--				my_coef(0)<= 16x"01";
--				my_coef(1)<= 16x"01";
--				my_coef(2)<= 16x"01";
--				my_coef(3)<= 16x"01";
--			end if;
--	end process init;
--	
--	multi: process(FLT_OE_INPUT, CLOCK_50)
--	begin
--		if FLT_OE_INPUT = '0' then
--			my_mult <= (others => (others => '0'));
--		
--		elsif rising_edge (CLOCK_50) then
--			for i in 0 to 3 loop
--				my_mult(i) <= my_dataIn(i) * my_coef(i);
--			end loop;
--		end if;
--	end process multi;
--	
--	subSom: process(FLT_OE_INPUT, CLOCK_50)
--	begin
--		if FLT_OE_INPUT = '0' then
--			my_subAdd <= (others => (others=> ('0'));
--		
--		elsif rising_edge (CLOCK_50) then
--			for i in 0 to 1 loop
--				my_subAdd(i) <= resize(my_dataIn(2*i), 16) + resize(my_dataIn(2*i+1), 16);
--			end loop;
--		end if;
--	end process subSom;
--	
--	total: process(FLT_OE_INPUT, CLOCK_50)
--	begin
--		if FLT_OE_INPUT = '0' then
--			my_total <= (others => (others => '0'));
--		
--		elsif rising_edge (CLOCK_50) then
--			my_total <= resize(my_subAdd(0), 17) + resize(my_subAdd(1), 17);
--		
--		end if;
--	end process total;
--	
--	output: process(FLT_OE_INPUT, CLOCK_50)
--	begin
--		if FLT_OE_INPUT = '0' then
--			TSMT_TOANALOG <= (others => '0');
--		
--		elsif rising_edge(CLOCK_50) then
--			tsmT_TOANALOG <= std_logic_vector(my_total(my_subAdd'length downto 2));
--		end if;
--	end process output;
--	
--end FIR_Filt;