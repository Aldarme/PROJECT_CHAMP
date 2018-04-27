
-------------------------------------------------------------------
--
-- This file is a Asynchrnous FIFO
--
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity FIFO_Asynch is
	generic
	(
		f_deep	: integer :=0;	--FIFO's depth
		f_wLgth	: integer :=0		--word's length
	);
	port
	(
		f_clock 	: in std_logic;
		f_oeW			:	in std_logic;
		f_dataIn	:	in std_logic_vector(f_wLgth-1 downto 0);
		f_oeR			:	in std_logic;
		f_dataOut	:	out std_logic_vector(f_wLgth-1 downto 0);
		emptyFlag	:	out std_logic;
		fullFlag	: out std_logic;
		f_reset		: in std_logic
	);
end entity;

Architecture AsynchFifo of FIFO_Asynch is
 
	type F_type is array (0 to f_deep-1) of std_logic_vector(f_wLgth-1 downto 0);
	signal FIFO : F_type;
	
	signal waddr : std_logic_vector(f_wLgth downto 0);
	signal raddr : std_logic_vector(f_wLgth downto 0);
 
	begin
 
	--
	-- Write process
	--
	WrtOp : process(f_reset, f_oeW)
		
		begin
		
		if f_reset = '0' then
			waddr <= (others => '0');
		
		elsif rising_edge(f_oeW) then
		
			if to_integer(signed(waddr(f_wLgth-1 downto 0))) = f_wLgth-1 then
				waddr(f_wLgth) <= waddr(f_wLgth) and '1';
				waddr(f_wLgth-1 downto 0) <= (others => '0');
			end if;
			
			FIFO( to_integer(signed(waddr(f_wLgth-1 downto 0))) ) <= f_dataIn;
			waddr <=  std_logic_vector( unsigned(waddr) + 1 );
			
		end if;			
	end process WrtOp;
	
	
	--
	-- Read process
	--
	RdOp : process(f_reset, f_oeR)		
		
		begin
		
		if f_reset = '0' then
			raddr <= (others => '0');
			
		elsif rising_edge(f_oeR) then
		
			if to_integer(signed(raddr(f_wLgth-1 downto 0))) = f_wLgth-1 then
				raddr(f_wLgth) <= raddr(f_wLgth) and '1';
				raddr(f_wLgth-1 downto 0) <= (others => '0');
			end if;
			
			f_dataOut <= FIFO( to_integer(signed(raddr(f_wLgth-1 downto 0))));
			raddr <= std_logic_vector( unsigned(raddr) + 1 );
			
		end if;		
	end process RdOp;
	
	
	--
	-- Synch Process
	--
	SynchOp : process (f_reset, f_clock)
		
		begin
		
		if f_reset = '0' then
			emptyFlag <= '1';
			fullFlag	<= '0';
			
		elsif rising_edge (f_clock) then
			
			if waddr = raddr then 
				emptyFlag <= '1';
			else
				emptyFlag <= '0';
			end if;
				
			if waddr(f_wLgth) /= raddr(f_wLgth) then
				fullFlag <= '1';
			else
				fullFlag <= '0';
			end if;
		end if;
	end process SynchOp;
	
end AsynchFifo;