----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2023 09:37:31
-- Design Name: 
-- Module Name: HW3 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY MAC_testbench IS
    --  Port ( );
END MAC_testbench;

ARCHITECTURE Behavioral OF MAC_testbench IS
    -
    CONSTANT CLK_PERIOD : TIME := 10 ns;
    CONSTANT SIM_TIME : TIME := 100 ns;
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL cntrl : STD_LOGIC := '0';
    SIGNAL input_1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00001001"; -- Example data
    SIGNAL input_2 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000110"; -- Example data
    SIGNAL output : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN

    UUT : ENTITY WORK.MAC
        PORT MAP(
            clk => clk,
            cntrl => cntrl,
            input_1 => input_1,
            input_2 => input_2,
            output => output
        );
    PROCESS
    BEGIN
        WHILE now < SIM_TIME LOOP
            clk <= NOT clk; -- Toggle the clock
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
        WAIT;
    END PROCESS;
    PROCESS
    BEGIN

        cntrl <= '0';
        input_1 <= "00001001";
        input_2 <= "00000110";
        WAIT FOR CLK_PERIOD * 2;
        cntrl <= '1';
        WAIT FOR CLK_PERIOD * 2;
        WAIT FOR CLK_PERIOD;

        WAIT;
    END PROCESS;

END Behavioral;