----------------------------------------------------------------
--   Title     :  ADXL355 Behavioral model
----------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.MATH_REAL.all;

entity adxl355_beh is
	 generic(
		SIZE   : INTEGER:=20;	-- 20 bits data
		ARANGE : REAL:=8.0		-- +-8g
	 );
	 port(
	   SCLK : in  STD_LOGIC;	--SPI clock
	   CSB  : in  STD_LOGIC;	--slave selection
	   SDI_O  : INOUT  STD_LOGIC	--MOSI/Miso
	   --SDO  : out STD_LOGIC		--MISO
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
architecture ThreeWires of adxl355_beh is

-- SPI Interface
signal iBit        : integer;
signal isAddress   : std_logic;
signal ReadWriteB  : std_logic;
signal Instruction : std_logic_vector( 7 downto 0);
signal TxData      : std_logic_vector( 7 downto 0);
signal RxData      : std_logic_vector( 7 downto 0);
signal SpiReg      : std_logic_vector( 7 downto 0);

---
--- ADXL355 Registers addresses
---
constant ADXL_READ_REG    : std_logic := '1';
constant ADXL_WRITE_REG   : std_logic := '0';

constant ADXL_DATAZ1_ADD  : std_logic_vector(7 downto 1):=7x"10";
constant ADXL_DATAZ2_ADD  : std_logic_vector(7 downto 1):=7x"0F";
constant ADXL_DATAZ3_ADD  : std_logic_vector(7 downto 1):=7x"0E";

constant SPI_ADD_FIELD    : std_logic_vector(15 downto 8):=(others=>'0');	--Champ d'addresses
constant SPI_DATA_FIELD   : std_logic_vector(7 downto 0):=(others=>'0');	--Champ de données

--
-- ADXL355
--
constant ADXL_DATA_RATE : REAL:= 1.0E3; 							--Output Data Rate (ODR) of ADXL355 is 1KHz
constant ADXL_DATA_PER  : REAL:= 1.0/ ADXL_DATA_RATE;
signal   Z              : REAL;

constant GMAX : REAL:=	2.0**(SIZE-1) - 1.0;
constant GMIN : REAL:=	-2.0**(SIZE-1);

signal   dataz_word     : std_logic_vector(23 downto 0);
alias dataz1 is dataz_word( 7 downto 0);
alias dataz2 is dataz_word(15 downto 8);
alias dataz3 is dataz_word(23 downto 16);

signal   dataz : std_logic_vector(SIZE-1 downto 0);

begin

measp: process
   variable ti: REAL:=0.0;
   variable ReflSine : REAL:=0.0;
	variable vZ : REAL;
  begin
	vZ := 8.0 * SIN( 2.0*MATH_PI*100.0*ti); -- +-8g sin, freq 100 Hz
	Z <= vZ;
	vZ := floor( GMAX * vZ / ARANGE );
	dataz <= Conv_Std_Logic_Vector(Integer(vZ),SIZE);
    
   ti := ti + ADXL_DATA_PER;
   wait for ADXL_DATA_PER * 1 sec;
end process measp;

-- dataz_word <= SXT( dataz, dataz_word'LENGTH );
dataz_word <= EXT( dataz, dataz_word'LENGTH ); --Copy dataz into dataz_word, coded on "dataz_word'LENGTH" bits.

--SDI_O <= 'Z';	--SDO
	
spip: process( CSB, SCLK )
variable vInst : std_logic_vector(Instruction'RANGE); --std_logic_vector(7 downto 0)

begin

  if CSB='1' then
      SDI_O        <= 'Z';	--SDO
      isAddress   <= '1';
      ReadWriteB  <= '0';
      iBit        <= 0;		--current bits, according to 355 protocole, READ/WRITE bits is LSB
      Instruction <= (others=>'U');
      TxData      <= (others=>'U');
		
      if rising_edge(CSB) then SpiReg <= RxData + '1'; end if;
		
  elsif rising_edge(SCLK) then
  
      if isAddress='1' then
		
         if iBit=7 and isAddress='1' then --wait for REA/WRITE bits
				ReadWriteB <= SDI_O;	--SDI
			end if;
			
         vInst := Instruction(Instruction'HIGH-1 downto 0) & SDI_O;	--SDI	--Instruction(7-1 downto 0) & SDI
         Instruction <= vInst;
				
			if iBit = Instruction'HIGH then	--handler for circular buffer
				isAddress <= '0';
				iBit <= 0;
				
				case vInst(ADXL_DATAZ1_ADD'RANGE) is
				
					when ADXL_DATAZ1_ADD =>
						TxData <= dataz1;

					when ADXL_DATAZ2_ADD =>
						TxData <= dataz2;
						
					when ADXL_DATAZ3_ADD =>
						TxData <= dataz3;

					when others =>
						TxData <= SpiReg;
						
				end case;
			
			else
				iBit <= iBit+1;
			end if;
			
		elsif ReadWriteB='0' then
			
				RxData <= RxData(RxData'HIGH-1 downto 0) & SDI_O ;	--SDI
				iBit   <= iBit+1;
				
		end if;
			
	elsif falling_edge(SCLK) then
		
      if isAddress='0' and ReadWriteB='1' then
          SDI_O   <= TxData(TxData'HIGH);		--SDO
          TxData <= TxData(TxData'HIGH-1 downto 0) & TxData(TxData'HIGH);
      end if;
		
  end if;
end process spip;

end ThreeWires;

--------------------------------------------------------------
--
-- Architecture 4 wires
--
--------------------------------------------------------------
--architecture behav of adxl355_beh is
--
---- SPI Interface
--signal iBit        : integer;
--signal isAddress   : std_logic;
--signal ReadWriteB  : std_logic;
--signal Instruction : std_logic_vector( 7 downto 0);
--signal TxData      : std_logic_vector( 7 downto 0);
--signal RxData      : std_logic_vector( 7 downto 0);
--signal SpiReg      : std_logic_vector( 7 downto 0);
--
-----
----- ADXL355 Registers addresses
-----
--constant ADXL_READ_REG    : std_logic := '1';
--constant ADXL_WRITE_REG   : std_logic := '0';
--
--constant ADXL_DATAZ1_ADD  : std_logic_vector(5 downto 0):=6x"10";
--constant ADXL_DATAZ2_ADD  : std_logic_vector(5 downto 0):=6x"0F";
--constant ADXL_DATAZ3_ADD  : std_logic_vector(5 downto 0):=6x"0E";
--
--constant SPI_ADD_FIELD    : std_logic_vector(15 downto 8):=(others=>'0');	--Champ d'addresses
--constant SPI_DATA_FIELD   : std_logic_vector(7 downto 0):=(others=>'0');	--Champ de données
--
----
---- ADXL355
----
--constant ADXL_DATA_RATE : REAL:= 3.4E3; -- 3400 Hz
--constant ADXL_DATA_PER  : REAL:= 1.0/ ADXL_DATA_RATE;
--signal   Z              : REAL;
--
--constant GMAX : REAL:=	2.0**(SIZE-1) - 1.0;
--constant GMIN : REAL:=	-2.0**(SIZE-1);
--
--signal   dataz_word     : std_logic_vector(23 downto 0);
--alias dataz1 is dataz_word( 7 downto 0);
--alias dataz2 is dataz_word(15 downto 8);
--alias dataz3 is dataz_word(23 downto 16);
--
--signal   dataz : std_logic_vector(SIZE-1 downto 0);
--
--begin
--
--measp: process
--    variable ti: REAL:=0.0;
--    variable ReflSine : REAL:=0.0;
--	variable vZ : REAL;
--  begin
--	vZ := 8.0 * SIN( 2.0*MATH_PI*100.0*ti); -- +-8g sin, freq 100 Hz
--	Z <= vZ;
--	vZ := floor( GMAX * vZ / ARANGE );
--	dataz <= Conv_Std_Logic_Vector(Integer(vZ),SIZE);
--    
--    ti := ti + ADXL_DATA_PER;
--    wait for ADXL_DATA_PER * 1 sec;
--end process measp;
--
---- dataz_word <= SXT( dataz, dataz_word'LENGTH );
--dataz_word <= EXT( dataz, dataz_word'LENGTH ); --Copy dataz into dataz_word, coded on "dataz_word'LENGTH" bits.
--
--SDO <= 'Z';
--	
--spip: process( CSB, SCLK )
--variable vInst : std_logic_vector(Instruction'RANGE); --std_logic_vector(7 downto 0)
--
--begin
--
--  if CSB='1' then
--      SDO        <= 'Z';
--      isAddress   <= '1';
--      ReadWriteB  <= '0';
--      iBit        <= 0;		--current bits, according to 355 protocole, READ/WRITE bits is LSB
--      Instruction <= (others=>'U');
--      TxData      <= (others=>'U');
--		
--      if rising_edge(CSB) then SpiReg <= RxData + '1'; end if;
--		
--  elsif rising_edge(SCLK) then
--  
--      if isAddress='1' then
--		
--         if iBit=7 and isAddress='1' then --wait for REA/WRITE bits
--				ReadWriteB <= SDI;
--			end if;
--			
--         vInst := Instruction(Instruction'HIGH-1 downto 0) & SDI;	--Instruction(7-1 downto 0) & SDI
--         Instruction <= vInst;
--				
--			if iBit = Instruction'HIGH then	--handler for circular buffer
--				isAddress <= '0';
--				iBit <= 0;
--				
--				case vInst(ADXL_DATAZ1_ADD'RANGE) is
--				
--					when ADXL_DATAZ1_ADD =>
--						TxData <= dataz1;
--
--					when ADXL_DATAZ2_ADD =>
--						TxData <= dataz2;
--						
--					when ADXL_DATAZ3_ADD =>
--						TxData <= dataz3;
--
--					when others =>
--						TxData <= SpiReg;
--						
--				end case;
--			
--			else
--				iBit <= iBit+1;
--			end if;
--			
--		elsif ReadWriteB='0' then
--			
--				RxData <= RxData(RxData'HIGH-1 downto 0) & SDI ;
--				iBit   <= iBit+1;
--				
--		end if;
--			
--		elsif falling_edge(SCLK) then
--		
--      if isAddress='0' and ReadWriteB='1' then
--          SDO   <= TxData(TxData'HIGH);
--          TxData <= TxData(TxData'HIGH-1 downto 0) & TxData(TxData'HIGH);
--      end if;
--		
--  end if;
--end process spip;
--
--end behav;
