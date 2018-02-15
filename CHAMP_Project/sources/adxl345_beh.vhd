----------------------------------------------------------------
--   Title     :  ADXL345 Behavioral model
----------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.MATH_REAL.all;

entity adxl345_beh is
	 generic(
		SIZE   : INTEGER:=13; -- 13 bits data
		ARANGE : REAL:=16.0 -- +-16g
	 );
	 port(
	   SCLK : in  STD_LOGIC;
	   CSB  : in  STD_LOGIC;
	   SDI  : in  STD_LOGIC;
	   SDO  : out STD_LOGIC
	     );
end entity;

--}} End of automatically maintained section

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.MATH_REAL.all;



architecture behav of adxl345_beh is

-- SPI Interface
signal iBit        : integer;
signal isAddress   : std_logic;
signal ReadWriteB  : std_logic;
signal Instruction : std_logic_vector( 7 downto 0);
signal TxData      : std_logic_vector( 7 downto 0);
signal RxData      : std_logic_vector( 7 downto 0);
signal SpiReg      : std_logic_vector( 7 downto 0);

---
--- ADXL345 Registers addresses
---
constant ADXL_READ_REG    : std_logic_vector(1 downto 0):="10";
constant ADXL_WRITE_REG   : std_logic_vector(1 downto 0):="00";
constant ADXL_DATAZ0_ADD  : std_logic_vector(5 downto 0):=6x"36";
constant ADXL_DATAZ1_ADD  : std_logic_vector(5 downto 0):=6x"37";
constant SPI_ADD_FIELD    : std_logic_vector(15 downto 8):=(others=>'0');
constant SPI_DATA_FIELD   : std_logic_vector(7 downto 0):=(others=>'0');

--
-- ADXL345
--
constant ADXL_DATA_RATE : REAL:= 3.4E3; -- 3400 Hz
constant ADXL_DATA_PER  : REAL:= 1.0/ ADXL_DATA_RATE;
signal   Z              : REAL;

constant GMAX : REAL:=2.0**(SIZE-1) - 1.0;
constant GMIN : REAL:=-2.0**(SIZE-1);

signal   dataz_word     : std_logic_vector(15 downto 0);
alias dataz0 is dataz_word( 7 downto 0);
alias dataz1 is dataz_word(15 downto 8);
signal   dataz : std_logic_vector(SIZE-1 downto 0);
begin

measp: process
    variable ti: REAL:=0.0;
    variable ReflSine : REAL:=0.0;
	variable vZ : REAL;
  begin
	vZ := 15.0 * SIN( 2.0*MATH_PI*100.0*ti); -- +-15g sin, freq 100 Hz
	Z <= vZ;
	vZ := floor( GMAX * vZ / ARANGE );
	dataz <= Conv_Std_Logic_Vector(Integer(vZ),SIZE);
    
    ti := ti + ADXL_DATA_PER;
    wait for ADXL_DATA_PER * 1 sec;
end process measp;

-- dataz_word <= SXT( dataz, dataz_word'LENGTH );
dataz_word <= EXT( dataz, dataz_word'LENGTH );

SDO <= 'Z';
	
spip: process( CSB, SCLK )
variable vInst : std_logic_vector(Instruction'RANGE);
begin
  if CSB='1' then
      SDO        <= 'Z';
      isAddress   <= '1';
      ReadWriteB  <= '0';
      iBit        <= 0;
      Instruction <= (others=>'U');
      TxData      <= (others=>'U');
      if rising_edge(CSB) then SpiReg <= RxData + '1'; end if;
  elsif rising_edge(SCLK) then
      if isAddress='1' then
         if iBit=0 and isAddress='1' then ReadWriteB <= SDI; end if;
         vInst := Instruction(Instruction'HIGH-1 downto 0) & SDI;
         Instruction <= vInst;
         if iBit=Instruction'HIGH then
            isAddress <= '0';
            iBit <= 0;
			case vInst(ADXL_DATAZ0_ADD'RANGE) is
				when ADXL_DATAZ0_ADD =>
					TxData <= dataz0;

				when ADXL_DATAZ1_ADD =>
					TxData <= dataz1;

				when others =>
					TxData <= SpiReg;
					
			end case;
         else
            iBit <= iBit+1;
         end if;
      else
         if ReadWriteB='0' then
            RxData <= RxData(RxData'HIGH-1 downto 0) & SDI ;
            iBit   <= iBit+1;
         end if;
      end if;
  elsif falling_edge(SCLK) then
      if isAddress='0' and ReadWriteB='1' then
          SDO   <= TxData(TxData'HIGH);
          TxData <= TxData(TxData'HIGH-1 downto 0) & TxData(TxData'HIGH);
      end if;
  end if;
end process spip;


end behav;
