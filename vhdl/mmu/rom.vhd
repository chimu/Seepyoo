------------------------------
-- ENEL353 Hardware Project
-- Microprocessor Group Assignment
-- Program ROM
-- By Thomas Pryde
-- Based up memory.vhd, Demonatration code
-- form on the website "http://esd.cs.ucr.edu/labs/tutorial/index.html"
-- 11 Oct 2011
------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;  

ENTITY rom IS
PORT(		clock	:	IN std_logic;
			reset	:	IN std_logic;
			f_req	:	IN std_logic;
			f_ack	:	IN std_logic;
			addr	:	IN std_logic_vector(12 DOWNTO 0);
			d_out	:	OUT std_logic_vector(15 DOWNTO 0);
	);
END rom;

ARCHITECTURE arch OF rom IS
	TYPE rom_type IS ARRAY ( 0 TO 4095) OF
									std_logic_vector(15 TO 0);
	SIGNAL tmp_rom: rom_type;
	
BEGIN
	PROCESS(clock, reset, f_req, addr)
	BEGIN
		IF reset = '1' THEN
			tmp_rom <= (OTHERS => "0000000000000000"); -- set all the ram to 0
																	 -- this will be later changed set the rom to the progam code.

		ELSIF rising_edge(clock) AND f_req = '1' AND f_ack = '0' THEN	-- if start of a clock cycle 
																							-- and data requested and bus not busy
			d_out <=(conv_integer(addr));											-- put the data at the address given on the bus
		END IF;
	END PROCESS;
END arch;