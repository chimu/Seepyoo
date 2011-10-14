----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:35:48 10/12/2011 
-- Design Name: 
-- Module Name:    control_unit - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_unit is
	port( clock		: in std_logic;
			resetn	: in std_logic;
			IAddr		: out std_logic_vector(11 downto 0);
			IData		: in	std_logic_vector(15 downto 0);
			I_req		: inout std_logic;
			I_ack		: in std_logic;
			DAddr		: out std_logic_vector(15 downto 0);
			DData		: inout std_logic_vector(7 downto 0);
			D_rnow	: out std_logic;
			D_req		: out std_logic;
			D_ack		: in std_logic
		 );
end control_unit;

architecture Behavioral of control_unit is

-- 
	signal Ireg 			: std_logic_vector(15 downto 0);
	signal PCreg			: std_logic_vector(15 downto 0);
	signal reset_all		: std_logic;
	signal dataA			: std_logic_vector(7 downto 0);
	signal dataB			: std_logic_vector(7 downto 0);
	signal dataResult		: std_logic_vector(7 downto 0);
	signal selA				: std_logic_vector(2 downto 0);
	signal selB				: std_logic_vector(2 downto 0);
	signal readA			: std_logic;
	signal readB			: std_logic;
	signal selResult		: std_logic_vector(2 downto 0);
	signal writeResult	: std_logic;
	signal selAddr			: std_logic_vector(1 downto 0);
	signal readAddr		: std_logic;
	signal addr				: std_logic_vector(15 downto 0);
	signal writeAddrH		: std_logic;
	signal writeAddrL		: std_logic;
	signal decodedI		: decodeType;
	
	type SR_type is -- Status Register bits
		record
			Z	: std_logic;
			N	: std_logic;
			C	: std_logic;
			V	: std_logic;
		end record;
	signal SR				: SR_type;
	
-- Component instantiations
	component ALU 
		port( op					: in std_logic_vector(1 downto 0);
				arith_logic		: in std_logic;
				carry_in			: in std_logic;
				operand_a		: in std_logic_vector(7 downto 0);
				operand_b		: in std_logic_vector(7 downto 0);
				result			: out std_logic_vector(7 downto 0);
				zero				: out std_logic;
				carry				: out std_logic;
				overflow			: out std_logic;
				negative			: out std_logic
			 );
	end component ALU;
	
	component GP_registers
		port( selA	: in std_logic_vector(2 downto 0);
				selB	: in std_logic_vector(2 downto 0);
				enA	: in std_logic;
				enB	: in std_logic;
				A		: out std_logic_vector(7 downto 0);
				B		: out std_logic_vector(7 downto 0);
				selWB	: in std_logic_vector(2 downto 0);
				enWB	: in std_logic;
				inWB	: in std_logic_vector(7 downto 0);
				clock : in std_logic;
				resetn : in std_logic
			 );
	end component GP_registers;
		
	component Addr_registers
		port( selO	: in std_logic_vector(1 downto 0);
				enO	: in std_logic;
				O		: out std_logic_vector(15 downto 0);
				selI	: in std_logic_vector(1 downto 0);
				enIL	: in std_logic;
				enIH	: in std_logic;
				IL		: in std_logic_vector(7 downto 0);
				IH		: in std_logic_vector(7 downto 0);
				clock : in std_logic;
				resetn : in std_logic
			 );
	end component Addr_registers;
	
	component decoder
		port( instruction	: in std_logic_vector(15 downto 0);
				decodedI		: out decodeType
			 );
	end component decoder;
	
-- state type
	type CPU_state_type is (reset, fetch_request, fetch_addr, fetch_read,decode,execute,write_back);
	signal cpu_state : CPU_state_type;
	signal next_cpu_state : CPU_state_type;
	
begin

	GP_regs: GP_registers -- Map the general purpose register port
				port map( selA	 => selA,
							 selB	 => selB,
							 enA	 => readA,
							 enB	 => readB,
							 A		 => dataA,
							 B		 => dataB,
							 selWB => selResult,
							 enWB  => writeResult,	
							 inWB	 => dataResult,
							 clock => clock,
							 resetn => reset_all
						  );
						  
	Addr_regs: Addr_registers -- Map the address register port
				  port map( selO		=> selAddr,
								enO		=> readAddr,
								O			=> addr,
								selI		=> selAddr,
								enIL		=> writeAddrH,
								enIH		=> writeAddrL,
								IL			=> dataA,
								IH			=> dataA,
								clock 	=> clock,
								resetn 	=> reset_all
							 );
							 
	ALU_i: ALU
			 port map( op				=> decodedI.ALU_op,
						  arith_logic	=> decodedI.ALU_mode,
						  carry_in		=> SR.C,
						  operand_a		=> dataA,
						  operand_b		=> dataB,
						  result			=> dataResult,
						  zero			=> SR.Z,
						  carry			=> SR.C,
						  overflow		=> SR.V,
						  negative		=> SR.N
			         );
					
	decoder_i: component decoder
				  port map( instruction => Ireg,
								decodedI 	=> decodedI
							 );
					
	process (clock, resetn)
	begin
		if resetn = '0' then
			cpu_state <= reset;
		elsif rising_edge(clock) then
			cpu_state <= next_cpu_state;
		end if;
		
		case cpu_state is
			when reset =>
				if resetn = '0' then
					next_cpu_state <= reset;
				else
					next_cpu_state <= fetch_request;
				end if;
			when fetch_request =>
				if I_req = '0' then
					next_cpu_state <= fetch_request;
				else
					next_cpu_state <= fetch_addr;
				end if;
			when fetch_addr =>
				if I_ack = '0' then
					next_cpu_state <= fetch_addr;
				else
					next_cpu_state <= fetch_read;
				end if;
			when fetch_read =>
				next_cpu_state <= decode;
			when decode =>
				next_cpu_state <= execute;
			when execute =>
				next_cpu_state <= write_back;
			when write_back =>
				next_cpu_state <= fetch_request;
		end case;
		case cpu_state is
			when reset =>
				PCreg <= "0000000000000000";
				Ireg <= "0000000000000000";
				reset_all <= '0';
--				decodedI <= (ALU_op=>"00",
--								 ALU_mode=>'0',
--								 memory_op=>'0',
--								 immediate=>"00000000",
--								 has_immediate=>'0',
--								 GP_regA=>"000",
--								 GP_regB=>"000",
--								 Addr_reg=>"00"
--								 );
				I_req <= '1';
			when fetch_request =>
				
			when fetch_addr =>
				I_req <= '0';
				IAddr <= PCreg(11 downto 0);
			when fetch_read =>
				Ireg <= IData;
				I_req <= '0';
			when decode =>
				
			when execute =>
			when write_back =>
		end case;
	end process;
	
	

end Behavioral;

