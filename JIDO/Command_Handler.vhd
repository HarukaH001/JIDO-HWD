----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:12:18 05/25/2021 
-- Design Name: 
-- Module Name:    Command_Handler - Behavioral 
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

entity Command_Handler is
    Port ( IRRES : in  STD_LOGIC_VECTOR (7 downto 0);
           CIN : in  STD_LOGIC_VECTOR (1 downto 0);
           RDY : in  STD_LOGIC;
           EN : in  STD_LOGIC;
           RES : out  STD_LOGIC_VECTOR (7 downto 0);
           CT : out  STD_LOGIC;
           CSEL : out  STD_LOGIC;
           SEND : out  STD_LOGIC);
end Command_Handler;

architecture Behavioral of Command_Handler is

component Response_Encoder_3_2
    Port ( I1 : in  STD_LOGIC;
           I2 : in  STD_LOGIC;
           I3 : in  STD_LOGIC;
           O : out  STD_LOGIC_VECTOR(1 downto 0));
end component;
signal I1 : STD_LOGIC := '0';
signal I2 : STD_LOGIC := '0';
signal I3 : STD_LOGIC := '0';
signal O  : STD_LOGIC_VECTOR(1 downto 0);

signal CIN_SEL1 : STD_LOGIC := '0';
signal CIN_SEL2 : STD_LOGIC := '0';

signal RDY_STEP_MOTOR : STD_LOGIC := '0';

--res template
constant OCCUPYRES  : STD_LOGIC_VECTOR(7 downto 0) := "01000000";
constant STARTEDRES : STD_LOGIC_VECTOR(7 downto 0) := "10000000";
constant ERRORRES   : STD_LOGIC_VECTOR(7 downto 0) := "01010101";

signal RDYRES		: STD_LOGIC_VECTOR(7 downto 0);

begin
I1 <= (not CIN(0)) and (not CIN(1));

CIN_SEL1 <= CIN(0) and (not CIN(1));
CIN_SEL2 <= (not CIN(0)) and CIN(1);
I2 <= CIN_SEL1 or CIN_SEL2;

I3 <= CIN(0) and CIN(1);

RE : Response_Encoder_3_2 port map(I1 => I1, I2 => I2, I3 => I3, O  => O);

RDY_STEP_MOTOR <= RDY and I1;

with RDY_STEP_MOTOR select
	RDYRES <= IRRES when '1',
				 OCCUPYRES when others;
				 
with O select
	RES <= RDYRES when "00",
			 STARTEDRES when "01",
			 ERRORRES when others;
											
CT <= EN and I2;

CSEL <= CIN_SEL2;

SEND <= EN;

end Behavioral;

