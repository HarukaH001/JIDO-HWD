----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:41:40 05/24/2021 
-- Design Name: 
-- Module Name:    T_FLIPFLOP - Behavioral 
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

entity T_FLIPFLOP is
    Port ( CLK : in  STD_LOGIC;
			  R : in STD_LOGIC;
           Q : out  STD_LOGIC;
           NOTQ : out  STD_LOGIC);
end T_FLIPFLOP;

architecture Behavioral of T_FLIPFLOP is
signal tmp : std_logic := '0';
begin
	process (CLK, R)
	begin
		if(R = '1') then
			tmp <= '0';
		elsif (falling_edge(CLK)) then
			tmp <= not tmp;
		end if;
	end process;
	Q <= tmp;
	NOTQ <= not tmp;
end Behavioral;

