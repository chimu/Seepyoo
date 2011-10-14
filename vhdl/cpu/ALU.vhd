----------------------------------------------------------------------------------
-- Company: N\A
-- Engineer: Pual Davey
--           Henry Wilkinson
-- 
-- Create Date:    15:32:42 10/12/2011 
-- Design Name: 	Seepyoo microcontroller
-- Module Name:    ALU - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: ALU for simple CPU
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--  http://www.cs.umbc.edu/portal/help/VHDL/sequential.html#case used as vhdl reference
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
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
end ALU;

architecture Behavioral of ALU is

begin
	process ( op, arith_logic, carry_in, operand_a, operand_b ) is
		variable temp_result		: std_logic_vector(8 downto 0);
	begin
		if arith_logic = '0' then
			case  op is 
				when "00" =>
					temp_result := operand_a and operand_b;
					negative <= temp_result(7);
					overflow <= '0';
					carry <= '0';
					if temp_result(7 downto 0) = "00000000" then
						zero <= '1';
					else
						zero <= '0';
					end if;
					result <= temp_result(7 downto 0);
				when "01" =>
					temp_result := operand_a or operand_b;
					negative <= temp_result(7);
					overflow <= '0';
					carry <= '0';
					if temp_result(7 downto 0) = "00000000" then
						zero <= '1';
					else
						zero <= '0';
					end if;
					result <= temp_result(7 downto 0);
				when "10" =>
					temp_result := not operand_a;
					negative <= temp_result(7);
					overflow <= '0';
					carry <= '0';
					if temp_result(7 downto 0) = "00000000" then
						zero <= '1';
					else
						zero <= '0';
					end if;
					result <= temp_result(7 downto 0);
				when "11" =>
					temp_result := operand_a xor operand_b;
					negative <= temp_result(7);
					overflow <= '0';
					carry <= '0';
					if temp_result(7 downto 0) = "00000000" then
						zero <= '1';
					else
						zero <= '0';
					end if;
					result <= temp_result(7 downto 0);
				when others =>
					result <= (others=>'0');
					negative <= '0';
					overflow <= '0';
					carry <= '0';
					zero <= '0';
			end case;
		else
			case op is
				when "00" =>
					temp_result := std_logic_vector(signed( '0' & operand_a ) + signed( operand_b ) );
					carry <= temp_result(8);
					negative <= temp_result(7);
					overflow <= temp_result(8) xor temp_result(7);
					if temp_result(7 downto 0) = "00000000" then
						zero <= '1';
					else
						zero <= '0';
					end if;
					result <= temp_result(7 downto 0);
				when "01" =>
					temp_result := std_logic_vector( signed( '0' & operand_a & carry_in) + signed( operand_b & '0' ) );
					carry <= temp_result(8);
					negative <= temp_result(7);
					overflow <= temp_result(8) xor temp_result(7);
					if temp_result(7 downto 0) = "00000000" then
						zero <= '1';
					else
						zero <= '0';
					end if;
					result <= temp_result(7 downto 0);
				when "10" =>
					temp_result := std_logic_vector(signed( '0' & operand_a ) - signed( operand_b ) );
					carry <= temp_result(8);
					negative <= temp_result(7);
					overflow <= temp_result(8) xor temp_result(7);
					if temp_result(7 downto 0) = "00000000" then
						zero <= '1';
					else
						zero <= '0';
					end if;
					result <= temp_result(7 downto 0);
				when "11" =>
					temp_result := std_logic_vector( signed( '0' & operand_a & carry_in) - signed( operand_b & '0' ) );
					carry <= temp_result(8);
					negative <= temp_result(7);
					overflow <= temp_result(8) xor temp_result(7);
					if temp_result(7 downto 0) = "00000000" then
						zero <= '1';
					else
						zero <= '0';
					end if;
					result <= temp_result(7 downto 0);
				when others =>
					result <= (others=>'0');
					carry <= '0';
					negative <= '0';
					overflow <= '0';
					zero <= '0';
			end case;
		end if;
	end process;

end Behavioral;

