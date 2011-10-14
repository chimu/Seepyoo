----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:38:17 10/12/2011 
-- Design Name: 
-- Module Name:    GP_registers - Behavioral 
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

entity GP_registers is
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
end GP_registers;

architecture Behavioral of GP_registers is

begin


end Behavioral;

