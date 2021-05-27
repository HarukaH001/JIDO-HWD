----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:54:42 05/26/2021 
-- Design Name: 
-- Module Name:    IR_Handler - Behavioral 
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

entity IR_Handler is
    Port ( MISO : in  STD_LOGIC;
			  CLK : in  STD_LOGIC;
           MOSI : out  STD_LOGIC;
           CS : out  STD_LOGIC;
           SCK : out  STD_LOGIC;
           RES : buffer  STD_LOGIC_VECTOR (7 downto 0));
end IR_Handler;

architecture Behavioral of IR_Handler is
component DIV20M_4M
    Port ( CLK_IN : in  STD_LOGIC;
           CLK_OUT : out  STD_LOGIC);
end component;
component DIV20M_100
    Port ( CLK_IN : in  STD_LOGIC;
           CLK_OUT : out  STD_LOGIC);
end component;
component Counter_0_16
    Port ( CLK : in  STD_LOGIC;
           R : in  STD_LOGIC;
           S : out  STD_LOGIC_VECTOR (4 downto 0);
           TC : out  STD_LOGIC);
end component;
component Counter_0_7
    Port ( CLK : in  STD_LOGIC;
           R : in  STD_LOGIC;
           S : out  STD_LOGIC_VECTOR (2 downto 0);
           TC : out  STD_LOGIC);
end component;
component D_FLIPFLOP
    Port ( D : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           R : in  STD_LOGIC;
           Q : out  STD_LOGIC);
end component;

signal DIVOUT : std_logic := '0';
signal DIVOUT0 : std_logic := '0';
constant DF1D : std_logic := '1';
signal C16TC : std_logic := '0';
signal DF1Q : std_logic := '0';
signal DF2CLK : std_logic := '0';
signal DF2Q : std_logic := '0';
signal DF2NOTQ : std_logic;
signal C16S : std_logic_vector (4 downto 0):= "00000";

signal BUFF : std_logic_vector (16 downto 0) := "00000000000000000";

signal CONV : std_logic_vector (9 downto 0) := "0000000000";
signal DETECT : std_logic := '0';

signal C07CLK : std_logic := '0';
signal C07R : std_logic := '0';
signal C07S : std_logic_vector (2 downto 0) := "000";
signal C07TC : std_logic := '0';

signal PAYLOAD : std_logic_vector (7 downto 0) := "00000000";
--signal DATARDY : std_logic_vector (7 downto 0) := "00000000";

begin
-------------------------------------------------------------------------------SCANNER
DIV0 : DIV20M_100 port map ( CLK_IN => CLK, CLK_OUT => DIVOUT0);
C07CLK <= DIVOUT0 and DF2NOTQ;
C07 : Counter_0_7 port map ( CLK => C07CLK, R => C07R, S => C07S, TC => C07TC);
-------------------------------------------------------------------------------SPI COMMUNICATION
DIV1 : DIV20M_4M port map ( CLK_IN => CLK, CLK_OUT => DIVOUT);
SCK <= DIVOUT; 
DF1 : D_FLIPFLOP port map ( D => DF1D, CLK => C07CLK, R => C16TC, Q => DF1Q);
DF2CLK <= not (DF1Q and DIVOUT);
DF2 : D_FLIPFLOP port map ( D => DF1D, CLK => DF2CLK, R => C16TC, Q => DF2Q);
DF2NOTQ <= not DF2Q;
CS <= DF2NOTQ;
C16 : Counter_0_16 port map ( CLK => DF2CLK, R => C16TC, S => C16S, TC => C16TC);
with C16S select MOSI <= 	'1' when "00000",
									'1' when "00001",
									'1' when "00010",
									C07S(2) when "00011",
									C07S(1) when "00100",
									C07S(0) when "00101",
									'0' when others;
									
process (DF2CLK)
begin
	if(rising_edge(DF2CLK)) then
		BUFF <= BUFF(15 downto 0)&MISO;
	end if;
end process;
CONV <= BUFF(9 downto 0);
-------------------------------------------------------------------------------DATA COMPARISON
DETECT <= CONV(8) or CONV(7) or CONV(6) or CONV(5);
-------------------------------------------------------------------------------DATA REGISTRATION
process(C16TC)
begin
	if(rising_edge(C16TC)) then
		case C07S is
			when "000" =>
				PAYLOAD(5) <= DETECT;
			when "001" =>
				PAYLOAD(4) <= DETECT;
			when "010" =>
				PAYLOAD(3) <= DETECT;
			when "011" =>
				PAYLOAD(2) <= DETECT;
			when "100" =>
				PAYLOAD(1) <= DETECT;
			when "101" =>
				PAYLOAD(0) <= DETECT;
			when others =>
				PAYLOAD <= PAYLOAD;
		end case;
		--if(C05S = "000") then
		--	PAYLOAD <= DETECT&CONV(6 downto 0);
		--end if;
		--if(C07S = "110") then
		--	DATARDY <= PAYLOAD;
		--end if;
	end if;
end process;
-------------------------------------------------------------------------------OUTPUT
RES <= PAYLOAD;
end Behavioral;

