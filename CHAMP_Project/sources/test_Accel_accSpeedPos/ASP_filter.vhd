-- Quartus II VHDL Template
-- Binary Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;

entity ASP_filter is
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
		POS_COUNT			: OUT INTEGER;
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
architecture filter_mapBitAvrgANDInteg of ASP_filter is
 
 signal offset : signed(16 downto 0) := 17x"08000";		--offset of 32768 (8000 Hex) to transform signed word into an unsigned word

 type   T_SPISTATE is ( IDLEst, Testst, CALIBst, MAPst, REMAPst, ADDst, TRANSMITst);
 signal cState	: T_SPISTATE;
 signal cState2	:	T_SPISTATE;
 signal cState3 : T_SPISTATE;
 signal cState4 : T_SPISTATE;
 
 --acceleration
 signal tmp17b		: signed(16 downto 0);
 signal signedTmp	: signed(16 downto 0);
 signal avrg17b		: signed(16 downto 0);
 signal avgSgnTmp	: signed(16 downto 0);
 signal spdtmp17 	: signed(16 downto 0);
 --speed
 signal sgnSpdTmp	: integer;
 signal SpdTmpadd	: integer;
 signal speedAdder: integer;
 signal speedAdBuf: integer;
 signal lessOffset: integer;
 --position
 signal withoffs : integer;
 signal posAdder : integer;
 
 
 
 type myTab is array(0 to 1023) of std_logic_vector(15 downto 0); -- depth of the average array 1024 or 2048
 
 signal NBits		: integer := 1024;				-- Array delimiter
 signal myData	: myTab;									-- Array of successive value of acceleration
 signal movIdx	:	integer	:= 0;						-- Most old value index of the acceleration array
 signal avrg		:	signed(15 downto 0);		-- Calculated average
 
 component ASP_HexDisplay
	port
	(
		hex_4		: out	std_logic_vector(6 downto 0);
		hex_5		: out	std_logic_vector(6 downto 0);
		inNumb	: in	integer;
		reset		: in std_logic
	);
 end component;
 
 begin
 
 sevDisp : ASP_HexDisplay
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
		tmp17b		<= 17x"0";
		signedTmp	<= 17x"0";
		TSMT_TOANALOG <= 16x"0";
		
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
				
				tmp17b <= resize(signed(RCV_TOFILTER(19 downto 4)), tmp17b'length);
				cState 	<= CALIBst;
				
			when CALIBst	=>
				
				signedTmp <= tmp17b + offset;
				FLT_OE_OUTPUT <= '1';
				cState 	<= TRANSMITst;
				
			when TRANSMITst =>
				
				TSMT_TOANALOG <= std_logic_vector(unsigned(signedTmp(15 downto 0)) - unsigned(avrg));
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
		
	begin
		
		if RESET_SIGNAL = '0' then
			
			for I in 0 to 1023 loop
				myData(I) <= 16x"0";
			end loop;
			
			movIdx	<= 0;
			avrg		<= 16x"0";
			
			cState2	<= IDLEst;
			
		elsif rising_edge(CLOCK_50) then
			
			case cState2 is
				
				when IDLEst		=>
					
					if(FLT_OE_INPUT = '0') then
						cState2 <= IDLEst;
					else
						cState2 <= Testst;
					end if;
					
				when Testst =>
					
					avrg17b <= resize(signed(RCV_TOFILTER(19 downto 4)), avrg17b'length);
					cState2 	<= CALIBst;
					
				when CALIBst	=>
					
					avgSgnTmp <= avrg17b + offset;
					cState2 	<= MAPst;
					
				when MAPst =>
					
					avrg <= avrg + avgSgnTmp(15 downto 0) - signed(myData(movIdx));
					myData(movIdx) <= std_logic_vector(unsigned(avgSgnTmp(15 downto 0)));
					cState2 <= TRANSMITst;
					
				when TRANSMITst =>
					
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
 dp_dt: process(RESET_SIGNAL, CLOCK_50) is	--IDLEst, Testst, CALIBst, MAPst, ADDst, TRANSMITst
			
			variable tmpLess : integer;
			
	begin
			
		if RESET_SIGNAL = '0' then
			
			SPD_OUTPUT 		<= 16x"0";
			SPD_OE_OUTPUT <= '0';
			SPD_COUNT			<= 0;
			sgnSpdTmp			<= 0;--17x"0";
			lessOffset		<= 0;
			speedAdBuf		<= 0;--17x"0";17x"0";
			SpdTmpadd			<= 0;--17x"0";17x"0";
			speedAdder		<= 0;--17x"0";17x"0";
			cState3 			<= IDLEst;
			
		elsif rising_edge(CLOCK_50) then
				
			case cState3 is
				
				when IDLEst =>
					
					SPD_OE_OUTPUT <= '0';
					
					if FLT_OE_INPUT = '1' then
						cState3 <= Testst;
					else
						cState3 <= IDLEst;
					end if;
					
				when Testst =>
					
					sgnSpdTmp	<= to_integer(unsigned(signedTmp(15 downto 0)) - unsigned(avrg));
					cState3 <= CALIBst;
					
				when CALIBst =>
					
					lessOffset <= sgnSpdTmp - to_integer(offset);
					cState3 <= REMAPst;
					
				when REMAPst =>
					
					if lessOffset > -1800 AND lessOffset < 1800 then
						tmpLess := 0;
						speedAdder <= 0;
					else
						tmpLess := lessOffset;
					end if;
					
					cState3 <= ADDst;
					
				when ADDst =>
					
					speedAdder <= tmpLess + speedAdder;
					cState3 <= MAPst;
					
				when MAPst =>
					
					SpdTmpadd <= speedAdder + to_integer(offset);
					SPD_OE_OUTPUT <= '1';
					cState3 <= TRANSMITst;
					
				when TRANSMITst =>
					
					SPD_OUTPUT	<= std_logic_vector(to_unsigned(SpdTmpadd, 16));
					SPD_COUNT		<= SPD_COUNT + 1;
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
		
		variable tmpLess : integer;
		
	 begin
		
		if  RESET_SIGNAL = '0' then
			
			POS_OUTPUT		<= 16x"0";
			POS_OE_OUTPUT	<= '0';
			POS_COUNT			<= 0;
			cState4 <= IDLEst;
			
		elsif rising_edge(CLOCK_50) then
			
			case cState4 is
				
				when IDLEst =>
					
					POS_OE_OUTPUT <= '0';
					
					if SPD_OE_OUTPUT = '1' then
						cState4 <= Testst;
					else
						cState4 <= IDLEst;
					end if;
					
				when Testst =>
					
					if speedAdder > -1000 AND speedAdder < 1000 then
						tmpLess := 0;
						posAdder <= 0;
					else
						tmpLess := speedAdder;
					end if;					
					cState4 <= CALIBst;
					
				when CALIBst =>
					
					posAdder <= tmpLess + posAdder;					
					cState4 <= ADDst;
					
				when ADDst =>
					
					withoffs <= posAdder + to_integer(offset);
					POS_OE_OUTPUT <= '1';
					cState4 <= TRANSMITst;
					
				when TRANSMITst =>
					
					POS_OUTPUT <= std_logic_vector(to_unsigned(withoffs, 16));
					POS_COUNT	 <= POS_COUNT +1;
					cState4 <= Testst;
					
				when others =>
					cState4 <= IDLEst;
			end case;			
		end if; 
	end process dv_dt;

end filter_mapBitAvrgANDInteg;












