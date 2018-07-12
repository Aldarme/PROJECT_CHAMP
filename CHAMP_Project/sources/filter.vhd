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
 signal Cstate2	:	T_SPISTATE;
 
 signal tmp17b		: signed(16 downto 0);
 signal signedTmp	: signed(16 downto 0);
 
 type myTab is array ( 0 to 63) of std_logic_vector(19 downto 0);
 
 signal divider	: integer := 4;
 signal NBits		: integer := 64;
 signal index		: integer := 0;
 signal myData	: myTab;
 signal tmpAvrg	:	signed(19 downto 0);
 signal avrg		:	unsigned(19 downto 0);
 signal speed		:	signed(15 downto 0);
 signal spd_oe	:	std_logic;
 signal posit		:	signed(15 downto 0);
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
				
				tmp17b <= resize(signed(RCV_TOFILTER(19 downto 4)) - signed(avrg), tmp17b'length);
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
 average: process(RESET_SIGNAL, CLOCK_50) is
		
		
	begin
		
		if resET_SIGNAL = '0' then
			
			for I in 0 to 63 loop
				myData(I) <= 20x"0"; 
			end loop;
			
			divider	<= 0;
			NBits		<= 0;
			index		<= 0;
			
			cState2 <= IDLEst;
			
		elsif rising_edge(CLOCK_50) then	
			
			case cState2 is
				
				when IDLEst	=>
					
					myData(index) <= RCV_TOFILTER;
					
					index <= index +1;
					
					if index >= NBits-1 then
						index <= 0;
					end if;
					
					cState2 <= CALIBst;
					
				when CALIBst =>
					
					for I in 0 to 63 loop
						tmpAvrg <= tmpAvrg + signed(myData(I));
					end loop;
					
					cState2 <= Mapst;
					
				when Mapst =>
					
					avrg <= shift_right(unsigned(tmpAvrg) , 6); --shift_right by 6 to divide by 64
					
					cState2 <= IDLEst;
					
				when others =>
					cState2	<= IDLEst;
					
			end case;
		end if;		
 end process average;

 --
 -- position integrator
 --
 dp_dt: process(RESET_SIGNAL, FLT_OE_INPUT) is
	
	variable idx : integer := 0;
	
 begin
 
	if RESET_SIGNAL = '0' then
		
		speed <= 16x"0";
		
	elsif rising_edge(flt_OE_INPUT) then
		
		speed <= speed + signed(RCV_TOFILTER(19 downto 4));
		idx := idx + 1;
		
		if idx < 7 then
			spd_oe <= '0';
		else
			spd_oe <= '1';
			idx 		:= 0;
		end if;
	end if;
	
	
 end process dp_dt;
 
 --
 -- speed integrator
 --
 dv_dt: process(RESET_SIGNAL, spd_oe) is
	
	variable idx : integer := 0;
	
 begin
	
	if  RESET_SIGNAL = '0' then
		
		posit <= 16x"0";
		
	elsif rising_edge(spd_oe) then
		
		posit <= posit + speed;
		idx := idx + 1;
		
		if idx < 2 then
			pos_oe <= '0';
		else
			pos_oe 	<= '1';
			idx			:= 0;
		end if;		
	end if;
 
 end process dv_dt;

end filter_mapBitAvrg;












