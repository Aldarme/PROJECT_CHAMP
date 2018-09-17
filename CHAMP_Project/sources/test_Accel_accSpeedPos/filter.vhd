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
		CLOCK_50   		:	IN	STD_LOGIC;
		FLT_OE_INPUT	:	IN 	STD_LOGIC;
		RCV_TOFILTER	:	IN 	STD_LOGIC_VECTOR(19 DOWNTO 0);
		FLT_OE_OUTPUT	:	OUT STD_LOGIC;		
		TSMT_TOANALOG	:	OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		SPD_OE_OUTPUT	: OUT STD_LOGIC;
		SPD_OUTPUT		:	OUT STD_LOGIC_VECTOR(15 DOWNTO 0);		-- Speed data, obtain by integration of acceleration
		SPD_COUNT			: OUT INTEGER;													-- Store the number of integration of acceleration since the beginning
		POS_OE_OUTPUT	:	OUT STD_LOGIC;
		POS_OUTPUT		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);		-- Position data, obtain by itegration of acceleration
		SWITCH				:	IN 	STD_LOGIC_VECTOR(17 DOWNTO 0);
		HEX4Disp			: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX5Disp			: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		RESET_SIGNAL	:	IN 	STD_LOGIC
	);
	
END ENTITY;

----------------------------------------------------------------
--
--	Filter:
--	 All amplitude data
--	 Acceleration average
--	 G integration to provide	-Spreed
--														-Position
--
----------------------------------------------------------------
architecture filter_mapBitAvrgANDInteg of filter is
 
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
 signal movIdx	:	integer	:= 0;						-- Most old value index of the acceleration array
 signal avrg		:	signed(19 downto 0);		-- Calculated average
 
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
 average: process(RESET_SIGNAL, CLOCK_50) is												--IDLEst, Testst, CALIBst, Mapst, TRANSMITst
		
	begin
		
		if RESET_SIGNAL = '0' then
			
			for I in 0 to 1023 loop
				myData(I) <= 20x"0";
			end loop;
			
			movIdx	<= 0;
			avrg		<= 20x"0";
			
			cState2	<= IDLEst;
			
		elsif rising_edge(CLOCK_50) then
			
			case cState2 is
				
				when IDLEst		=>
					
					if(FLT_OE_INPUT = '0') then
						cState2 <= IDLEst;
					else
						cState2 	<= Testst;
					end if;
					
				when Testst =>
					
					avrg <= avrg + signed(RCV_TOFILTER) - signed(myData(movIdx));
					myData(movIdx) <= RCV_TOFILTER;
					
					cState2 <= CALIBst;
					
				when CALIBst =>
					
					if movIdx >= NBits -1 then
						movIdx <= 0;
					else
						movIdx <= movIdx +1;
					end if;
					
					cState2 <= IDLEst;
					
				when others =>
					cState2 <= IDLEst;
					
			end case;
		end if;
	end process average;

 --
 -- Integrated acceleration
 --
 dp_dt: process(RESET_SIGNAL, CLOCK_50) is
			
		variable speedAdd : signed(19 downto 0);
			
	 begin
	 
		if RESET_SIGNAL = '0' then
			
			SPD_OUTPUT 		<= 16x"0";
			SPD_OE_OUTPUT <= '0';
			SPD_COUNT			<= 0;
			cState3 			<= IDLEst;
			
		elsif rising_edge(CLOCK_50) then
				
			case cState3 is
				
				when IDLEst =>
					
					if flt_OE_INPUT = '1' then
						cState3 <= Mapst;
					else
						cState3 <= IDLEst;
					end if;
					
				when Mapst =>
					
					speedAdd		:= signed(RCV_TOFILTER) + signed(SPD_OUTPUT);	
					SPD_OUTPUT	<= std_logic_vector(speedAdd(19 downto 4));
					SPD_COUNT		<= SPD_COUNT + 1;
					
					cState3 <= TRANSMITst;
					
				when TRANSMITst =>
					
					SPD_OE_OUTPUT <= '1';
					cState3 <= CALIBst;
					
				when CALIBst =>
					
					SPD_OE_OUTPUT <= '0';
					cState3 <= IDLEst;
					
				when others =>
					cState3 <= IDLEst;
			end case;
		end if;	
	end process dp_dt;
 
 --
 -- Integrated speed
 --
 dv_dt: process(RESET_SIGNAL, CLOCK_50) is
		
	 begin
		
		if  RESET_SIGNAL = '0' then
			
			POS_OUTPUT		<= 16x"0";
			POS_OE_OUTPUT	<= '0';
			cState4 <= IDLEst;
			
		elsif rising_edge(CLOCK_50) then
			
			case cState4 is
				
				when IDLEst =>
					
					if SPD_OE_OUTPUT = '1' then
						cState4 <= Mapst;
					else
						cState4 <= IDLEst;
					end if;
					
				when Mapst =>
					
					POS_OUTPUT <= std_logic_vector(signed(SPD_OUTPUT) + signed(POS_OUTPUT));
					
					cState4 <= TRANSMITst;
					
				when TRANSMITst =>
					
					POS_OE_OUTPUT <= '1';
					
					cState4 <= Testst;
					
				when Testst =>
					
					POS_OE_OUTPUT <= '0';
					
					cState4 <= IDLEst;
					
				when others =>
					cState4 <= IDLEst;
			end case;			
		end if; 
	end process dv_dt;

end filter_mapBitAvrgANDInteg;












