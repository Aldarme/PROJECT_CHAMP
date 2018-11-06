-- Quartus II VHDL Template
-- Binary Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;

entity ASP_spi_accel is
	PORT
	(
		CLOCK_50   		:  IN STD_LOGIC;
		LEDG    			:  OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		LEDR    			:  OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		KEY    				:  IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
		GPIO_SPI_CLK	:	INOUT STD_LOGIC;
		GPIO_SPI_SS		:	INOUT STD_LOGIC;
		GPIO_SPI_SDIO	:	INOUT STD_LOGIC;
		DATA_OUT			:	out STD_LOGIC_VECTOR(19 DOWNTO 0);
		DATA_ENABLE		:	out STD_LOGIC;
		RESET_SIGNAL	:	in STD_LOGIC
	);

end entity;

architecture rtl of ASP_spi_accel is

COMPONENT ASP_spi_master
  GENERIC(
    slaves  		: INTEGER := 4;  	--number of spi slaves
    d_width 		: INTEGER := 2;		--data bus width
		accel_used	: NATURAL := 0);	--by default set on accelerometer ADXL355
  PORT(
    clock   : IN     STD_LOGIC;                             --system clock
    reset_n : IN     STD_LOGIC;                             --asynchronous reset
    enable  : IN     STD_LOGIC;                             --initiate transaction
    cpol    : IN     STD_LOGIC;                             --spi clock polarity
    cpha    : IN     STD_LOGIC;                             --spi clock phase
    cont    : IN     STD_LOGIC;                             --continuous mode command
    clk_div : IN     INTEGER;                               --system clock cycles, based on 1/2 period of clock (~10MHz -> 3 ; 100K -> 250)
    addr    : IN     INTEGER;                               --address of slave
    tx_data : IN     STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);	--data to transmit
    sclk    : BUFFER STD_LOGIC;                             --spi clock
    ss_n    : BUFFER STD_LOGIC_VECTOR(slaves-1 DOWNTO 0);   --slave select
    busy    : OUT    STD_LOGIC;                             --busy / data ready signal
    rx_data : OUT    STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);	--data received
	 MISOMOSI	: INOUT	STD_LOGIC
	);
END COMPONENT;

COMPONENT ASP_spi_master_Rw_adaptative_wordLenght
	GENERIC(
    slaves  : INTEGER := 0;	--number of spi slaves
    d_width : INTEGER := 0);	--data bus width 
	PORT(
    clock   : IN     STD_LOGIC;                             --system clock
    reset_n : IN     STD_LOGIC;                             --asynchronous reset
    enable  : IN     STD_LOGIC;                             --initiate transaction
    cpol    : IN     STD_LOGIC;                             --spi clock polarity
    cpha    : IN     STD_LOGIC;                             --spi clock phase
    cont    : IN     STD_LOGIC;                             --continuous mode command
    clk_div : IN     INTEGER;                               --system clock cycles, based on 1/2 period of clock
    addr    : IN     INTEGER;                               --address of slave
    tx_data : IN     STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data to transmit
    sclk    : BUFFER STD_LOGIC;                             --spi clock
    ss_n    : BUFFER STD_LOGIC_VECTOR(slaves-1 DOWNTO 0);   --slave select
    busy    : OUT    STD_LOGIC;                             --busy / data ready signal
    rx_data : OUT    STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      --data received
	 MISOMOSI	: INOUT 	STD_LOGIC
	);
END COMPONENT;

constant ACC_CONF : natural := 2; -- 0 = ADXL355 ; 1 = AIS3624 ; 2 = KX224 / Define the arch according to the used acc

signal reset_n : STD_LOGIC;
signal SampKey : STD_LOGIC_VECTOR(3 DOWNTO 0);

--Variables for ADXL355 & AIS3624 architecture
signal ss_n       : STD_LOGIC_VECTOR(0 DOWNTO 0);
signal spi_enable : STD_LOGIC;
signal spi_ss_n   :  STD_LOGIC_VECTOR(0 DOWNTO 0);
signal spi_busy   : STD_LOGIC;
signal spi_pbusy  : STD_LOGIC;
signal spi_busydn : STD_LOGIC;
signal spi_sclk   : STD_LOGIC;
signal spi_txdata : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal spi_rxdata : STD_LOGIC_VECTOR(15 DOWNTO 0);

