----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:20:15 05/24/2021 
-- Design Name: 
-- Module Name:    main - Behavioral 
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

entity main is
    Port ( RX : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           MISO : in  STD_LOGIC;
           TX : out  STD_LOGIC;
           --SLOT1 : out  STD_LOGIC_VECTOR (2 downto 0);
           --SLOT2 : out  STD_LOGIC_VECTOR (2 downto 0);
           MOSI : out  STD_LOGIC;
           SCLK : out  STD_LOGIC;
           CS : out  STD_LOGIC;
			  TIRRES : in std_logic_vector (7 downto 0);
			  TRDY	: in std_logic;
			  DEBUG: buffer std_logic_vector (7 downto 0);
			  LOGIC: buffer std_logic_vector (7 downto 0));
end main;

architecture Behavioral of main is
component UART_Receiver
    Port ( RX : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           UOUT : out  STD_LOGIC_VECTOR (1 downto 0);
           TRIGGER : out  STD_LOGIC;
			  LOG : out std_logic_vector (7 downto 0));
end component;
component UART_Transmitter
    Port ( DATA : in  STD_LOGIC_VECTOR (7 downto 0);
           CLK : in  STD_LOGIC;
           EN : in  STD_LOGIC;
           TX : out  STD_LOGIC;
			  LOG : out STD_LOGIC;
			  SOUT : out std_logic_vector(3 downto 0));
end component;
component Command_Handler
    Port ( IRRES : in  STD_LOGIC_VECTOR (7 downto 0);
           CIN : in  STD_LOGIC_VECTOR (1 downto 0);
           RDY : in  STD_LOGIC;
           EN : in  STD_LOGIC;
           RES : out  STD_LOGIC_VECTOR (7 downto 0);
           CT : out  STD_LOGIC;
           CSEL : out  STD_LOGIC;
           SEND : out  STD_LOGIC);
end component;
component IR_Handler
    Port ( MISO : in  STD_LOGIC;
			  CLK : in  STD_LOGIC;
           MOSI : out  STD_LOGIC;
           CS : out  STD_LOGIC;
           SCK : out  STD_LOGIC;
           RES : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

signal URUOUT										: std_logic_vector (1 downto 0);
signal URTRIGGER									: std_logic := '0';
signal testTX										: std_logic := '0';
signal LOG											: std_logic := '0';
signal sled											: std_logic_vector(3 downto 0);
signal CRES											: std_logic_vector(7 downto 0);
signal CMCT											: std_logic;
signal CMCSEL										: std_logic;
signal CMSEND										: std_logic;
signal IRRES										: std_logic_vector (7 downto 0) := "11110000";
signal DUMP											: std_logic_vector(7 downto 0) := "00000000";
begin
	UR : UART_Receiver							port map (	RX				=> RX,
																		CLK			=> CLK,
																		UOUT			=> URUOUT,
																		TRIGGER		=> URTRIGGER,
																		LOG			=> DUMP);
	
	CM : Command_Handler							port map (	IRRES			=> IRRES,
																		CIN			=> URUOUT,
																		RDY			=> TRDY,
																		EN				=> URTRIGGER,
																		RES			=> CRES,
																		CT				=> CMCT,
																		CSEL			=> CMCSEL,
																		SEND			=> CMSEND);
																		
	UT : UART_Transmitter						port map (	DATA			=> CRES,
																		CLK			=> CLK,
																		EN				=> CMSEND,
																		TX				=> testTX,
																		LOG			=> LOG,
																		SOUT			=> sled);
	TX <= testTX;
	
	IR : IR_Handler								port map (	MISO			=> MISO,
																		CLK			=> CLK,
																		MOSI			=> MOSI,
																		CS				=> CS,
																		SCK			=> SCLK,
																		RES			=> IRRES);
	
	--MOSI <= '1';
	--CS <= '1';
	--SCLK <= '1';
	--IRRES <= "01010111";
	
	LOGIC <= IRRES;--CRES;
	DEBUG <= CRES;--IRRES;
	
end Behavioral;

