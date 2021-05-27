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
use IEEE.NUMERIC_STD.ALL;

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
           SLOT1 : inout  STD_LOGIC_VECTOR (2 downto 0);
           SLOT2 : inout  STD_LOGIC_VECTOR (2 downto 0);
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

component DIV20M_100
    Port ( CLK_IN : in  STD_LOGIC;
           CLK_OUT : out  STD_LOGIC);
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

signal CMRDY										: std_logic;
signal PULSE										: std_logic;
signal TIMER										: std_logic;
signal count 										: integer range 0 to 100 := 0;
signal DIVOUT										: std_logic;
signal R										: std_logic;
begin
	UR : UART_Receiver							port map (	RX				=> RX,
																		CLK			=> CLK,
																		UOUT			=> URUOUT,
																		TRIGGER		=> URTRIGGER,
																		LOG			=> DUMP);
	
	CM : Command_Handler							port map (	IRRES			=> IRRES,
																		CIN			=> URUOUT,
																		RDY			=> CMRDY,
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
	
	CMRDY <= SLOT1(2) and SLOT2(2);
	
	----------------------------------------------------------------------PULSE GENERATOR
	------------------------------------------------------PULSE TRIGGER
	DIV100 : DIV20M_100 port map ( CLK_IN => CLK, CLK_OUT => DIVOUT);
	process (CMCT, R)
	begin
		if (R = '1') then
			PULSE <= '0';
		elsif(rising_edge(CMCT)) then
			PULSE <= '1';
		end if;
	end process;
	
	TIMER <= DIVOUT and PULSE;
	------------------------------------------------------PULSE DELAY 1S
	process (TIMER, CMCT, R)
	begin
		if (CMCT = '1' or R = '1') then
			count <= 0;
			R <= '0';
		elsif (rising_edge(TIMER)) then
			count <= count + 1;
			if (count = 100) then
				R <= '1';
			else
				R <= '0';
			end if;
		end if;
	end process;
	
	SLOT1 <= SLOT1(2)&PULSE&CMCSEL;
	SLOT2 <= SLOT2(2)&PULSE&CMCSEL;
	
	LOGIC <= IRRES;--CRES;
	DEBUG <= CRES;--IRRES;
	
end Behavioral;

