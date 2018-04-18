----------------------------------------------------------------------------------------
--
--This file is a generic clock divider
--IT allow to divide the main clock frequency to have a new smallest clock frequency
--
----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity clockDivider is
 generic
	(
		mainClock 	: integer := 0;
		wishedClock : integer := 0
	);
 port
	(
		clockIn  : in std_logic;
		clockOut : out std_logic;
		reset		: in std_logic
	);
end clockDivider;

architecture dividerArch of clockDivider is

	signal prescaler		: integer := mainClock/wishedClock/2;		--masterClock / wishedClock / 2 = 50M / 1K / 2 = 25000;
	signal clockCounter	: integer range 0 to prescaler-1 := 0;
	signal newclockOut	: std_logic := '0';
	
	begin
	
		freqDiv : process (reset, clockIn) begin
			if reset = '1' then
				clockCounter <= 0;
				newclockOut  <= '0';
				
			elsif rising_edge(clockIn) then
				if clockCounter = prescaler-1 then
					newclockOut <= not newclockOut;
					clockCounter <= 0;
					
				else
					clockCounter <= clockCounter + 1;
					
				end if;
			end if;			
		end process;
		
end dividerArch;