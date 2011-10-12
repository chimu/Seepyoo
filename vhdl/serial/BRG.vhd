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
--* useful, but WITHOUT ANY WARRANTY; without even the implied            *
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
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

entity BR_GENERATOR is
generic (DIVIDER_WIDTH: integer := 16);
Port ( 
     	  CLOCK : in std_logic;
		  RX_ENABLE      : in std_logic;
		  CLK_TXD     : out std_logic;	
		  TX_ENABLE   : in std_logic;
        CLK_SERIAL  : out std_logic
		);
end BR_GENERATOR;

architecture PRINCIPAL of BR_GENERATOR is


-- Change the following constant to your desired baud rate
-- One Hz equal to one bit per second

signal COUNT_BRG : STD_LOGIC_VECTOR(DIVIDER_WIDTH-1 downto 0):=(others=>'0'); 
signal COUNT_BRG_TXD : STD_LOGIC_VECTOR(DIVIDER_WIDTH-1 downto 0):=(others=>'0'); 


constant BRDVD : std_logic_vector(DIVIDER_WIDTH-1 downto 0) := X"A2C2"; -- 15B@115200, 40MHz 8235@1200, 1046A 600BPS, 824@19200BPS    BASYS2: 1B2=115200, A2C2=1200
begin

TXD : process (CLOCK) 
begin
if (CLOCK='1' and CLOCK'event) then		
	if (COUNT_BRG_TXD=BRDVD) then
			CLK_TXD<='1';
			COUNT_BRG_TXD <= (others=>'0');	
	elsif (TX_ENABLE='1') then
			CLK_TXD<='0';
			COUNT_BRG_TXD <= COUNT_BRG_TXD + 1;											
	else
			CLK_TXD<='0';
			COUNT_BRG_TXD <= (others=>'0');	
	end if;	
end if;		
end process TXD;

RXD : process (CLOCK)
begin
if (CLOCK='1' and CLOCK'event) then		
	if (COUNT_BRG=BRDVD) then
			COUNT_BRG <= (others=>'0');	
			CLK_SERIAL<='1';
	elsif (RX_ENABLE='1') then	
			COUNT_BRG<=COUNT_BRG+1;	
			CLK_SERIAL<='0';			
	else				
			CLK_SERIAL<='0';
			COUNT_BRG<=  '0' & BRDVD(DIVIDER_WIDTH-1 DOWNTO 1);			
	end if;
end if;
end process RXD;
end PRINCIPAL;