--Variables for KX224 architecture
signal adapt_spi_txdata : STD_LOGIC_VECTOR(16 DOWNTO 0);
signal adapt_spi_rxdata : STD_LOGIC_VECTOR(16 DOWNTO 0);

signal spi_dataz  : STD_LOGIC_VECTOR(19 DOWNTO 0);
signal new_accel_data  : STD_LOGIC;
signal cptConf		: integer := 0;

-- signal spi_start_button : STD_LOGIC;

type   T_SPISTATE is ( RESETst, ACCESSCONFst, ACSCBUSYst, CONFst, CONFIDLEst, CONFBUSYst, IDLEst, TSTACCESS, TSTBUSY, READst, READBUSYst );
signal cState     : T_SPISTATE;

type    T_WORD_ARR is array (natural range <>) of std_logic_vector;

---
--- ADXL355 Registers addresses
---
constant BIT_READ_REG    	: std_logic := '1';
constant BIT_WRITE_REG   	: std_logic := '0';
constant AIS_MS_BIT				: std_logic := '0';
constant KX_EXTRA_BIT			: std_logic := '0';

constant ADXL_DATAZ1_ADD  : std_logic_vector(6 downto 0):=7x"0E";	
constant ADXL_DATAZ2_ADD  : std_logic_vector(6 downto 0):=7x"0F";
constant ADXL_DATAZ3_ADD  : std_logic_vector(6 downto 0):=7x"10";
constant ADXL_STATUS_ADD  : std_logic_vector(6 downto 0):=7x"04";

constant AIS_DATAZ1_L	  	: std_logic_vector(5 downto 0):=6x"2C";
constant AIS_DATAZ2_H	  	: std_logic_vector(5 downto 0):=6x"2D";

constant KX_DATAZ1_L	  	: std_logic_vector(6 downto 0):=7x"0A";
constant KX_DATAZ2_H		  : std_logic_vector(6 downto 0):=7x"0B";

constant SPI_ADD_FIELD    : std_logic_vector(15 downto 8):=(others=>'0');
constant SPI_DATA_FIELD   : std_logic_vector(7 downto 0):=(others=>'0');

constant ACCEL_CONFIG_ADXL355 : T_WORD_ARR := (
			7x"2D" & BIT_WRITE_REG & 8x"01",		--initiate protocol to configure registers (standby <- 1 : standby mode)
			7x"2F" & BIT_WRITE_REG & 8x"52",		--Power-on reset, code 0x52		
			7x"2C" & BIT_WRITE_REG & 8x"03",		--G range [+-8g : 3] ; [+- 4g : 2] ; [+-2g : 1] ; [disable : 0]
			7x"28" & BIT_WRITE_REG & 8x"02",		--No high-pass filter & ODR = 1KHz with low-pass filter = 250Hz
			7x"2D" & BIT_WRITE_REG & 8x"00"			--End protocol to configure registers (standby mode <- 0 : mesurement mode)
			);
			
constant ACCEL_READ_ADXL355 : T_WORD_ARR := (
			ADXL_DATAZ1_ADD & BIT_READ_REG & 8x"00", -- 2100h -- DATAZ1 (MSB)
			ADXL_DATAZ2_ADD & BIT_READ_REG & 8x"00", -- 1F00h -- DATAZ2
			ADXL_DATAZ3_ADD & BIT_READ_REG & 8x"00", -- 1D00h -- DATAZ3 (LSB)
			ADXL_STATUS_ADD & BIT_READ_REG & 8x"04"  -- 0904h -- NVM_BUSY to check if memory can be access
			);
			
constant ACCEL_CONFIG_AIS3634 : T_WORD_ARR := (
			BIT_WRITE_REG & AIS_MS_BIT & 6x"20" & 8x"3C",	-- 203Ch -- ODR to 1Khz and axes enable
			BIT_WRITE_REG & AIS_MS_BIT & 6x"23" & 8x"B1"	-- 23B1h -- secure data between L&H register data Z & SCALE & SPI 3 wires enable
			);
			
