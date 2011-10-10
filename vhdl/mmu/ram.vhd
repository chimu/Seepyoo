------------------------------
-- ENEL353 Hardware Project
-- Microprocessor Group Assignment
-- Data RAM
-- By Thomas Pryde
-- Based up memory.vhd, Demonatration code from the website
-- "http://esd.cs.ucr.edu/labs/tutorial/index.html"
-- 11 Oct 2011
------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;  

ENTITY ram is
PORT(	clock		:	IN 	std_logic;
		reset		:	IN 	std_logic;
		f_req		:	IN 	std_logic;	--	fetch_requets
		f_ack		:	IN 	std_logic;	--	fetch_acknowledge
		r_NOTw	:	IN		std_logic;	-- read_not_write
		addr		:	IN		std_logic_vector(15	DOWNTO 0);
		d_in		:	IN 	std_logic_vector(7	DOWNTO 0);
		d_out		:	OUT	std_logic_vector(7	DOWNTO 0);
);

ARCHITECTURE arch OF rom IS
	TYPE ram IS ARRAY (128 to 65535) OF
							std_logic_vector(7 DOWNTO 0)
	SIGNAL tmp_ram: ram;
	
BEGIN
	PROCESS(clock, reset, f_req, r_NOTw, addr, d_in)
	BEGIN
		IF reset = '1' THEN											-- if reset is ever i then
			tmp_ram <= (OTHERS => "00000000");					-- reset all ram to 0

		ELSIF rising_edge(clock) THEN								-- if start of clock pulse		
				IF f_req = '1' AND f_ack = '0' THEN				--	if asked for data and bus not in use
					IF r_NOTw = '1' THEN								--	if reading
						d_out <= tmp_ram(conv_integer(addr));	-- return data at address
					ELSE													-- else must be writing
						tmp_ram(conv_integer(addr)) <= d_in;	--	get the data at the address
					END IF;
				END IF;
		END IF;
	END PROCESS;
END arch;
						