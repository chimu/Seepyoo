--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package types is

-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--

	type branch_type is (Z,N,C,Unconditional);

	type decodeType is
		record
			ALU_op  				: std_logic_vector(1 downto 0);
			ALU_mode				: std_logic;
			memory_op			: std_logic;
			immediate			: std_logic_vector(7 downto 0);
			has_immediate		: std_logic;
			GP_regA				: std_logic_vector(2 downto 0);
			GP_regB				: std_logic_vector(2 downto 0);
			Addr_reg				: std_logic_vector(1 downto 0);
			branch				: std_logic;
			branch_on			: branch_type;
			branch_sense		: std_logic;
			move					: std_logic;
			fromA					: std_logic;
			toA					: std_logic;
			HighByte				: std_logic;
			store					: std_logic;
			inc					: std_logic;
			dec					: std_logic;
			alu					: std_logic;
			writeResult			: std_logic;
			neg					: std_logic;
		end record;
		
end types;

package body types is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end types;
