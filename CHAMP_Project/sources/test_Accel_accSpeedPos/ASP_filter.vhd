--------------------------------------------------------------------------------
--
-- FileName:         ASP_filter.vhd
-- Dependencies:     none
-- Design Software:  Quartus II Version 17.1.0
--
-- This file provide an architecture to calculate different type of data
-- Those data are:
--	Average acceleration
--	Speed 		(integration of acceleration)
--	Position 	(integration of speed)
-- 
-- Version History
-- Version 0.5 21/11/2018 - Pierre ROMET
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
		GPIO_OE_MOTOR	: OUT 	STD_LOGIC;
		RESET_SIGNAL	:	IN 	STD_LOGIC
	);
	
END ENTITY;

----------------------------------------------------------------
--
--	Filter:
--	 All amplitude data
--	 Acceleration average
--	 G integration to provide	-Speed
--														-Position
--
----------------------------------------------------------------
architecture filter_mapBitAvrgANDInteg of ASP_filter is
 
 constant offset : signed(16 downto 0) := 17x"08000";		--offset of 32768 (8000 Hex) to transform signed word into an unsigned word
 
 type myTab is array(0 to 4) of unsigned(15 downto 0);
 type T_SPISTATE is ( IDLEst, Testst, CALIBst, MAPst, REMAPst, ADDst, checkMaxst, NORMALIZEst, TRANSMITst);

 signal cState	: T_SPISTATE;
 signal cState2 :	T_SPISTATE;
 signal cState3 : T_SPISTATE;
 signal cState4 : T_SPISTATE;
 
 --acceleration
 signal tmp17b		: signed(16 downto 0);
 signal signedTmp : signed(16 downto 0);
 signal tmp 			: unsigned(15 downto 0);
 
 --average
 signal avgSgnTmp	: signed(16 downto 0);
 signal normVal 	: unsigned(15 downto 0);
 signal avrg			:	signed(23 downto 0);		-- Calculated average
 signal avgAdder	:	signed(23 downto 0);		-- Calculated average
 --speed
 signal spdAdder	: signed(20 downto 0);
 signal spdDiv		: signed(20 downto 0);
 signal to_send		:	signed(20 downto 0);
 signal oe_motor	: std_logic;							-- high state active
 signal spdGain		: integer;
