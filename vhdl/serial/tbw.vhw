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
use IEEE.std_logic_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE STD.TEXTIO.ALL;

ENTITY tbw IS
END tbw;

ARCHITECTURE testbench_arch OF tbw IS
    COMPONENT Minimal_UART_CORE
        PORT (
            CLOCK : In std_logic;
            EOC : Out std_logic;
            OUTP : InOut std_logic_vector (7 DownTo 0);
            RXD : In std_logic;
            TXD : Out std_logic;
            EOT : Out std_logic;
            INP : In std_logic_vector (7 DownTo 0);
            READY : Out std_logic;
            WR : In std_logic
        );
    END COMPONENT;

    SIGNAL CLOCK : std_logic := '0';
    SIGNAL EOC : std_logic := '0';
    SIGNAL OUTP : std_logic_vector (7 DownTo 0) := "ZZZZZZZZ";
    SIGNAL RXD : std_logic := '1';
    SIGNAL TXD : std_logic := '0';
    SIGNAL EOT : std_logic := '0';
    SIGNAL INP : std_logic_vector (7 DownTo 0) := "00000000";
    SIGNAL READY : std_logic := '0';
    SIGNAL WR : std_logic := '0';

    constant PERIOD : time := 26 ns;
    constant DUTY_CYCLE : real := 0.5;
    constant OFFSET : time := 0 ns;

    BEGIN
        UUT : Minimal_UART_CORE
        PORT MAP (
            CLOCK => CLOCK,
            EOC => EOC,
            OUTP => OUTP,
            RXD => RXD,
            TXD => TXD,
            EOT => EOT,
            INP => INP,
            READY => READY,
            WR => WR
        );

        PROCESS    -- clock process for CLOCK
        BEGIN
            WAIT for OFFSET;
            CLOCK_LOOP : LOOP
                CLOCK <= '0';
                WAIT FOR (PERIOD - (PERIOD * DUTY_CYCLE));
                CLOCK <= '1';
                WAIT FOR (PERIOD * DUTY_CYCLE);
            END LOOP CLOCK_LOOP;
        END PROCESS;

        PROCESS
            BEGIN
                -- -------------  Current Time:  8562ns
                WAIT FOR 8562 ns;
                RXD <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  18728ns
                WAIT FOR 10166 ns;
                RXD <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  26814ns
                WAIT FOR 8086 ns;
                INP <= "10100110";
                -- -------------------------------------
                -- -------------  Current Time:  27776ns
                WAIT FOR 962 ns;
                RXD <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  34744ns
                WAIT FOR 6968 ns;
                WR <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  35342ns
                WAIT FOR 598 ns;
                WR <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  36304ns
                WAIT FOR 962 ns;
                RXD <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  45482ns
                WAIT FOR 9178 ns;
                RXD <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  54244ns
                WAIT FOR 8762 ns;
                RXD <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  62590ns
                WAIT FOR 8346 ns;
                RXD <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  72340ns
                WAIT FOR 9750 ns;
                RXD <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  80842ns
                WAIT FOR 8502 ns;
                RXD <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  90280ns
                WAIT FOR 9438 ns;
                RXD <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  200598ns
                WAIT FOR 110318 ns;
                INP <= "01011101";
                -- -------------------------------------
                -- -------------  Current Time:  205096ns
                WAIT FOR 4498 ns;
                RXD <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  206084ns
                WAIT FOR 988 ns;
                WR <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  207306ns
                WAIT FOR 1222 ns;
                WR <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  214040ns
                WAIT FOR 6734 ns;
                RXD <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  346926ns
                WAIT FOR 132886 ns;
                INP <= "10000011";
                -- -------------------------------------
                -- -------------  Current Time:  352438ns
                WAIT FOR 5512 ns;
                WR <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  353036ns
                WAIT FOR 598 ns;
                WR <= '0';
                -- -------------------------------------
                WAIT FOR 146990 ns;

            END PROCESS;

    END testbench_arch;

