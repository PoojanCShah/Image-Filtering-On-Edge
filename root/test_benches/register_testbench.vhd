LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

ENTITY register_testbench IS
    --  Port ( );
END register_testbench;

ARCHITECTURE Behavioral OF register_testbench IS

    SIGNAL clok : STD_LOGIC := '0';
    SIGNAL we : STD_LOGIC := '1';
    SIGNAL d : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000011";
    SIGNAL q : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000001";
    COMPONENT REG IS
        PORT (
            clk : IN STD_LOGIC;
            we : IN STD_LOGIC;
            input : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            output : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
    END COMPONENT;

BEGIN

    PROCESS
    BEGIN
        clok <= '1';
        WAIT FOR 10ns;
        clok <= '0';
        WAIT FOR 10 ns;
    END PROCESS;

    uut : REG
    PORT MAP(
        clk => clok, -- Corrected the clock signal connection
        we => we, -- Corrected the write enable connection
        input => d, -- Corrected the input data connection
        output => q -- Corrected the output data connection
    );

    d <= "00010101", "01111101" AFTER 10 ns, "00000111" AFTER 15ns;
    we <= '0' AFTER 20 ns, '1' AFTER 40 ns, '0' AFTER 60 ns;
END Behavioral;