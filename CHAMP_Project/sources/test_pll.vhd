-- Quartus Prime VHDL Template
-- Basic Shift Register

library ieee;
use ieee.std_logic_1164.all;

entity test_pll is

		-- port (
			-- refclk   : in  std_logic := 'X'; -- clk
			-- rst      : in  std_logic := 'X'; -- reset
			-- outclk_0 : out std_logic;        -- clk
			-- outclk_1 : out std_logic;        -- clk
			-- locked   : out std_logic         -- export
		-- );

end entity;

architecture rtl of test_pll is
	signal	refclk   : std_logic := '0';
	signal	rst      : std_logic := 'X'; -- reset
	signal	outclk_0 : std_logic;        -- clk
	signal	outclk_1 : std_logic;        -- clk
	signal	outclk_2 : std_logic;        -- clk
	signal	outclk_3 : std_logic;        -- clk
	signal	locked   : std_logic;        -- export
	signal	phase_en   : std_logic                    := '0';             --   phase_en.phase_en
--	signal	scanclk    : std_logic                    := '0';             --    scanclk.scanclk
	signal	updn       : std_logic                    := '0';             --       updn.updn
	signal	cntsel     : std_logic_vector(4 downto 0) := (others => '0'); --     cntsel.cntsel
	signal	phase_done : std_logic;                                        -- phase_done.phase_done

	alias CLOCK50 is refclk;
	signal reset_n : std_logic;

	signal spi_enable : STD_LOGIC;
	signal spi_busy   : STD_LOGIC;
	signal spi_pbusy  : STD_LOGIC;
	signal spi_busydn : STD_LOGIC;
	signal spi_sclk   : STD_LOGIC;
	signal mosi       : STD_LOGIC;
	signal miso       : STD_LOGIC;
	signal spi_txdata : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal spi_rxdata : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal spi_ss_n   : STD_LOGIC_VECTOR(0 DOWNTO 0);
	
	signal spi_start_button : STD_LOGIC;
	
	type   T_SPISTATE is ( RESETst, CONFst, CONFBUSYst, IDLEst );
	signal cState     : T_SPISTATE;
	
	type    T_WORD_ARR is array (natural range <>) of std_logic_vector;
	constant ACCEL_CONFIG : T_WORD_ARR:= (
			"00" & 14x"00AA",
			"00" & 14x"2C55",
			"00" & 14x"1B12",
			"00" & 14x"1AFE" );
	signal ConfAddress: integer range 0 to ACCEL_CONFIG'LENGTH-1;
	
--	component mypll is
--	port (
--		refclk     : in  std_logic                    := '0';             --     refclk.clk
--		rst        : in  std_logic                    := '0';             --      reset.reset
--		outclk_0   : out std_logic;                                       --    outclk0.clk
--		outclk_1   : out std_logic;                                       --    outclk1.clk
--		locked     : out std_logic;                                       --     locked.export
--		phase_en   : in  std_logic                    := '0';             --   phase_en.phase_en
--		scanclk    : in  std_logic                    := '0';             --    scanclk.scanclk
--		updn       : in  std_logic                    := '0';             --       updn.updn
--		cntsel     : in  std_logic_vector(4 downto 0) := (others => '0'); --     cntsel.cntsel
--		phase_done : out std_logic                                        -- phase_done.phase_done
--	);
--	end component mypll;

	component PLLADC50 is
	port (
		refclk     : in  std_logic                    := '0';             --     refclk.clk
		rst        : in  std_logic                    := '0';             --      reset.reset
		outclk_0   : out std_logic;                                       --    outclk0.clk
		outclk_1   : out std_logic;                                       --    outclk1.clk
		outclk_2   : out std_logic;                                       --    outclk2.clk
		outclk_3   : out std_logic;                                       --    outclk3.clk
		locked     : out std_logic;                                       --     locked.export
		phase_en   : in  std_logic                    := '0';             --   phase_en.phase_en
		scanclk    : in  std_logic                    := '0';             --    scanclk.scanclk
		updn       : in  std_logic                    := '0';             --       updn.updn
		cntsel     : in  std_logic_vector(4 downto 0) := (others => '0'); --     cntsel.cntsel
		phase_done : out std_logic                                        -- phase_done.phase_done
	);
	end component PLLADC50;

	COMPONENT spi_master
		GENERIC ( slaves : INTEGER := 4; d_width : INTEGER := 2 );
		PORT
		(
			clock		:	 IN STD_LOGIC;
			reset_n		:	 IN STD_LOGIC;
			enable		:	 IN STD_LOGIC;
			cpol		:	 IN STD_LOGIC;
			cpha		:	 IN STD_LOGIC;
			cont		:	 IN STD_LOGIC;
			clk_div		:	 IN INTEGER;
			addr		:	 IN INTEGER;
			tx_data		:	 IN STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);
			miso		:	 IN STD_LOGIC;
			sclk		:	 OUT STD_LOGIC;
			ss_n		:	 OUT STD_LOGIC_VECTOR(slaves-1 DOWNTO 0);
			mosi		:	 OUT STD_LOGIC;
			busy		:	 OUT STD_LOGIC;
			rx_data		:	 OUT STD_LOGIC_VECTOR(d_width-1 DOWNTO 0)
		);
	END COMPONENT;

