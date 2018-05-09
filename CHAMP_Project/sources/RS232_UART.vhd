-------------------------------------------------------
--
--	This Documents describe the usage of UART protocol
--	for RS232 communication
-------------------------------------------------------

entity rs232_uart is
	generic
	(
		baudRate : integer := 0;
	);
	
	port
	(
		uartClock 	: in std_logic;
		uart_oe_in	:	in std_logic;
		dataIn 			: in std_logic_vector(7 downto 0);
		uart_oe_out	:	out std_logic;
		dataOut			: out std_logic_vector(7 downto 0);
		uart_tx			:	out std_logic_vector(7 downto 0);	-- Port to link with PIN_G9
		uart_rx			: in std_logic_vector(7 downto 0)		-- Port to link with PIN_G12
	);
end entity;

--
--	RX architecture
--
architecture uart_rx of rs232_uart is

	begin

end uart_rx;

--
-- TX  architecture
--
architecture uart_tx of rs232_uart is

	begin

end uart_tx;