constant ACCEL_READ_AIS3634 : T_WORD_ARR := (
			BIT_READ_REG & AIS_MS_BIT & 6x"2C" & 8x"00", -- AC00h -- OUT_Z_L (LSB)
			BIT_READ_REG & AIS_MS_BIT & 6x"2D" & 8x"00"	 -- AD00h -- OUT_Z_H (MSB)
			);
			
constant ACCEL_CONFIG_KX224 : T_WORD_ARR := (
			BIT_WRITE_REG & 7x"18" & 8x"00", -- 03000h -- Standby mode
			BIT_WRITE_REG & 7x"18" & 8x"50", -- 030A0h -- Set definition to 32g
			BIT_WRITE_REG & 7x"1B" & 8x"07", -- 0360Eh -- ODR defined at 1600Hz
			BIT_WRITE_REG & 7x"1C" & 8x"01", -- 03802h -- enable SPI 3 wires
			BIT_WRITE_REG & 7x"18" & 8x"D0"	 -- 031A0h -- Operating mode
			);
			
constant ACCEL_READ_KX224 : T_WORD_ARR := (
			BIT_READ_REG & 7x"0A" & 1x"0" & 8x"00",	-- 1140h -- OUT_Z_L (LSB)
			BIT_READ_REG & 7x"0B" & 1x"0" & 8x"00"	-- 1160h -- OUT_Z_H (MSB)
			);
			
signal ConfAddress: natural;

constant CLOCK_50_FREQ 			: real:=50.0E6;
signal   spi_read_cpt_zero	: std_logic;
signal   spi_read_restart  	: std_logic;


------------------------------------------------------------------------------------------------------------------
--
	BEGIN
--
------------------------------------------------------------------------------------------------------------------


LEDG( 0 ) <= not KEY(0);
LEDG( 3 ) <= not KEY(3);

LEDG( 1 ) <= not spi_busy;

reset_n <= RESET_SIGNAL;

GPIO_SPI_CLK	<= spi_sclk;		--GPIO(1)
GPIO_SPI_SS		<= spi_ss_n(0);	--GPIO(3)

LEDR	<= spi_dataz(19 downto 2);
LEDG(7 downto 6)	<= spi_dataz(1 downto 0);


-- Adaptative architecture according to the used accelerometer

