-- Design for lab 4 of ee475 for spring 1998
 -- The mica cpu + ken's shell
 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;
 USE ieee.std_logic_unsigned.all;
 
 ENTITY shell IS
      PORT (
            rxdat : IN     std_logic;
            xclk  : IN     std_logic;
            rxstb : IN     std_logic;
            txstb : IN     std_logic;
            txdat : OUT    std_logic;
           
            clk   : IN     std_logic;
            addr  : BUFFER std_logic_vector(15 DOWNTO 0);
            data  : INOUT  std_logic_vector(7 DOWNTO 0);
            rd    : BUFFER std_logic;
            wr    : BUFFER std_logic;
            ramcs : OUT    std_logic;
            sevseg: OUT    std_logic_vector(6 DOWNTO 0)
      );
 END shell;
 
 ARCHITECTURE one OF shell IS
 
       COMPONENT cpu PORT (
                 clk   : IN     std_logic;
                 addr  : BUFFER std_logic_vector(15 DOWNTO 0);
                 data  : INOUT  std_logic_vector(7 DOWNTO 0);
                 rd    : BUFFER std_logic;
                 wr    : BUFFER std_logic;
                 --ramcs : OUT    std_logic;
                 sevseg: OUT    std_logic_vector(6 DOWNTO 0);
                
                 din   : IN     std_logic_vector(15 DOWNTO 0);
                 dout  : OUT    std_logic_vector(7 DOWNTO 0);
                 dsel  : IN     std_logic_vector(1 DOWNTO 0)
      );
      END COMPONENT;
 
         SIGNAL din        : std_logic_vector(15 DOWNTO 0);
         SIGNAL clksel     : std_logic_vector(4 DOWNTO 0);
         SIGNAL dsel       : std_logic_vector(1 DOWNTO 0);
         SIGNAL dout       : std_logic_vector(7 DOWNTO 0);
         SIGNAL txshift    : std_logic_vector(7 DOWNTO 0);
         SIGNAL txshiftnext: std_logic_vector(7 DOWNTO 0);
         SIGNAL rxshift    : std_logic_vector(22 DOWNTO 0);
         SIGNAL clkdiv     : std_logic_vector(23 DOWNTO 0);
         SIGNAL cpuclk     : std_logic;
 BEGIN
      u1: cpu PORT MAP (
            clk    => cpuclk,
            addr   => addr,
            data   => data,
            rd     => rd,
            wr     => wr,
            --ramcs  => ramcs,
            sevseg => sevseg,
 
            din    => din,
            dout   => dout,
            dsel   => dsel
      );
 
 -- select ram
      ramcs <='0';
 -- Drive serial interface
      WITH txstb SELECT
            txshiftnext <= txshift(6 DOWNTO 0)&'0' WHEN '0',
                        dout WHEN OTHERS;
      txrx: PROCESS
      BEGIN
            WAIT UNTIL (xclk'event AND xclk='0');
            rxshift <= rxshift(21 DOWNTO 0)&(NOT rxdat);
            txshift <= txshiftnext;
      END PROCESS txrx;
           
      rx: PROCESS
      BEGIN
            WAIT UNTIL (rxstb'event AND rxstb='1');
            din    <= rxshift(15 DOWNTO 0);
            dsel   <= rxshift(17 DOWNTO 16);
            clksel <= rxshift(22 DOWNTO 18);
      END PROCESS rx;
      txdat <=  txshift(7);
 
 -- Run clock divider
       PROCESS
      BEGIN
            WAIT UNTIL (clk'event AND clk='1');
            clkdiv <= clkdiv + 1;
      END PROCESS;
      WITH clksel SELECT
            cpuclk <= clk WHEN "00000",
                      clkdiv(0) WHEN "00001",
                      clkdiv(1) WHEN "00010",
                      clkdiv(2) WHEN "00011",
                      clkdiv(3) WHEN "00100",
                      clkdiv(4) WHEN "00101",
                      clkdiv(5) WHEN "00110",
                      clkdiv(6) WHEN "00111",
                      clkdiv(7) WHEN "01000",
                      clkdiv(8) WHEN "01001",
                      clkdiv(9) WHEN "01010",
                      clkdiv(10) WHEN "01011",
                      clkdiv(11) WHEN "01100",
                      clkdiv(12) WHEN "01101",
                      clkdiv(13) WHEN "01110",
                      clkdiv(14) WHEN "01111",
                      clkdiv(15) WHEN "10000",
                      clkdiv(16) WHEN "10001",
                      clkdiv(17) WHEN "10010",
                      clkdiv(18) WHEN "10011",
                      clkdiv(19) WHEN "10100",
                      clkdiv(20) WHEN "10101",
                      clkdiv(21) WHEN "10110",
                      clkdiv(22) WHEN "10111",
                      clkdiv(23) WHEN "11000",
                      '0'        WHEN "11110",
                      '1'        WHEN "11111",
                      '0'        WHEN OTHERS;                           
 END one;
 
 ---------------------------------------------------------------------------
 
 
 -- Design based on the MICA architecture from Notre Dame.
 -- CPU is a four register, 8 bit data/instruction, load/store machine.
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;    -- standard logic
 USE ieee.std_logic_unsigned.all; -- arithmetic stuff
 
 ENTITY cpu IS
      PORT(
       clk: IN std_logic;              -- 50% duty cycle clock
       rd: BUFFER std_logic;              -- mem read cntl
       wr: BUFFER std_logic;              -- mem write cntl
       addr: BUFFER std_logic_vector(15 downto 0);-- the address bus
       data: INOUT std_logic_vector(7 downto 0); -- the data bus
       sevseg: OUT std_logic_vector(6 downto 0); -- segven segment display
       
       din   : IN     std_logic_vector(15 DOWNTO 0); -- shell data in
      dout  : OUT    std_logic_vector(7 DOWNTO 0); -- shell data out
      dsel  : IN     std_logic_vector(1 DOWNTO 0)  -- shell data out select
      );
 END cpu;
 
 ARCHITECTURE one OF cpu IS
 
      -- reset signal
      SIGNAL reset: std_logic;
     
      -- cpu state
      SIGNAL fetch, exec: std_logic;
     
      --opcodes
      SIGNAL opLDI, opLD, opSTI, opST, opMV: std_logic;
      SIGNAL opAND, opOR, opNOT, opXOR, opADD, opADC, opSUB, opSBB, opNEG, opCMP: std_logic;
		SIGNAL opBEQ, opBNE, opBLT, opBGT, opBC, opBNC, opRJMP, opJMP, opNOP: std_logic;
 
      -- IR, PC
      SIGNAL ir:  std_logic_vector(15 downto 0);       
      --instruction register
      SIGNAL pc:  std_logic_vector(7 downto 0);       
      --program counter
      SIGNAL PCinSel:  std_logic;
      --selects PC load source 0=PC_incrementer 1=Aout
      SIGNAL PCload:  std_logic;
      --gates the PC load
      SIGNAL PCaddSel:  std_logic_vector(1 downto 0);
      --selects PC increment 0=1 1=2 3=displacement
      SIGNAL PCinc:  std_logic_vector(7 downto 0);
      --increment value
      SIGNAL PCin:  std_logic_vector(7 downto 0);
      --PC update
      SIGNAL PCnew:  std_logic_vector(7 downto 0);
      --incrmented PC
     
      -- DATA from IR
      SIGNAL DataImm:  std_logic_vector(7 downto 0);       
      -- 4 bits from IR extended
      SIGNAL disp:  std_logic_vector(2 downto 0);             
      --offset for reg indirect data addr from IR so addr<= disp+Bout
      SIGNAL displacement:  std_logic_vector(7 downto 0);       
      --offset for PC jump from IR so PC <= PC+displacement
 
      -- MEMORY interface
      SIGNAL MASel:  std_logic; 
      --memory address select: 0=PC, 1=disp+(B)
      SIGNAL dataAddr:  std_logic_vector(7 downto 0); 
      --memory data address  1=disp+(B)
      SIGNAL AtoBus:  std_logic;
      --gates the A bus output onto the memory data bus
 
      -- DATA registers
      SIGNAL r0, r1, r2, r3, r4, r5, r6, r7: std_logic_vector(7 downto 0);
      SIGNAL rdata:  std_logic_vector(7 downto 0);
      -- register outputs
      SIGNAL Aout, Bout: std_logic_vector(7 downto 0);
      --register input bus
      SIGNAL RegDSel:  std_logic_vector(1 downto 0);
      --data source for rdata reg write: 0=0 1=PC 2=ALUout 3=data
      SIGNAL ALUBSel:  std_logic_vector(1 downto 0);
      --data source for ALU b input: 0=Bout 1=0 2=1 3=DataImm
      SIGNAL ASel:  std_logic_vector(1 downto 0);
      --selects A register output
      SIGNAL BSel:  std_logic_vector(1 downto 0);
      --selects B register output
      SIGNAL we:  std_logic;
      --enables a register load
 
      -- ALU
      SIGNAL Bin: std_logic_vector(7 downto 0);
      SIGNAL ALUop:  std_logic_vector(1 downto 0);
      --selects ALU function
      SIGNAL ALUout:  std_logic_vector(7 downto 0);
      --ALU result
      SIGNAL zne:  std_logic;
      --gates the Z and N register loads
      SIGNAL z, n:  std_logic;
      --the Z and N registers
 
 
      BEGIN
     
            -- ***********************************
            --debugger shell interface
           
            reset <= din(0);
           
            WITH dsel  SELECT
                     dout <= addr(7 downto 0) WHEN "00" ,
                             data             WHEN "01",          
                         pc                    WHEN "10",    
                         ir               WHEN "11" ,
                         "11111111"       WHEN OTHERS  ;
                         
               -- ***********************************               
            -- 7-seg decoder
            WITH r3(3 downto 0) SELECT
                  sevseg <= "0111111" WHEN "0000",
                          "0000110" WHEN "0001",
                          "1011011" WHEN "0010",
                          "1001111" WHEN "0011",
                          "1100110" WHEN "0100",
                          "1101101" WHEN "0101",
                          "1111101" WHEN "0110",
                          "0000111" WHEN "0111",
                          "1111111" WHEN "1000",
                          "1101111" WHEN "1001",
                          "1110111" WHEN "1010",
                          "1111100" WHEN "1011",
                          "0111001" WHEN "1100",
                          "1011110" WHEN "1101",
                          "1111001" WHEN "1110",
                          "1110001" WHEN OTHERS;
         
            -- ***********************************
            -- OPcode decoder
            opLDI <= '1' WHEN ir(15 downto 10)="100001" ELSE '0'; -- load immediate
           
            opLD <= '1' WHEN ir(15 downto 10)="000001" ELSE '0'; --load direct
           
            opSTI <= '1' WHEN ir(15 downto 10)="100101" ELSE '0'; --store immediate
           
            opST <= '1' WHEN ir(15 downto 10)="000101" ELSE '0'; --store indirect
				
            opMV <= '1' WHEN  ir(15 downto 10)="000100" ELSE '0'; -- move 
                             
            opAND <= '1' WHEN  ir(15 downto 10)="000010" ELSE '0'; -- bitwise AND 
                             
            opOR <= '1' WHEN  ir(15 downto 10)="000110" ELSE '0'; -- bitwise OR 
 
            opNOT <= '1' WHEN  ir(15 downto 10)="001010" ELSE '0'; -- bitwise NOT
                             
            opXOR <= '1' WHEN  ir(15 downto 10)="001110" ELSE '0'; -- bitwise XOR
           
            opADD <= '1' WHEN  ir(15 downto 10)="010010" ELSE '0'; -- addition
                       
            opADC <= '1' WHEN  ir(15 downto 10)="010110" ELSE '0'; -- addition with carry
           
            opSUB <= '1' WHEN  ir(15 downto 10)="011010" ELSE '0'; -- subtraction

            opSBB <= '1' WHEN  ir(15 downto 10)="011110" ELSE '0'; -- subtraction with borrow(carry)

            opNEG <= '1' WHEN  ir(15 downto 10)="001000" ELSE '0'; -- negation - 2s complement

            opCMP <= '1' WHEN  ir(15 downto 10)="001100" ELSE '0'; -- compare

            opBEQ <= '1' WHEN  ir(15 downto 10)="100011" ELSE '0'; -- branch if equal

            opBNE <= '1' WHEN  ir(15 downto 10)="100111" ELSE '0'; -- branch if not equal

            opBLT <= '1' WHEN  ir(15 downto 10)="101011" ELSE '0'; -- branch if less than
				
				opBGT <= '1' WHEN  ir(15 downto 10)="101111" ELSE '0'; -- branch if greater than
				
				opBC <= '1' WHEN  ir(15 downto 10)="110011" ELSE '0'; -- branch if carry
				
				opBNC <= '1' WHEN  ir(15 downto 10)="110111" ELSE '0'; -- branch if not carry
				
				opRJMP <= '1' WHEN  ir(15 downto 10)="111011" ELSE '0'; -- relative unconditional jump
				
				opJMP <= '1' WHEN  ir(15 downto 10)="011111" ELSE '0'; -- unconditional jump
                                                                                               
                             
            -- ***********************************
            -- compute memory address
            disp <= ir(2 downto 0);
            dataAddr <= "00000"&disp + Bout;
           
            MASel <= '1' WHEN exec='1' ELSE '0';  
                              
            WITH MASel SELECT
                  addr <= "00000000" & pc       WHEN '0', -- during fetch phase
                         "00000000" & dataAddr    WHEN '1', -- during exec phase
                        "00000000" & pc             WHEN OTHERS;
 
            -- ***********************************
            -- memory read/write control
            rd <= '0' WHEN (ld='1' AND exec='1' AND clk='0' ) -- load data
                                 OR (fetch='1' AND clk='0')         -- fetch inst
                        ELSE '1'; 
                 
            wr <= '0' WHEN (st='1' AND exec='1' AND clk='0')  -- store data
                       ELSE       '1';     
 
            -- A bus to memory
            data <= Aout WHEN wr='0' ELSE "ZZZZZZZZ";  -- floats the bus
                 
 
            -- ***********************************
            -- Program Counter control
           
            PCaddSel <= '0'&n WHEN skipn='1' ELSE -- add 2
                          '0'&z WHEN skipz='1' ELSE -- add 2
                          "10"  WHEN br='1'    ELSE -- add displacment
                          "00";  -- increment when not a branch or skip
                         
            -- sign extend the displacement field
            displacement <= ir(5) & ir(5) & ir(5) & ir(5) & ir(5 downto 2);
 
            WITH PCaddSel SELECT
                  PCinc <= "00000001"   WHEN "00",
                             "00000010"   WHEN "01",
                             displacement WHEN "10",
                             "00000001"   WHEN OTHERS;
           
            PCnew <= pc + PCinc; -- the updated verion of the PC
                         
            PCinSel <= '1' WHEN jal='1' ELSE  '0';
                                 
            WITH PCinSel SELECT
                  PCin <= PCnew   WHEN '0',
                            Aout    WHEN '1',
                            Aout    WHEN OTHERS;
 
            -- ***********************************
            -- register controls
           
            -- set up register data select
            RegDSel <= "11" WHEN ld='1'  ELSE
                         "01" WHEN jal='1' ELSE
                         "00" WHEN clr='1' ELSE
                         "10" ; -- feedback from alu
 
            -- route the input data
            WITH RegDSel SELECT
                  rdata <= "00000000" WHEN "00",
                             pcnew      WHEN "01",
                             ALUout     WHEN "10",
                             data       WHEN "11",
                            "00000000" WHEN OTHERS;
                             
            -- choose a register for output A, jal always loads r2
            ASel <= "10" WHEN jal='1' ELSE ir(5 downto 4) ;             
                 
            -- choose a register for output B, r2 or r3 used for ld/st disp
            BSel <= '1'&ir(3) WHEN (ld='1' OR st='1') ELSE ir(3 downto 2) ;
           
            -- write enable for registers disable for 4 opcodes
            we <= '0' WHEN  st='1' OR br='1' OR skipn='1' OR skipz='1' ELSE '1' ;
 
            -- A output
            WITH ASel SELECT      
                  Aout <= r0 WHEN "00",
                            r1 WHEN "01",
                            r2 WHEN "10",
                            r3 WHEN OTHERS;
 
            -- B output
            WITH BSel SELECT      
                  Bout <= r0 WHEN "00",
                            r1 WHEN "01",
                            r2 WHEN "10",
                            r3 WHEN OTHERS;
 
            -- ***********************************
            -- ALU controls
 
            -- control the B input to the ALU
            ALUbSel <= "11" WHEN addi='1' ELSE -- DataImm
                         "10" WHEN inot='1' ELSE -- const=1
                         "00" ; --Bout
     
            DataImm <= "0000"&ir(3 downto 0);
 
            -- ALU B input
            WITH ALUbSel SELECT           
                  Bin <= Bout       WHEN "00",
                         "00000000" WHEN "01",
                         "11111111" WHEN "10",
                         DataImm    WHEN OTHERS;
           
            -- ALU function control
            ALUop <= "00" WHEN addi='1'  OR add='1' ELSE
                       "01" WHEN inand='1' OR inot='1' ELSE
                       "10" ;-- shift left
 
            -- ALU
            WITH ALUop SELECT
                  ALUout <= Aout + Bin           WHEN "00", -- add and addi
                              NOT (Aout AND Bin)   WHEN "01", -- nand and not
                              Aout(6 downto 0)&'0' WHEN OTHERS; --shift
 
            -- zero and neg flag control
            zne <= '1' WHEN addi='1' OR add='1' OR inand='1'
                                    OR isll='1' OR inot='1' ELSE
                     '0' ;
 
            -- ***********************************
            -- Timing, reset, and register updates
 
            PROCESS (clk, reset) BEGIN
                 
                  IF reset='1' THEN
                        pc <= "00000000"; -- reset to address zero
                        ir <= "00000000"; -- inst is equiv to clear reg 0
                        r3 <= "11111111"; -- for testing
                        fetch <= '1';
                        exec <= '0';
                       
                  ELSIF (clk='1' AND clk'event) THEN
                 
                        IF fetch='1' THEN
                              ir <= data;
                              fetch <= '0';
                              exec <= '1';                      
                        ELSE
                              pc <= PCin;
                              fetch <= '1';
                              exec <= '0';
                              IF we='1' THEN
                                    CASE ASel IS
                                          WHEN "00" => r0 <= rdata;
                                          WHEN "01" => r1 <= rdata;
                                          WHEN "10" => r2 <= rdata;
                                          WHEN "11" => r3 <= rdata;
                                          WHEN OTHERS => NULL;
                                    END CASE;
                              END IF;
                             
                              IF zne='1' THEN
                                    n <= aluout(7);                               
                                    IF aluout=0 THEN
                                          z <= '1';
                                    ELSE
                                          z <= '0';
                                    END IF;
                              END IF;
                        END IF;
                  END IF;
                       
            END PROCESS;
           
      END one;