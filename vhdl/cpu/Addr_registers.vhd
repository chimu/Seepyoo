----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:38:43 10/12/2011 
-- Design Name: 
-- Module Name:    Addr_registers - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Addr_registers is
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
end Addr_registers;

architecture Behavioral of Addr_registers is

begin


end Behavioral;

