LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY image_rom_tb IS
    --  Port ( );
END image_rom_tb;

ARCHITECTURE Behavioral OF image_rom_tb IS
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL data : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL address : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL i : INTEGER := 0;
    COMPONENT dist_mem_gen_0 IS
        PORT (
            a : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
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

    uut : dist_mem_gen_0
    PORT MAP(a => address, spo => data, clk => clk);
    rom_process : PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (i < 4096) THEN
                address <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 12));
                i <= i + 1;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;