begin
	mypll_inst : PLLADC50
		port map (
			refclk   => refclk,   --  refclk.clk
			rst      => rst,      --   reset.reset
			outclk_0 => outclk_0, -- outclk0.clk
			outclk_1 => outclk_1, -- outclk1.clk
			outclk_2 => outclk_2, -- outclk2.clk
			outclk_3 => outclk_3, -- outclk3.clk
			locked   => locked,    --  locked.export
			phase_en => phase_en,
			scanclk  => refclk,
			updn     => updn,
			cntsel   => cntsel,
			phase_done => phase_done
		);
		
--	refclk <= not refclk after 5 ns;
	refclk <= not refclk after 7.5 ns;
	rst    <= '1', '0' after 331.3 ns;
	cntsel <= "00010";
	updn   <= '1';
	phase_en <= '0',
			'1' after 3 us,
			'0' after 3.5 us,
			'1' after 4 us;
			
	reset_n <= not rst;
	
	spi_start_button <= '0', '1' after 500 ns, '0' after 600 ns;
	miso <= 'L';
	
	edgep : process( reset_n, CLOCK50 )
	variable button, pbutton: STD_LOGIC;
	begin
		if reset_n='0' then
			button  := '0';
			pbutton := '0';
		elsif rising_edge(CLOCK50) then
			-- spi_enable <= button and not pbutton;
			pbutton := button;
			button  := spi_start_button;
		end if;
	end process edgep;
	
	
	--
	-- Accelerometer state machine
	--
	statep: process( reset_n, CLOCK50 )
	begin
		if reset_n='0' then
			cState <= RESETst;
			ConfAddress <= 0;
			spi_enable <= '0';
			spi_pbusy <= '1';
		elsif rising_edge(CLOCK50) then
			case cState is
				when RESETst =>
					ConfAddress <= 0;
					spi_enable <= '0';
					cState <= CONFst;
					
				when CONFst =>
					spi_enable <= '1';
					spi_txdata <= ACCEL_CONFIG(ConfAddress);
					cState <= CONFBUSYst;
				
				when CONFBUSYst =>
					spi_enable <= '0';
					if spi_busydn='1' then
						if ConfAddress=ACCEL_CONFIG'LENGTH-1 then
							cState <=  IDLEst;
						else
							ConfAddress <= ConfAddress+1;
							cState <= CONFst;
						end if;
					else
						cState <= CONFBUSYst;
					end if;
					
				when others =>
					null;
			end case;
			
			if cState=RESETst then
				spi_pbusy  <= '0';
			else
				spi_pbusy  <= spi_busy;
			end if;
			spi_busydn <= not spi_busy and spi_pbusy;
		end if;
		
	end process statep;
	
	spim : spi_master
		generic map (
			slaves  => 1,
			d_width => 16 )
		port map (
			clock		=> CLOCK50,
			reset_n		=> reset_n,
			enable		=> spi_enable,
			cpol		=> '1',
			cpha		=> '1',
			cont		=> '0',
			clk_div		=> 10,
			addr		=> 0,
			tx_data		=> spi_txdata,
			miso		=> miso,
			sclk		=> spi_sclk,
			ss_n		=> spi_ss_n,
			mosi		=> mosi,
			busy		=> spi_busy,
			rx_data		=> spi_rxdata
		);
	

end rtl;
