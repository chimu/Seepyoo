--*************************************************************************
--*  Simple UART ip core                                                  *
--* Author: Arao Hayashida Filho        arao@medinovacao.com.br           *
--*                                                                       *
--*************************************************************************
--*                                                                       *
--* Copyright (C) 2009 Arao Hayashida Filho                               *
--*                                                                       *
--* This source file may be used and distributed without                  *
--* restriction provided that this copyright statement is not             *
--* removed from the file and that any derivative work contains           *
--* the original copyright notice and the associated disclaimer.          *
--*                                                                       *
--* This source file is free software; you can redistribute it            *
--* and/or modify it under the terms of the GNU Lesser General            *
--* Public License as published by the Free Software Foundation;          *
--* either version 2.1 of the License, or (at your option) any            *
--* later version.                                                        *
--*                                                                       *
--* This source is distributed in the hope that it will be                *
--* useful, but without ANY WARRANTY; without even the implied            *
--* warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR               *
--* PURPOSE.  See the GNU Lesser General Public License for more          *
--* details.                                                              *
--*                                                                       *
--* You should have received a copy of the GNU Lesser General             *
--* Public License along with this source; if not, download it            *
--* from http://www.opencores.org/lgpl.shtml                              *
--*                                                                       *
--*************************************************************************
--*    To initialize the KS0070B/HD44780 display  send the following      *
--*    commands:    056-015-006-001-003 (decimal)                         *
--*************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity main is
    Port (
			  CLOCK : in STD_LOGIC;
			  TXD : out STD_LOGIC;
			  RXD : in STD_LOGIC;			  
    		  WR : IN  STD_LOGIC;			  
      --     E : out  STD_LOGIC;
			  switches: IN STD_LOGIC_VECTOR ( 7 DOWNTO 0);
			  clk_btn: IN STD_LOGIC;
			  
			  leds : out STD_LOGIC_VECTOR (7 DOWNTO 0)
			  );
end main;

architecture principaltst of main is
component Minimal_UART_CORE
port( 
	  CLOCK 		:  in    std_logic;
	  EOC		   :  out   std_logic;
	  OUTP      :  inout std_logic_vector(7 downto 0) := "ZZZZZZZZ";
	  RXD       :  in	std_logic;	
	  TXD			: 	out std_logic;
	  EOT			:	out std_logic;
	  INP 		: in std_logic_vector(7 downto 0);
	  READY     :  out   std_logic;
	  WR			:  in    std_logic	  
    );
end component;

--COMPONENT DECOD 
--      Port ( DATA : in  STD_LOGIC_VECTOR (7 downto 0);
--       	  CLOCK : in STD_LOGIC;
--           SEGMENT : out  STD_LOGIC_VECTOR (7 downto 0);
--			  OUTP : out  STD_LOGIC_VECTOR (7 downto 0);		
--			  EOT : in STD_LOGIC;
--			  WR : out STD_LOGIC			  
--			 );
--END COMPONENT;	

signal EOC : std_logic;
signal EOT : std_logic;
signal READY : std_logic;
signal WRT : std_logic;
signal DSerial, outs : std_logic_vector(7 downto 0):=X"00";
signal INPs : std_logic_vector(7 downto 0):=X"00";
signal EDL : std_logic := '0';
signal derpvider : std_logic_vector(24 DOWNTO 0);
signal strobe, dotrans, ahyeah : std_logic := '0';

signal packet_data : std_logic_vector(39 DOWNTO 0);

type STATE is (RECV_HEADER, RECV_ADDRESS1, RECV_ADDRESS2 , RECV_DATA1, RECV_DATA2, EXECUTE);

signal cur_state, next_state : STATE := RECV_HEADER;

begin
MUART : Minimal_UART_CORE port map(CLOCK, EDL, DSerial, RXD, TXD, EOT, INPS, READY, WRT);
--TEST: DECOD port map (DSerial, CLOCK, SEGMENT, INPS, EOT, WRT); 

--E<=EDL;
--<=DSERIAL;
EOC<=EDL;
--WRT<=WR; -- The DECOD component send data to the transmitter

process (CLOCK)
begin	
	if rising_edge(CLOCK) then
		cur_state <= next_state;
		--if (EDL='1') then
			--if (DSERIAL=X"5C") then
			--	RS_S<='0';
			--elsif (DSERIAL=X"5D") then
			--	RS_S<='1';
			--end if;	
			--outs <= DSerial;
		--end if;
		
		derpvider <= derpvider + "1";
	
		if EDL = '1' THEN
			outs <= DSerial;
		end if;
		
		
		if derpvider = "0" THEN
			--INPS <= X"21";
			--WRT <= '1';
			strobe <= NOT strobe;
		else
			WRT <= '0';
		end if;
		
		if cur_state = RECV_HEADER then
			packet_data(39 DOWNTO 32) <= outs;
			next_state <= RECV_ADDRESS1;
		elsif cur_state = RECV_ADDRESS1 then
			packet_data(31 DOWNTO 24) <= outs;
			next_state <= RECV_ADDRESS2;
		elsif cur_state = RECV_ADDRESS2 then
			packet_data(23 DOWNTO 16) <= outs;
			next_state <= RECV_DATA1;
		elsif cur_state = RECV_DATA1 then
			packet_data(15 DOWNTO 8) <= outs;
			if packet_data(32) = '1' then --if the header indicates an instruction
				next_state <= RECV_DATA2;
			else
				next_state <= EXECUTE;
			end if;
		elsif cur_state = RECV_DATA2 then
			packet_data(7 DOWNTO 0) <= outs;
			next_state <= EXECUTE;
		end if;
		
		

	end if;
end process;

		
leds <= "0000000" & strobe;

--leds <= outs;
--leds (7 DOWNTO 1) <= "0000000";
--leds(0) <= READY;

end principaltst;