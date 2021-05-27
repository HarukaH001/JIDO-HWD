----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:51:51 05/25/2021 
-- Design Name: 
-- Module Name:    D_FLIPFLOP - Behavioral 
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

entity D_FLIPFLOP is
    Port ( D : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           R : in  STD_LOGIC;
           Q : out  STD_LOGIC);
end D_FLIPFLOP;

architecture Behavioral of D_FLIPFLOP is
signal temp : std_logic := '0';
begin
process (CLK, R)
begin
	if(R = '1') then 
		temp <= '0';
	elsif (rising_edge(CLK)) then
		temp <= D;
	end if;
end process;
Q <= temp;
end Behavioral;

