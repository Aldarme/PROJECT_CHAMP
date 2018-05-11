-------------------------------------------------------
--
--	This Documents describe the usage of UART protocol
--	for RS232 communication
-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity rs232_uart is
	generic
	(
		baudRate : integer := 0
	);
	
	port
	(
		clock 				: in std_logic;
		reset					: in std_logic;
		uartOeTx_in		: in std_logic;
		uartOeTx_done	: out std_logic;
		uartIn 				: in std_logic_vector(7 downto 0);
		uartOeRx_out	: out std_logic;
		uartOut				: out std_logic_vector(7 downto 0);
		uart_rx				: in std_logic;							-- Port to link with PIN_G12
		uart_tx				: out std_logic							-- Port to link with PIN_G9		
	);
end entity;

-------------------------------------------------------
--
--	RX architecture
--
-------------------------------------------------------
architecture uart_rx of rs232_uart is

	type	 state is (IdleSt, StartBitSt, ReadRxSt, StopBitSt, CleanUpSt);
	signal cStateRx : state;

	signal rxRead		: std_logic;
	
	constant wordLength : integer := 7;
	
	signal cpt_clk	: integer := 0;
	signal dataIdx	: integer := 0;
	
	begin
	
	-- Double buffering the incoming data
	-- It remove problems caused by metastability
	cpy: process(reset, clock)
	
		begin
		
		if reset = '0' then
			rxRead <= '0';
		elsif rising_edge(clock) then
			rxRead <= uart_rx;
		end if;
		
	end process cpy;
	
	-- Read data from rx uart
	u_rx: process(clock)
	
		begin
		
		if reset = '0' then
			cpt_clk 		<= 0;
			uartOeRx_out <= '0';
			cStateRx 			<= IdleSt;
		
		elsif rising_edge(clock) then
			
			case cStateRx is 
				
				when IdleSt =>
					cpt_clk 		<= 0;
					dataIdx			<= 0;
					uartOeRx_out	<= '0';
					
					if rxRead = '0' then					
						cStateRx <= StartBitSt;
					else					
						cStateRx <= IdleSt;
					end if;
					
				when StartBitSt =>
					if cpt_clk = (baudRate-1)/2 then
						if rxRead = '0' then
							cpt_clk <= 0;
							cStateRx	<= ReadRxSt;
						else
							cStateRx <= IdleSt;
						end if;					
					else
						cpt_clk <= cpt_clk +1;
						cStateRx	<= StartBitSt;
					end if;
					
				when ReadRxSt =>
					if cpt_clk < baudRate-1 then
						cpt_clk <= cpt_clk +1;
						cStateRx	<= ReadRxSt;
					else
						cpt_clk <= 0;
						uartOut(dataIdx) <= rxRead;
						
						if dataIdx < wordLength then
							dataIdx <= dataIdx +1;
							cStateRx	<= ReadRxSt;							
						else
							dataIdx <= 0;
							cStateRx	<= StopBitSt;							
						end if;
					end if;
					
				when StopBitSt =>
					if cpt_clk < baudRate-1 then
						cpt_clk <= cpt_clk +1;
						cStateRx	<= StopBitSt;
					else
						cpt_clk <= 0;
						uartOeRx_out <= '1';
						cStateRx	<= IdleSt;
					end if;
					
				when others =>
					cStateRx <= IdleSt;
			
			end case;				
		end if;
	end process u_rx;
end uart_rx;


-------------------------------------------------------
--
-- TX  architecture
--
-------------------------------------------------------
architecture uart_tx of rs232_uart is
	
	type state is (IdleSt, StartActSt, DataTxSt, StopBitSt, AcquitmtSt);
	signal cStateTx : state;
	
	constant startBit	: std_logic := '0';
	constant stopBit	: std_logic := '1';
	
	signal tx_out			:	std_logic_vector(7 downto 0);
	signal cpt_clk_tx : integer := 0;
	signal dataIdx_tx : integer := 0;
	
	begin
	
	u_tx : process (reset, clock)
	
		begin
	
		if reset = '0' then
			uartOeTx_done <= '0';
			cpt_clk_tx		<= 0;
			dataIdx_tx		<= 0;
			cStateTx			<= IdleSt;
		
		elsif rising_edge (clock) then
		
			case cStateTx is
			
				when IdleSt =>
					uartOeTx_done <= '0';
					
					if uartOeTx_in = '0' then
						cStateTx 	<= idleSt;
					else
						tx_out 		<= uartIn;
						cStateTx 	<= StartActSt;
					end if;
				
				when StartActSt	=>
					if cpt_clk_tx < baudRate-1 then
						cpt_clk_tx <= cpt_clk_tx +1;
						cStateTx	 <= StartActSt;
					else
						cpt_clk_tx	<= 0;
						uart_tx		<= startBit;
						cStateTx 	<= DataTxSt;
					end if;
					
				when DataTxSt =>
					if cpt_clk_tx < baudRate-1 then
						cpt_clk_tx <= cpt_clk_tx +1;
						cStateTx 	 <= DatatxSt;
					else
						cpt_clk_tx <= 0;
						if dataIdx_tx < 7 then
							uart_tx		 <= tx_out(dataIdx_tx);
							dataIdx_tx <= dataIdx_tx +1;
							cStateTx	 <= DataTxSt;
						else
							dataIdx_tx <= 0;
							cStateTx <= StopBitSt;
						end if;					
					end if;
					
				when StopBitSt =>
					if cpt_clk_tx < baudRate-1 then
						cpt_clk_tx <= cpt_clk_tx +1;
						cStateTx	 <= AcquitmtSt;
					else
						cpt_clk_tx <= 0;
						uart_tx 	 <= stopBit;
					end if;
					
				when AcquitmtSt =>
					uartOeTx_done <= '1';
					cStateTx 			<= IdleSt;
				
				when others =>
				cStateTx <= IdleSt;
				
			end case;
		end if;
	end process u_tx;
end uart_tx;