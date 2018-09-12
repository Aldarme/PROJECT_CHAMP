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
				
				--tmp17b <= resize(signed(RCV_TOFILTER(19 downto 4)), tmp17b'length);
				tmp17b <= shift_right(resize(signed(RCV_TOFILTER(19 downto 4)), tmp17b'length), to_integer(unsigned(SWITCH(3 downto 0))));
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



----------------------------------------------------------------
--
--	Filter:
--	 All amplitude data
--	 Acceleration average
--	 G integration to provide	-Spreed
--														-Position
--
----------------------------------------------------------------
architecture filter_mapBitAvrg of filter is
 
 signal offset : signed(16 downto 0) := 17x"08000";

 type   T_SPISTATE is ( IDLEst, Testst, CALIBst, Mapst, TRANSMITst);
 signal cState	: T_SPISTATE;
 signal cState2	:	T_SPISTATE;
 signal cState3 : T_SPISTATE;
 signal cState4 : T_SPISTATE;
 
 signal tmp17b		: signed(16 downto 0);
 signal signedTmp	: signed(16 downto 0);
 
 type myTab is array ( 0 to 1023) of std_logic_vector(19 downto 0); -- depth of the average array 1024 or 2048
 
 signal NBits		: integer := 1024;				-- Array delimiter
 signal myData	: myTab;									-- Array of successive value of acceleration
 signal avrg		:	signed(19 downto 0);	-- Calculated average
 signal speed		:	signed(15 downto 0);		-- Speed data, obtain by integration of acceleration
 signal spd_oe	:	std_logic;							
 signal posit		:	signed(15 downto 0);		-- Position data, obtain by itegration of acceleration
 signal pos_oe	: std_logic;
 
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
 
 --
 -- Good acceleration data transmit
 --	data transmit = acceleration - average acceleration
 --
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
				
				tmp17b <= resize(signed(RCV_TOFILTER(19 downto 4)) - avrg, tmp17b'length);
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
 
 
 --
 -- Slidding window average
 --
 --	The average data (avrg) calculated below, is define has "signed"
 --
 average: process(RESET_SIGNAL, CLOCK_50) is
		
		variable movIdx	:	integer	:= 0;			-- Most old value index of the acceleration array
		
	begin
		
		if RESET_SIGNAL = '0' then
			
			for I in 0 to 1023 loop
				myData(I) <= 20x"0";
			end loop;
			
			movIdx	:= 0;
			avrg		<= 20x"0";
			
			cState2	<= IDLEst;
			
		elsif rising_edge(CLOCK_50) then
			
			case cState2 is
				
				when IDLEst =>
					
					avrg <= avrg + signed(RCV_TOFILTER) - signed(myData(movIdx));
					myData(movIdx) <= RCV_TOFILTER;
					
					cState2 <= Testst;
					
				when Testst =>
					
					if movIdx >= NBits -1 then
						movIdx := 0;
					else
						movIdx := movIdx +1;
					end if;
					
				when others =>
					cState2 <= IDLEst;
					
			end case;
		end if;
	end process average;

 --
 -- Integrated acceleration
 --
 dp_dt: process(RESET_SIGNAL, FLT_OE_INPUT) is
	
	 begin
	 
		if RESET_SIGNAL = '0' then
			
			speed 	<= 16x"0";
			spd_oe 	<= '0';
			cState3 <= IDLEst;
			
		elsif rising_edge(flt_OE_INPUT) then
				
			case cState3 is
				
				when IDLEst =>
					
					speed <= shift_right(signed(RCV_TOFILTER(19 downto 4)),11) + speed;
					spd_oe <= '1';
					
					cState3 <= Testst;
					
				when Testst =>
					
					spd_oe 	<= '0';
					
					cState3 <= IDLEst;			
					
				when others =>
					cState3 <= IDLEst;
			end case;
		end if;	
	end process dp_dt;
 
 --
 -- Integrated speed
 --
 dv_dt: process(RESET_SIGNAL, spd_oe) is
	
		variable idx : integer := 0;
		
	 begin
		
		if  RESET_SIGNAL = '0' then
			
			posit		<= 16x"0";
			pos_oe	<= '0';
			cState4 <= IDLEst;
			
		elsif rising_edge(spd_oe) then
			
			case cState4 is
				
				when IDLEst =>
					
					posit <= shift_right(speed, 11) + (posit);
					--posit <= shift_right(shift_right(signed(RCV_TOFILTER(19 downto 4)), 2), 20) + (shift_right(speed, 11) + (posit);
					--0.001^2 is the same thing to divide by 1000000, correspnding to a shift right of 20 bits. 
					--With our 16  bits word, it is like having our 16 bits at "0".
					pos_oe <= '1';
					
					cState4 <= Testst;
					
				when Testst =>
					
					pos_oe <= '0';
					
					cState4 <= IDLEst;
					
				when others =>
					cState4 <= IDLEst;
			end case;			
		end if; 
	end process dv_dt;

end filter_mapBitAvrg;












