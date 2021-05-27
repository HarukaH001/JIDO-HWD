----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:31:05 05/25/2021 
-- Design Name: 
-- Module Name:    UART_Transmitter - Behavioral 
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

entity UART_Transmitter is
    Port ( DATA : in  STD_LOGIC_VECTOR (7 downto 0);
           CLK : in  STD_LOGIC;
           EN : in  STD_LOGIC;
           TX : out  STD_LOGIC;
			  LOG : out STD_LOGIC;
			  SOUT : out std_logic_vector(3 downto 0));
end UART_Transmitter;

architecture Behavioral of UART_Transmitter is
component D_FLIPFLOP
    Port ( D : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           R : in  STD_LOGIC;
           Q : out  STD_LOGIC);
end component;
component DIV20M_UART8X
    Port ( CLK_IN : in  STD_LOGIC;
           CLK_OUT : out  STD_LOGIC);
end component;
component Counter_0_10
    Port ( CLK : in  STD_LOGIC;
           R : in  STD_LOGIC;
           S : out  STD_LOGIC_VECTOR (3 downto 0);
           TC : out  STD_LOGIC);
end component;
component Counter_0_9
    Port ( CLK : in  STD_LOGIC;
           R : in  STD_LOGIC;
           S : out  STD_LOGIC_VECTOR (3 downto 0);
           TC : out  STD_LOGIC);
end component;
component Counter_0_7
    Port ( CLK : in  STD_LOGIC;
           R : in  STD_LOGIC;
           S : out  STD_LOGIC_VECTOR (2 downto 0);
           TC : out  STD_LOGIC);
end component;

signal DIVOUT : std_logic := '0';
signal DFFR_C07R_C10R_C10TC : std_logic := '0';
signal DFFQ : std_logic := '0';
signal C07CLK : std_logic := '0';
signal C07S : std_logic_vector (2 downto 0) := "000";
signal C07TC_C10CLK_C09CLK : std_logic := '0';
signal C10S : std_logic_vector (3 downto 0) := "0000";
signal C09S : std_logic_vector (3 downto 0) := "0000";
signal C09R : std_logic := '0';
signal C09TC : std_logic := '0';

constant DFFD : std_logic := '1';
signal tmp : std_logic := '0';
begin
DIV : DIV20M_UART8X port map ( CLK_IN => CLK, CLK_OUT => DIVOUT);
DFF : D_FLIPFLOP port map ( D => DFFD, CLK => EN, R => DFFR_C07R_C10R_C10TC, Q => DFFQ); 
C07CLK <= DIVOUT and DFFQ;
C07 : Counter_0_7 port map ( CLK => C07CLK, R => DFFR_C07R_C10R_C10TC, S => C07S, TC => C07TC_C10CLK_C09CLK);
C10 : Counter_0_10 port map ( CLK => C07TC_C10CLK_C09CLK, R => DFFR_C07R_C10R_C10TC, S => C10S, TC => DFFR_C07R_C10R_C10TC);
C09 : Counter_0_9 port map ( CLK => C07TC_C10CLK_C09CLK, R => DFFR_C07R_C10R_C10TC, S => C09S, TC => C09TC);
with C09S select TX <=	'1' when "0000",
								'0' when "0001",
								DATA(0) when "0010",
								DATA(1) when "0011",
								DATA(2) when "0100",
								DATA(3) when "0101",
								DATA(4) when "0110",
								DATA(5) when "0111",
								DATA(6) when "1000",
								DATA(7) when "1001",
								'1' when others;
SOUT <= C09S;
end Behavioral;