--position
 signal posAdder	: unsigned(20 downto 0);
 signal posDiv		: unsigned(20 downto 0);
 signal pos_send	:	unsigned(20 downto 0);
 signal oe_pos		: std_logic;
 
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
-- Acceleration data transmit
--	data transmit = acceleration - average acceleration
--
Acceleration: process(RESET_SIGNAL, CLOCK_50) is
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
				cState 	<= MAPst;
				
			when MAPst =>
				
				tmp <= unsigned(avgSgnTmp(15 downto 0)) - to_unsigned(32768, tmp'length );
				cState 	<= NORMALIZEst;
				
			when NORMALIZEst =>
				
				normVal <= unsigned(signedTmp(15 downto 0)) - (tmp);
				cState 	<= TRANSMITst;
				
			when TRANSMITst =>
				
				FLT_OE_OUTPUT <= '1';
				TSMT_TOANALOG <= std_logic_vector(normVal);
				cState 	<= IDLEst;
				
			when others	=>
				cState <= IDLEst;
				
		end case;
	end if;
end process Acceleration;
 
 
--
-- Average acceleration, measured on 1024 samples (or ~1sec)
--
average: process(RESET_SIGNAL, CLOCK_50) is
		
		variable avgIdx	: integer := 0;
		
	begin
		
	if RESET_SIGNAL = '0' then
		avrg		 <= 24x"0";
		avgAdder <= 24x"0";
		avgIdx	 := 0;
		avgSgnTmp <= 17x"0";
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
					
					if to_integer(signed(RCV_TOFILTER(19 downto 4))) >= 3300
						AND to_integer(signed(RCV_TOFILTER(19 downto 4))) <= 4096 then
						
						avgAdder <= avgAdder + signed(RCV_TOFILTER(19 downto 4));
						avgIdx := avgIdx +1;
						cState2 <= CALIBst;
					else
						cState2 <= IDLEst;
					end if;
						
				when CALIBst =>
					
					if avgIdx >= 1024 then
						avrg		 <= shift_right(signed(avgAdder), 10);
						avgAdder <= 24x"0";
						avgIdx	 := 0;
						cState2	 <= TRANSMITst;
					else
						cState2 <= IDLEst;
					end if;
					
				when TRANSMITst =>
					avgSgnTmp <= avrg(15 downto 0) + offset;
					cState2 <= IDLEst;
				
			when others =>
				cState2 <= IDLEst;
		end case;
	end if;
end process average;

	
--
-- Integrated acceleration
--
Speed: process(RESET_SIGNAL, CLOCK_50) is
		
begin
		
	if RESET_SIGNAL = '0' then
			
		spdAdder			<= 21x"0";
		spdDiv				<= 21x"0";
		oe_motor			<= '0';
		spdGain				<= 0;
		to_send				<= 21x"0";
		SPD_OUTPUT 		<= 16x"0";
		SPD_OE_OUTPUT <= '0';
		SPD_COUNT			<= 0;
		cState3 			<= IDLEst;
			
	elsif rising_edge(CLOCK_50) then
-- signal spdAdder	: signed(20 downto 0);
-- signal spdDiv		: signed(20 downto 0);
-- signal to_send		:	signed(20 downto 0);
-- signal oe_motor	: std_logic;
		case cState3 is
			
			when IDLEst =>
					
				SPD_OE_OUTPUT <= '0';
					
				if FLT_OE_INPUT = '1' then
					cState3 <= TEStst;
				else
					cState3 <= IDLEst;
				end if;
					
			when TEStst =>
				spdDiv <= resize( signed(RCV_TOFILTER(19 downto 4)), spdDiv'Length);
				cState3 <= ADDst;
					
			when ADDst =>
				if spdDiv <= to_signed(4096, to_send'length) then					--accInst < 4096
					 
					spdAdder 			<= 21x"0";
					oe_motor 			<= '0';
					GPIO_OE_MOTOR	<= oe_motor;
						
				else																											--out of range
					spdAdder <= spdAdder + shift_right(signed(spdDiv), 5);	--le facteur de division est la calibration en vitesse (5)
					if spdDiv > to_signed(8000, to_send'length) then
					oe_motor <= '1';
					GPIO_OE_MOTOR	<= oe_motor;
					end if;
				end if;
					
				cState3 <= MAPst;
					
			when MAPst =>
				if oe_motor = '0' then
					to_send <= to_signed(32768, to_send'length);
				else
					to_send <= spdAdder + to_signed(32768, to_send'length);
				end if;
				
				cState3 <= TRANSMITst;
					
			when TRANSMITst =>
				SPD_OE_OUTPUT	<= '1';
				SPD_OUTPUT		<= std_logic_vector(to_send(15 downto 0));
				SPD_COUNT			<= SPD_COUNT + 1;
				cState3 			<= IDLEst;
					
			when others =>
				cState3 <= IDLEst;
		end case;
	end if;	
end process Speed;
 
 
--
-- Integrated speed
--
Position: process(RESET_SIGNAL, CLOCK_50) is
-- signal posAdder	: unsigned(20 downto 0);
-- signal posDiv		: unsigned(20 downto 0);
-- signal pos_send	:	unsigned(20 downto 0);
 --signal oe_pos		: std_logic;
		
begin
		
	if RESET_SIGNAL = '0' then

		posAdder			<= 21x"0";
		posDiv				<= 21x"0";
		oe_pos				<= '0';
		pos_send			<= 21x"0";
		POS_OUTPUT		<= 16x"0";
		POS_OE_OUTPUT	<= '0';
		POS_COUNT			<= 0;
		cState4 			<= IDLEst;
		
	elsif rising_edge(CLOCK_50) then
			
		case cState4 is
			
			when IDLEst =>
					
				POS_OE_OUTPUT <= '0';
					
				if SPD_OE_OUTPUT = '1' then
					cState4 <= TEStst;
				else
					cState4 <= IDLEst;
				end if;
					
			when TEStst =>
				posDiv 	<= resize( unsigned(spdAdder), spdDiv'Length);
				cState4 <= ADDst;
					
			when ADDst =>
				if posDiv /= 16x"0" then
					posAdder 	<= posAdder + shift_right(unsigned(posDiv), 5);	--le facteur de division est la calibration en position (5)
					oe_pos		<= '1';
				else
					posAdder 	<= 21x"0";
					oe_pos		<= '0';
				end if;
					
				cState4 	<= MAPst;
					
			when MAPst =>
				if oe_pos = '0' then
					pos_send <= to_unsigned(32768, to_send'length);
				else
					pos_send <= posAdder + to_unsigned(32768, pos_send'length);
				end if;
					
				cState4 <= TRANSMITst;
					
			when TRANSMITst =>
				POS_OE_OUTPUT	<= '1';
				POS_OUTPUT		<= std_logic_vector(pos_send(15 downto 0));
				POS_COUNT			<= POS_COUNT + 1;
				cState4 			<= IDLEst;
					
			when others =>
				cState4 <= IDLEst;
		end case;
	end if;	
end process Position;

end filter_mapBitAvrgANDInteg;












