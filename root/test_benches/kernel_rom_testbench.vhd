LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY kernel_rom_tb IS
    --  Port ( );
END kernel_rom_tb;

ARCHITECTURE Behavioral OF kernel_rom_tb IS
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL data : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL address : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL i : INTEGER := 0;
    COMPONENT dist_mem_gen_1 IS
        PORT (
            a : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            clk : IN STD_LOGIC);
    END COMPONENT;
BEGIN
    clock_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR 5ns;
        clk <= '1';
        WAIT FOR 5ns;
    END PROCESS;

    uut : dist_mem_gen_1
    PORT MAP(a => address, spo => data, clk => clk);
    rom_process : PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (i < 9) THEN
                address <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 4));
                i <= i + 1;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;