--
-- Generate configuration for ADXL355 Accelerometer
--
ADXL355_gen_arch : if ACC_CONF = 0 generate
		
		constant SPI_READ_FREQ 			: real:=1.0E3;
		constant SPI_READ_NCLK 			: natural:=natural( ceil(CLOCK_50_FREQ/SPI_READ_FREQ) );
		signal   spi_read_cpt  			: natural range 0 to SPI_READ_NCLK;
		
	begin
		
		sm_accel: entity work.ASP_spi_master(SPI_ACCEL)
			GENERIC MAP (
			 slaves 		=> 1,
			 d_width		=> 16,
			 accel_used	=> ACC_CONF
			 )
			PORT MAP(
			 clock    => CLOCK_50,
			 reset_n  => reset_n,
			 enable   => spi_enable,
			 cpol     => '0',									--spi clock polarity	- ADXL355:	0	- AIS3624:	1	- KX224:	0
			 cpha     => '0',                 --spi clock phase			-		 				0	-						1	-					0
			 cont     => '0',                 --continuous mode command
			 clk_div  => 5,										--system clock cycles, based on 1/2 period of clock (~10MHz -> 3 ; 100K -> 250)
			 addr     => 0,                   --address of slave
			 tx_data  => spi_txdata,          --data to transmit
			 sclk     => spi_sclk,            --spi clock
			 ss_n     => spi_ss_n,            --slave select
			 busy     => spi_busy,            --busy / data ready signal
			 rx_data  => spi_rxdata,					--data received
			 MISOMOSI => GPIO_SPI_SDIO				--GPIO(2)
			);
			
		samp: process(reset_n, CLOCK_50) is
				
			begin 
				if(reset_n = '0') then
					SampKey <= ( others=> '1' );
				elsif(rising_edge(CLOCK_50)) then
					SampKey <= KEY;
				end if;
		end process samp;
				
		rcpt: process(reset_n, CLOCK_50) is
				
			begin 
				if(reset_n = '0') then
					spi_read_cpt      <= 0;
					spi_read_cpt_zero <= '1';
				elsif(rising_edge(CLOCK_50)) then
					if spi_read_restart='1' then
						spi_read_cpt <= SPI_READ_NCLK;
						spi_read_cpt_zero <= '0';
					else
						if spi_read_cpt/=0 then
							spi_read_cpt <= spi_read_cpt-1;
							spi_read_cpt_zero <= '0';
						else
							spi_read_cpt_zero <= '1';
						end if;
					end if;
				end if;
		end process rcpt;
				
		statep: process( reset_n, CLOCK_50 )
				
			begin
				if reset_n='0' then
					cState <= RESETst;
					ConfAddress <= 0;
					spi_enable <= '0';
					spi_pbusy <= '1';
					spi_dataz <= ( others=> '0');
					new_accel_data <= '0';
					spi_read_restart <= '0';
					
				elsif rising_edge(CLOCK_50) then
					case cState is
					
						when RESETst =>
							DATA_ENABLE <= '0';
							ConfAddress <= 0;
							spi_enable <= '0';
							spi_dataz <= ( others=> '0');
							new_accel_data <= '0';
							spi_read_restart <= '0';
							cState <= CONFst;
							
						when CONFst =>
							spi_enable <= '1';
							spi_txdata <= ACCEL_CONFIG_ADXL355(ConfAddress);
							cState <= CONFIDLEst;
							--cState <= CONFBUSYst;
							
						when CONFIDLEst =>
							if cptConf >= 8000 then			-- 180us between to access config register - 50MHz <-> 0.02 us
								cptConf <= cptConf +1;		-- 180 us = 0.02 * 9000
								cState <= CONFIDLEst;			-- Need to decrease the NVM access périod to below than 170 us -> 160 us <=> 8000
							else
								cptConf <= 0;
								cState <= CONFBUSYst;
							end if;
							
						when CONFBUSYst =>
							spi_enable <= '0';
							if spi_busydn='1' then
								if ConfAddress=ACCEL_CONFIG_ADXL355'LENGTH-1 then
									cState <=  IDLEst;
								else
									ConfAddress <= ConfAddress+1;
									cState <= CONFst;
								end if;
							else
								cState <= CONFBUSYst;
							end if;
							
						when IDLEst =>
							DATA_ENABLE <= '0';
							ConfAddress <= 0;
							spi_enable <= '0';
							if spi_read_cpt_zero='1' then
								spi_read_restart <= '1';
								cState <= TSTACCESS;
							end if;
							new_accel_data <= '0';
							
						when TSTACCESS =>
							DATA_ENABLE <= '0';
							spi_read_restart <= '0';
							spi_enable <= '1';
							spi_txdata <= ACCEL_READ_ADXL355(3);
							cState <= TSTBUSY;
							
						when TSTBUSY =>
							DATA_ENABLE <= '0';
							spi_enable <= '0';
							if spi_busydn='1' then
								if spi_rxdata = "1" then
									cState	<= TSTACCESS;
								else
									cState <= READst;
								end if;
							else
								cState <= TSTBUSY;
							end if;
							
						when READst =>
							DATA_ENABLE <= '0';
							spi_read_restart <= '0';
							spi_enable <= '1';
							spi_txdata <= ACCEL_READ_ADXL355(ConfAddress);
							cState <= READBUSYst;
							
						when READBUSYst =>
							DATA_ENABLE <= '0';
							spi_enable <= '0';
							if spi_busydn='1' then
							
								case spi_txdata( SPI_ADD_FIELD'RANGE ) is
								
									when ADXL_DATAZ1_ADD & BIT_READ_REG =>
										spi_dataz(19 downto 12)	<= spi_rxdata( 7 downto 0 );
										
									when ADXL_DATAZ2_ADD & BIT_READ_REG =>
										spi_dataz(11 downto 4)	<= spi_rxdata( 7 downto 0 );
										
									when ADXL_DATAZ3_ADD & BIT_READ_REG =>
										spi_dataz(3 downto 0 )	<= spi_rxdata( 7 downto 4 );
										
									when others =>
										null; --modif null to delete latch
										
								end case;
								
								if ConfAddress=ACCEL_READ_ADXL355'LENGTH-1 then
									new_accel_data <= '1';
									DATA_ENABLE <= '1';
									DATA_OUT <= spi_dataz;
									cState <=  IDLEst;
								else
									ConfAddress <= ConfAddress+1;
									cState <= TSTACCESS;
								end if;
							else
								cState <= READBUSYst;
							end if;
							
						when others =>
							cState <= RESETst;
							
					end case;
					
					if cState=RESETst then
						spi_pbusy  <= '0';
					else
						spi_pbusy  <= spi_busy;
					end if;
					spi_busydn <= not spi_busy and spi_pbusy;
				end if;
		end process statep;
		
end generate ADXL355_gen_arch;

--
-- Generate configuration for AIS3624 Accelerometer
--
AIS3624_gen_arch : if ACC_CONF = 1 generate
		
		constant SPI_READ_FREQ 			: real:=1.0E3;
		constant SPI_READ_NCLK 			: natural:=natural( ceil(CLOCK_50_FREQ/SPI_READ_FREQ) );
		signal   spi_read_cpt  			: natural range 0 to SPI_READ_NCLK;
		
	begin
		
		sm_ais: entity work.ASP_spi_master(SPI_ACCEL)
			GENERIC MAP (
			 slaves  => 1,
			 d_width => 16
			 )
			PORT MAP(
			 clock    => CLOCK_50,
			 reset_n  => reset_n,
			 enable   => spi_enable,
			 cpol     => '1',									--spi clock polarity	- ADXL355:	0	- AIS3624:	1	- KX224:	0
			 cpha     => '1',                 --spi clock phase			- 					0	-						1	-					0
			 cont     => '0',                 --continuous mode command
			 clk_div  => 5,										--system clock cycles, based on 1/2 period of clock (~10MHz -> 3 ; 100K -> 250)
			 addr     => 0,                   --address of slave
			 tx_data  => spi_txdata,          --data to transmit
			 sclk     => spi_sclk,            --spi clock
			 ss_n     => spi_ss_n,            --slave select
			 busy     => spi_busy,            --busy / data ready signal
			 rx_data  => spi_rxdata,					--data received
			 MISOMOSI => GPIO_SPI_SDIO				--GPIO(2)
			);
			
		samp: process(reset_n, CLOCK_50) is
				
			begin 
				if(reset_n = '0') then
					SampKey <= ( others=> '1' );
				elsif(rising_edge(CLOCK_50)) then
					SampKey <= KEY;
				end if;
		end process samp;
				
		rcpt: process(reset_n, CLOCK_50) is
				
			begin 
				if(reset_n = '0') then
					spi_read_cpt      <= 0;
					spi_read_cpt_zero <= '1';
				elsif(rising_edge(CLOCK_50)) then
					if spi_read_restart='1' then
						spi_read_cpt <= SPI_READ_NCLK;
						spi_read_cpt_zero <= '0';
					else
						if spi_read_cpt/=0 then
							spi_read_cpt <= spi_read_cpt-1;
							spi_read_cpt_zero <= '0';
						else
							spi_read_cpt_zero <= '1';
						end if;
					end if;
				end if;
		end process rcpt;
			
		statep: process( reset_n, CLOCK_50 )
				
			begin
				if reset_n ='0' then
					cState <= RESETst;
					ConfAddress <= 0;
					spi_enable <= '0';
					spi_pbusy <= '1';
					spi_dataz <= ( others=> '0');
					new_accel_data <= '0';
					spi_read_restart <= '0';
					
				elsif rising_edge(CLOCK_50) then
					case cState is
					
						when RESETst =>
							DATA_ENABLE <= '0';
							ConfAddress <= 0;
							spi_enable <= '0';
							spi_dataz <= ( others=> '0');
							new_accel_data <= '0';
							spi_read_restart <= '0';
							cState <= CONFst;
							
						when CONFst =>
							spi_enable <= '1';
							spi_txdata <= ACCEL_CONFIG_AIS3634(ConfAddress);
							cState <= CONFBUSYst;
							
						when CONFBUSYst =>
							spi_enable <= '0';
							if spi_busydn ='1' then
								if ConfAddress = ACCEL_CONFIG_AIS3634'LENGTH-1 then
									cState <=  IDLEst;
								else
									ConfAddress <= ConfAddress+1;
									cState <= CONFst;
								end if;
							else
								cState <= CONFBUSYst;
							end if;
							
						when IDLEst =>
							DATA_ENABLE <= '0';
							ConfAddress <= 0;
							spi_enable <= '0';
							if spi_read_cpt_zero='1' then
								spi_read_restart <= '1';
								cState <= READst;
							end if;
							new_accel_data <= '0';
							
						when READst =>
							spi_read_restart <= '0';
							spi_enable <= '1';
							spi_txdata <= ACCEL_READ_AIS3634(ConfAddress);
							cState <= READBUSYst;
							
						when READBUSYst =>
							DATA_ENABLE <= '0';
							spi_enable <= '0';
							if spi_busydn='1' then
							
								case spi_txdata( SPI_ADD_FIELD'RANGE ) is
								
									when BIT_READ_REG & AIS_MS_BIT & AIS_DATAZ2_H =>
										spi_dataz(15 downto 8)	<= spi_rxdata( 7 downto 0 );
										
									when BIT_READ_REG & AIS_MS_BIT & AIS_DATAZ1_L =>
										spi_dataz(7 downto 0)	<= spi_rxdata( 7 downto 0 );
										
									when others =>
										null; --modif null to delete latch
										
								end case;
								
								if ConfAddress=ACCEL_READ_AIS3634'LENGTH-1 then
									new_accel_data <= '1';
									DATA_ENABLE <= '1';
									DATA_OUT <= spi_dataz;
									cState <=  IDLEst;
								else
									ConfAddress <= ConfAddress+1;
									cState <= READst;
								end if;
							else
								cState <= READBUSYst;
							end if;
							
						when others =>
							cState <= RESETst;
							
					end case;
					
					if cState=RESETst then
						spi_pbusy  <= '0';
					else
						spi_pbusy  <= spi_busy;
					end if;
					spi_busydn <= not spi_busy and spi_pbusy;
				end if;
		end process statep;
		
end generate AIS3624_gen_arch;

--
-- Generate configuration for KX224 Accelerometer
--
KX224_gen_arch : if ACC_CONF = 2 generate
		
		constant SPI_READ_FREQ 			: real:=1.6E3;
		constant SPI_READ_NCLK 			: natural:=natural( ceil(CLOCK_50_FREQ/SPI_READ_FREQ) );
		signal   spi_read_cpt  			: natural range 0 to SPI_READ_NCLK;
		
	begin
		
		sm_kx: ASP_spi_master_Rw_adaptative_wordLenght
				GENERIC MAP (
				slaves   =>	1,	--number of spi slaves
				d_width =>	17	--data bus width 
				)
				PORT MAP(
				 clock    => CLOCK_50,
				 reset_n  => reset_n,
				 enable   => spi_enable,
				 cpol     => '0',									--spi clock polarity	- ADXL355:	0	- AIS3624:	1	- KX224:	0
				 cpha     => '0',                 --spi clock phase		- 				0	-				1	-			0
				 cont     => '0',                 --continuous mode command
				 clk_div  => 5,										--system clock cycles, based on 1/2 period of clock (~10MHz -> 3 ; 100K -> 250)
				 addr     => 0,                   --address of slave
				 tx_data  => adapt_spi_txdata,    --data to transmit
				 sclk     => spi_sclk,            --spi clock
				 ss_n     => spi_ss_n,            --slave select
				 busy     => spi_busy,            --busy / data ready signal
				 rx_data  => adapt_spi_rxdata,		--data received
				 MISOMOSI => GPIO_SPI_SDIO				--GPIO(2)
				);
				
		samp: process(reset_n, CLOCK_50) is
				
			begin 
				if(reset_n = '0') then
					SampKey <= ( others=> '1' );
				elsif(rising_edge(CLOCK_50)) then
					SampKey <= KEY;
				end if;
		end process samp;
				
		rcpt: process(reset_n, CLOCK_50) is
				
			begin 
				if(reset_n = '0') then
					spi_read_cpt      <= 0;
					spi_read_cpt_zero <= '1';
				elsif(rising_edge(CLOCK_50)) then
					if spi_read_restart='1' then
						spi_read_cpt <= SPI_READ_NCLK;
						spi_read_cpt_zero <= '0';
					else
						if spi_read_cpt/=0 then
							spi_read_cpt <= spi_read_cpt-1;
							spi_read_cpt_zero <= '0';
						else
							spi_read_cpt_zero <= '1';
						end if;
					end if;
				end if;
		end process rcpt;
			
		statep: process( reset_n, CLOCK_50 )
			
			begin
				if reset_n='0' then
					cState <= RESETst;
					ConfAddress <= 0;
					spi_enable <= '0';
					spi_pbusy <= '1';
					spi_dataz <= ( others=> '0');
					new_accel_data <= '0';
					spi_read_restart <= '0';
					
				elsif rising_edge(CLOCK_50) then
					case cState is
						
						when RESETst =>
							DATA_ENABLE <= '0';
							ConfAddress <= 0;
							spi_enable <= '0';					
							spi_dataz <= ( others=> '0');
							new_accel_data <= '0';
							spi_read_restart <= '0';
							cState <= CONFst;
							
						when CONFst =>
							spi_enable <= '1';
							adapt_spi_txdata <= ACCEL_CONFIG_KX224(ConfAddress)&'0';
							cState <= CONFBUSYst;
							
						when CONFBUSYst =>
							spi_enable <= '0';
							if spi_busydn ='1' then
								if ConfAddress = ACCEL_CONFIG_KX224'LENGTH-1 then
									cState <=  IDLEst;
								else
									ConfAddress <= ConfAddress+1;
									cState <= CONFst;
								end if;
							else
								cState <= CONFBUSYst;
							end if;
							
						when IDLEst =>
							DATA_ENABLE <= '0';
							ConfAddress <= 0;
							spi_enable <= '0';
							if spi_read_cpt_zero='1' then
								spi_read_restart <= '1';
								cState <= READst;
							end if;
							new_accel_data <= '0';
							
						when READst =>
							spi_read_restart <= '0';
							spi_enable <= '1';
							adapt_spi_txdata <= ACCEL_READ_KX224(ConfAddress);
							cState <= READBUSYst;
							
						when READBUSYst =>
							DATA_ENABLE <= '0';
							spi_enable <= '0';
							if spi_busydn='1' then
									
								case adapt_spi_txdata( SPI_ADD_FIELD'RANGE ) is
									
									when BIT_READ_REG & KX_DATAZ2_H =>
										spi_dataz(15 downto 8)	<= adapt_spi_rxdata( 7 downto 0 ); --ne pas oublier de gérer le EXTRA BIT
										
									when BIT_READ_REG & KX_DATAZ1_L =>
										spi_dataz(7 downto 0)	<= adapt_spi_rxdata( 7 downto 0 ); 	 --ne pas oublier de gérer le EXTRA BIT
										
									when others =>
										null; --modif null to delete latch
										
								end case;
									
								if ConfAddress=ACCEL_READ_KX224'LENGTH-1 then
									new_accel_data <= '1';
									DATA_ENABLE <= '1';
									DATA_OUT <= spi_dataz;
									cState <=  IDLEst;
								else
									ConfAddress <= ConfAddress+1;
									cState <= READst;
								end if;
							else
								cState <= READBUSYst;
							end if;
							
						when others =>
							cState <= RESETst;
							
					end case;
					
					if cState=RESETst then
						spi_pbusy  <= '0';
					else
						spi_pbusy  <= spi_busy;
					end if;
					spi_busydn <= not spi_busy and spi_pbusy;
				end if;
		end process statep;
		
end generate KX224_gen_arch;

end rtl;