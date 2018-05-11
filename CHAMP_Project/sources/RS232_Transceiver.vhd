-------------------------------------------------------
--
--	This Documents describe the usage of tranceiver to
--	connect to the UART protocol to transmit data and 
--	get incoming data.
--	Used on RS232 communication
--
--	Author: ROMET Pierre
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity uart_transceiver is
generic
(
	wordLength : integer := 24
);
port
(
	reset						: in std_logic;
	clock						: in std_logic;
	oe_transmit			: in std_logic;
	dataToTransmit	: in std_logic_vector(23 downto 0);
	oe_incData			:	out std_logic;
	incomingData		:	out std_logic_vector(23 downto 0)
);
end uart_transceiver;

-------------------------------------------------------
--
--	Tx transceiver architecture
--
-------------------------------------------------------
architecture tx_trcver of uart_transceiver is

	--Component uart_tx
	component rs232_uart
		Generic
		(
			baudRate : integer := 0
		);	
		Port
		(
			clock 				: in std_logic;
			reset					: in std_logic;
			uartOeTx_in		: in std_logic;
			uartOeTx_done	: out std_logic;
			uartIn 				: in std_logic_vector(7 downto 0);
			uartOeRx_out	: out std_logic;
			uartOut				: out std_logic_vector(7 downto 0);
			uart_rx				: in std_logic;														-- Port to link with PIN_G12
			uart_tx				: out std_logic														-- Port to link with PIN_G9		
		);
	end component;
	
	type state is (IdleSt, DataLoadingSt, Acqutmt);
	signal txState : state;	
	
	signal ut_clock 				: std_logic;
	signal ut_reset					: std_logic;
	signal ut_uartOeTx_in		: std_logic;
	signal ut_uartOeTx_done	: std_logic;
  signal ut_uartIn 				: std_logic_vector(7 downto 0);
  signal ut_uartOeRx_out	: std_logic;
  signal ut_uartOut				: std_logic_vector(7 downto 0);
  signal ut_uart_rx				: std_logic; 										-- Port to link with PIN_G12
  signal ut_uart_tx				: std_logic;						     		-- Port to link with PIN_G9
	
	constant 	wordsize				: integer := 8;
	constant 	nbrofiteration	: integer := wordLength / wordsize;
	signal 		idxMin	: integer := 0;
	signal		idxMax	: integer := 0;
	signal		cptOfWord : integer := 0;
	
	begin
	
	ut_uartOeTx_in <= oe_transmit;

	tx_uart: entity work.rs232_uart(uart_tx)
		Generic map
		(
			baudRate => 115200
		)
		Port map
		(
			clock 				=> ut_clock,
			reset					=> ut_reset,
			uartOeTx_in		=> ut_uartOeTx_in,
			uartOeTx_done	=> ut_uartOeTx_done,
			uartIn 				=> ut_uartIn,					-- dataIn (Tx)
			uartOeRx_out	=> ut_uartOeRx_out,
			uartOut				=> ut_uartOut,				-- dataOut (Rx)
			uart_rx				=> ut_uart_rx,				-- Port to link with PIN_G12
			uart_tx				=> ut_uart_tx         -- Port to link with PIN_G9
		);
	
--	Process to send data.
--	Enter a word with a define length,and it will be cut
--	into 8 bits word to be transmit on the uart protocol
	tx_trv : process(reset, clock)
	
		begin
		if reset = '0' then
			idxMin 		<= 0;
			idxMax 		<= 0;
			cptOfWord <= 0;
			ut_uartOeTx_in <= '0';
			ut_uartIn <= (others => '0');
			txState 	<= IdleSt;
			
		elsif rising_edge(clock) then
		
			case txState is
				
				when IdleSt =>
					if ut_uartOeTx_in = '0' then
						txState <= IdleSt;
					else
						idxMax 	<= 0;
						idxMin 	<= wordsize;
						txState <= DataLoadingSt;
					end if;
					
				when DataLoadingSt =>
					ut_uartIn <= dataToTransmit(idxMin downto idxMax);
					
				when Acqutmt =>
					if ut_uartOeTx_done = '0' then
						txState <= Acqutmt;
					else
						idxMin 	<= idxMin + wordsize;
						idxMax 	<= idxMax + wordsize;
						if cptOfWord < 3 then
							cptOfWord <= cptOfWord +1;
							txState 	<= DataLoadingSt;
						else
							cptOfWord <= 0;
							txState		<= IdleSt;
						end if;
					end if;
					
				when others =>
					txState <= IdleSt;
					
			end case;	
		end if;	
	end process tx_trv;
end tx_trcver;



-------------------------------------------------------
--
--	Rx transceiver architecture
--
-------------------------------------------------------
architecture rx_trcver of uart_transceiver is

	type state is (IdleSt, DataLoadingSt, Acqutmt);
	signal rxState : state;
begin

end rx_trcver;