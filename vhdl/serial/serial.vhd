--*************************************************************************
--*  Minimal UART ip core                                                 *
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
--* useful, but WITHout ANY WARRANTY; without even the implied            *
--* warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR               *
--* PURPOSE.  See the GNU Lesser General Public License for more          *
--* details.                                                              *
--*                                                                       *
--* You should have received a copy of the GNU Lesser General             *
--* Public License along with this source; if not, download it            *
--* from http://www.opencores.org/lgpl.shtml                              *
--*                                                                       *
--*************************************************************************

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

entity Minimal_UART_CORE is
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
end Minimal_UART_CORE;

ARCHITECTURE PRINCIPAL OF Minimal_UART_CORE  is




type STATE is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9);
signal CLK_SERIAL : std_logic :='0';
signal START : std_logic:='0';
signal EOCS, EOC1, EOC2 : std_logic:='0';
signal RX_CK_ENABLE : std_logic:='0';
signal RECEIVING : std_logic:='0';
signal TRANSMITTING : std_logic:='0';
signal CLK_TXD : std_logic :='0';
signal TXDS : std_logic :='1';
signal EOTS : std_logic :='0';
signal INPL : std_logic_vector(7 downto 0):=X"00";
signal DATA : std_logic_vector(7 downto 0):=X"00";
signal ATUAL_STATE, NEXT_STATE, ATUAL_STATE_TXD, NEXT_STATE_TXD: STATE := S0; 
signal TX_ENABLE : std_logic :='0';
signal TX_CK_ENABLE : std_logic :='0';

component BR_GENERATOR 
		port ( 
       	  CLOCK      : in std_logic;
			  RX_ENABLE  : in std_logic;
			  CLK_TXD    : out std_logic;	
			  TX_ENABLE  : in std_logic;
           CLK_SERIAL : out std_logic		
			 );
end component;

begin
READY<=not(TX_ENABLE);


BRG : BR_GENERATOR port map (CLOCK, RX_CK_ENABLE, CLK_TXD, TX_CK_ENABLE, CLK_SERIAL);
RX_CK_ENABLE <=START OR RECEIVING;
TX_CK_ENABLE<=TX_ENABLE OR TRANSMITTING;

START_DETECT : process(RXD, EOCS)
begin
		if (EOCS='1') then			
				START<='0';
		elsif (falling_edge(rxd)) then			
				START<='1';			
		end if;	   
end process START_DETECT;

RXD_STATES : process (CLK_SERIAL)
begin
	if (rising_edge(CLK_SERIAL)) then
			ATUAL_STATE<=NEXT_STATE;	
	end if;			
end process RXD_STATES;

RXD_STATE_MACHINE : process(START, ATUAL_STATE)
begin
if (START='1' or RECEIVING='1') then	
	case ATUAL_STATE is
		when S0 =>	
		 	EOCS<='0';						
		   if (START='1') then
				NEXT_STATE<=S1;	
				RECEIVING<='1';				
			else
				NEXT_STATE<=S0;	
				RECEIVING<='0';				
			end if;				
		when S1 =>		
			RECEIVING<='1';
			EOCS<='0';					
			NEXT_STATE<=S2;			
		when S2	=>					
			RECEIVING<='1';
			EOCS<='0';					
			NEXT_STATE<=S3;			
		when S3	=>					
			RECEIVING<='1';
			EOCS<='0';				
			NEXT_STATE<=S4;			
		when S4	=>					
			RECEIVING<='1';
			EOCS<='0';							
			NEXT_STATE<=S5;			
		when S5	=>				
			RECEIVING<='1';
			EOCS<='0';							
			NEXT_STATE<=S6;			
		when S6	=>					
			RECEIVING<='1';
			EOCS<='0';					
			NEXT_STATE<=S7;		
		when S7	=>					
			RECEIVING<='1';
			EOCS<='0';								
			NEXT_STATE<=S8;		
		when S8	=>    			
			RECEIVING<='1';
			EOCS<='0';						
			NEXT_STATE<=S9;			
		when S9	=>    			
			RECEIVING<='1';
			EOCS<='1';						
			NEXT_STATE<=S0;				
		when others =>			
			null;			
	end case;	
end if;
end process RXD_STATE_MACHINE;

RXD_SHIFT : PROCESS(CLK_SERIAL)
BEGIN   	
	if (rising_edge(CLK_SERIAL)) then	
		if(EOCS='0') then
	 		DATA<=RXD & DATA(7 downto 1);	 		
		end if;
	end if; 	 	
END PROCESS RXD_SHIFT;

process (CLOCK)
begin	
	if (rising_edge(CLOCK)) then
		EOC<=EOCS;
	end if;
end process;

process(ATUAL_STATE)
begin
	if (ATUAL_STATE=S9) then
		OUTP<=DATA;	
	end if;
end process;

TXD_STATES : process(CLK_TXD)
begin
	if (rising_edge(CLK_TXD)) then
		ATUAL_STATE_TXD<=NEXT_STATE_TXD;	
	end if;			
end process	TXD_STATES;

TXD_STATE_MACHINE : process(ATUAL_STATE_TXD, TX_ENABLE)
begin
case ATUAL_STATE_TXD is
		when S0 =>					
			INPL<=INP;			
			EOTS<='0';				
			if (TX_ENABLE='1') then
				TXDS<='0';	
				TRANSMITTING<='1';
				NEXT_STATE_TXD<=S1;						
			else				
				TXDS<='1';			
				TRANSMITTING<='0';
				NEXT_STATE_TXD<=S0;
			end if;			
		when S1 =>		
			TXDS<=INPL(0);			
			EOTS<='0';		
			TRANSMITTING<='1';			
			NEXT_STATE_TXD<=S2;									
		when S2 =>			
			TXDS<=INPL(1);
			EOTS<='0';			
			TRANSMITTING<='1';
			NEXT_STATE_TXD<=S3;		
		when S3 =>		
			TXDS<=INPL(2);
			EOTS<='0';			
			TRANSMITTING<='1';
			NEXT_STATE_TXD<=S4;		
		when S4 =>		
			TXDS<=INPL(3);
			EOTS<='0';			
			TRANSMITTING<='1';
			NEXT_STATE_TXD<=S5;		
		when S5 =>		
			TXDS<=INPL(4);
			EOTS<='0';			
			TRANSMITTING<='1';
			NEXT_STATE_TXD<=S6;		
		when S6 =>		
			TXDS<=INPL(5);
			EOTS<='0';			
			TRANSMITTING<='1';
			NEXT_STATE_TXD<=S7;		
		when S7 =>			
			TXDS<=INPL(6);
			EOTS<='0';			
			TRANSMITTING<='1';
			NEXT_STATE_TXD<=S8;		
		when S8 =>			
			TXDS<=INPL(7);
			EOTS<='0';			
			TRANSMITTING<='1';
			NEXT_STATE_TXD<=S9;		
		when S9 =>			
			TXDS<='1';	
			EOTS<='1';	
			TRANSMITTING<='1';
			NEXT_STATE_TXD<=S0;				
		when others =>			
			null;			
end case;	
end process TXD_STATE_MACHINE;

TX_START:process (CLOCK, WR,  EOTS)
begin
	if (EOTS='1') then
			TX_ENABLE<='0';				
	elsif (falling_edge(CLOCK)) then
		if (WR='1') then
			TX_ENABLE<='1';			
		end if;	
	end if;
end process TX_START;
EOT<=EOTS;

process (CLOCK)
begin
	if (rising_edge(CLOCK)) then
		TXD<=TXDS;
	end if;
end process;

end PRINCIPAL ;    