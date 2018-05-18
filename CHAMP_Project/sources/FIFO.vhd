
--------------------------------------------------------------------------------------------------
-- Autor	:	ROMET Pierre
-- Date		:	19/03/2018
-- FileName :  FIFO.vhd
-- License  :	Code under license creative commun BY-SA, that define
--					Attribution :	Licensees may copy, distribute, display and perform 
--										the work and make derivative works and remixes based on it only if
--										they give the author or licensor the credits (attribution) in the 
--										manner specified by these.
--					Share-alink :	Licensees may distribute derivative works only under a license 
--										identical ("not more restrictive") to the license that governs the 
--										original work. (See also copyleft.) Without share-alike, derivative
--										works might be sublicensed with compatible but more restrictive
--										license clauses, e.g. CC BY to CC BY-NC.)
--------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity FIFO is
	generic
	(
		f_deep	: integer :=0; --FIFO's depth
		f_wLgth	: integer :=0	--word's length
	);
	port
	(
		f_clock	: in std_logic;		
		--Write
		f_write	: in std_logic_vector(f_wLgth-1 downto 0);
		f_oeW 	: in std_logic;
		--Read
		f_read	: out std_logic_vector(f_wLgth-1 downto 0);
		f_oeR	: in std_logic;
		f_rdStop: out std_logic;
		f_reset	: in STD_LOGIC
	);
 end entity;
 
 
 --FIFO architecture
 architecture synchFifo of FIFO is
 
	type F_type is array (0 to f_deep-1) of std_logic_vector(f_wLgth-1 downto 0);
	signal FIFO : F_type;
	
	type   T_SPISTATE is (waitst, checkst);
	signal cState     : T_SPISTATE;
	
	signal current : std_logic := '0';
	signal previous : std_logic := '0';
	
	begin
	
	fifo_p : process(f_reset, f_oeW, f_oeR)
		
		variable head : integer := 0;
		variable tail : integer := 0;
		
		begin
		
		-- Reset action
		if f_reset = '0' then
			f_rdStop <= '0';
			cState <= waitst;
			
		else
			case cState is
				
				when waitst =>
					
					-- Write action
					if f_oeW = '1' then
					
						if head > 11 then
							head := 0;
						end if;
						
						if f_rdStop = '1' then
							f_rdStop <= '0';
						end if;
						
						FIFO(head) <= f_write;
						head := head +1;
						
						cState <= waitst;
					end if;
					
					-- Read action
					if f_oeR = '1' then
					
						if tail > 11 then
							tail := 0;
						end if;
						
						f_read <= FIFO(tail);
						tail := tail +1;
						
						cState <= checkst;
					end if;
					
				when checkst =>
				
					if tail = head and tail > 0 and head > 0 then
						f_rdStop <= '1';
					end if;					
					cState <= waitst;
					
				when others =>
					cState <= waitst;
					
			end case;
		end if;		
	end process fifo_p;
 
 end synchFifo;
	
