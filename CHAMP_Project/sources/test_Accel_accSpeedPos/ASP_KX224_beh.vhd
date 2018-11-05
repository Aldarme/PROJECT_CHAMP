----------------------------------------------------------------
--   Title     :  KX224 Behavioral model
----------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.MATH_REAL.all;

entity ASP_KX224_beh is
	generic(
		SIZE   : INTEGER:=20;	-- 20 bits data
		ARANGE : REAL:=8.0		-- +-8g
	);
	port(
	  SCLK	: in  STD_LOGIC;		--SPI clock
	  CSB  	: in  STD_LOGIC;		--slave selection
	  SDI_O : INOUT  STD_LOGIC	--MOSI/Miso
	  --SDO : out STD_LOGIC			--MISO
	);
end entity;

--}} End of automatically maintained section

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.MATH_REAL.all;

--------------------------------------------------------------
--
-- Architecture 3 wires
--
--------------------------------------------------------------
architecture ThreeWires of ASP_KX224_beh is

-- SPI Interface
signal iBit        : integer		:= 0;
signal isAddress   : std_logic	:= '0';
signal ReadWriteB  : std_logic	:= '0';
signal Instruction : std_logic_vector( 7 downto 0) := 8x"0";
signal TxData      : std_logic_vector( 8 downto 0) := 9x"0";	--From accelerometer (slave) to master
signal RxData      : std_logic_vector( 8 downto 0) := 9x"0";	--From master to accelerometer (slave) | data store but never used
signal SpiReg      : std_logic_vector( 8 downto 0) := 9x"0";

---
--- KX224 Registers addresses
---
constant KX_READ_REG    : std_logic := '1';
constant KX_WRITE_REG   : std_logic := '0';

constant KX_ZOUT_L  : std_logic_vector(6 downto 0) := 7x"0A";
constant KX_ZOUT_H  : std_logic_vector(6 downto 0) := 7x"0B";

constant SPI_ADD_FIELD	: std_logic_vector(16 downto 9)	:=(others=>'0');	--Champ d'addresses
constant SPI_DATA_FIELD : std_logic_vector(8 downto 0)	:=(others=>'0');	--EXTRABIT & Champ de données

--
-- KX224
--
constant KX_DATA_RATE : REAL:= 1.0E3; 							--Output Data Rate (ODR) of KX224 is 1KHz
constant KX_DATA_PER  : REAL:= 1.0/ KX_DATA_RATE;
signal   Z            : REAL;

constant GMAX : REAL:=	2.0**(SIZE-1) - 1.0;
constant GMIN : REAL:=	-2.0**(SIZE-1);

signal dataz_word     : std_logic_vector(23 downto 0);
alias  dataz1 is dataz_word( 7 downto 0);
alias  dataz2 is dataz_word(15 downto 8);
alias	 dataz3 is dataz_word(23 downto 16);

signal bitConf : std_logic_vector(7 downto 0) := 8x"0";

signal dataz : std_logic_vector(SIZE-1 downto 0);


------------------------------------------------------------------------------
--
BEGIN
--
------------------------------------------------------------------------------

measp: process

	variable ti: REAL:=0.0;
	variable ReflSine : REAL:=0.0;
	variable vZ : REAL;
begin
	vZ := 8.0 * SIN( 2.0*MATH_PI*100.0*ti); -- +-8g sin, freq 100 Hz
	Z <= vZ;
	vZ := floor( GMAX * vZ / ARANGE );
	dataz <= Conv_Std_Logic_Vector(Integer(vZ),SIZE);
    
   ti := ti + KX_DATA_PER;
	wait for KX_DATA_PER * 1 sec;
		
end process measp;

-- dataz_word <= SXT( dataz, dataz_word'LENGTH );
dataz_word <= EXT( dataz, dataz_word'LENGTH ); --Copy dataz into dataz_word, coded on "dataz_word'LENGTH" bits.

--SDI_O <= 'Z';	--SDO
	
spip: process( CSB, SCLK )
variable vInst : std_logic_vector(Instruction'RANGE); --std_logic_vector(7 downto 0)

begin

  if CSB='1' then
      SDI_O       <= 'Z';	--SDO
      isAddress   <= '1';
      ReadWriteB  <= '0';
      iBit        <= 0;		--current bits, according to KX224 protocole, READ/WRITE bits is MSB
      Instruction <= (others=>'U');
      TxData      <= (others=>'U');
		
      if rising_edge(CSB) then 
				SpiReg <= RxData + '1';
			end if;
		
  elsif rising_edge(SCLK) then
			
		if isAddress='1' then
			if iBit=1 and isAddress='1' then --wait for REA/WRITE bits
				ReadWriteB <= SDI_O;	--SDI
			end if;
				
			vInst := Instruction(Instruction'HIGH-1 downto 0) & SDI_O;	--Serialize SDI_O data into "vInst"
			Instruction <= vInst;
				
			if iBit = Instruction'HIGH-1 then	--handler for circular buffer || if iBit = 8
				isAddress <= '0';
				iBit <= 0;
					
				case vInst(KX_ZOUT_L'RANGE) is
						
					when KX_ZOUT_L =>
						TxData(8) 					<= '0';
						TxData(7 downto 0)	<= dataz1;
						
					when KX_ZOUT_H =>
						TxData(8) 			 		<= '0';
						TxData(7 downto 0) 	<= dataz2;
						
					when others =>
						TxData(8) 			 		<= '0';
						TxData(7 downto 0) 	<= SpiReg(8 downto 1);						
				end case;
				
			else
				iBit <= iBit+1;
			end if;
			
		elsif ReadWriteB='0' then	--master is in WRITE mode (send data to configure internal register)
				
				RxData <= RxData(RxData'HIGH-1 downto 0) & SDI_O ;	--SDI
				iBit   <= iBit+1;
				
		end if;
			
	elsif falling_edge(SCLK) then
		
      if isAddress='0' and ReadWriteB='1' then
          SDI_O  <= TxData(TxData'HIGH);		--EXTRABIT & register addresse read are stored and returned to the master  
          TxData <= TxData(TxData'HIGH-1 downto 0) & TxData(TxData'HIGH);
      end if;
		
  end if;
end process spip;

end ThreeWires;
