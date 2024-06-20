



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY REG IS
    PORT (
        clk : IN STD_LOGIC;
        we : IN STD_LOGIC;
        input : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END REG;
ARCHITECTURE Behavioral OF REG IS

BEGIN
    PROCESS (input)
    BEGIN
--        IF (rising_edge(clk)) THEN
            IF (we = '1') THEN
                output <= input;
            END IF;
--        END IF;
    END PROCESS;
END Behavioral;


