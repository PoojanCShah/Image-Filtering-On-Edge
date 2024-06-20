-- Company:
-- Engineer:
-- 
-- Create Date: 06.11.2023 11:12:28
-- Design Name:
-- Module Name: MAC - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY MAC IS
    PORT (
        clk : IN STD_LOGIC;
        cntrl : IN STD_LOGIC;
        input_1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        input_2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        output : out integer );
END MAC;

ARCHITECTURE Behavioral OF MAC IS
    SIGNAL sum : INTEGER := 0;
    SIGNAL product : INTEGER := 0;
    signal flag : integer := 0 ;
    signal eclk : std_logic := '1' ; 
BEGIN
    
    output <= sum;
--    output <= STD_LOGIC_VECTOR(to_signed(sum, 16));
    -- product <= to_integer(unsigned(input_1)) * to_integer(signed(input_2));

    PROCESS (clk)
    variable product : integer ;
    BEGIN

        IF (rising_edge(clk)) THEN
           
            product := to_integer(unsigned(input_1)) * to_integer(signed(input_2));
            IF (cntrl = '0') THEN
                sum <= product;
            ELSE
                    
                sum <= sum + product;
           
            END IF;
            
            
        END IF;
    END PROCESS;

END Behavioral;