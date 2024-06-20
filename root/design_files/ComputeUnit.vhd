
------------------------------------------------------------------------
-- Company:
-- Engineer:
-- 
-- Create Date: 11/07/2023 02:26:22 PM
-- Design Name:
-- Module Name: ComputeUnit - Behavioral
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
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY ComputeUnit IS
    PORT (

        l1 : OUT STD_LOGIC;
        --        --     hPo: out integer;
        --        --      vPo: out integer;
        rclk : IN STD_LOGIC;
        sw : IN STD_LOGIC;
        pixel_value : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        RST : IN STD_LOGIC;
        HSYNC : OUT STD_LOGIC;
        VSYNC : OUT STD_LOGIC;
        R0 : OUT STD_LOGIC;
        R1 : OUT STD_LOGIC;
        R2 : OUT STD_LOGIC;
        R3 : OUT STD_LOGIC;
        B0 : OUT STD_LOGIC;
        B1 : OUT STD_LOGIC;
        B2 : OUT STD_LOGIC;
        B3 : OUT STD_LOGIC;
        G0 : OUT STD_LOGIC;
        G1 : OUT STD_LOGIC;
        G2 : OUT STD_LOGIC;
        G3 : OUT STD_LOGIC
    );
END ComputeUnit;

ARCHITECTURE MACHINE OF ComputeUnit IS

    COMPONENT blk_mem_gen_0
        PORT (
            addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            clka : IN STD_LOGIC
        );
    END COMPONENT;

    COMPONENT blk_mem_gen_1
        PORT (
            addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            clka : IN STD_LOGIC
        );
    END COMPONENT;

    COMPONENT blk_mem_gen_2
        PORT (
            addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            clka : IN STD_LOGIC;
            wea : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
            dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT MAC
        PORT (
            clk : IN STD_LOGIC;
            cntrl : IN STD_LOGIC;
            input_1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            input_2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            --        output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
            output : OUT INTEGER
        );
    END COMPONENT;

    COMPONENT vga
        PORT (
            hcter : OUT INTEGER;
            vcter : OUT INTEGER;
            clk25hz : IN STD_LOGIC;
            pixel_value : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            RST : IN STD_LOGIC;

            HSYNC : OUT STD_LOGIC;
            VSYNC : OUT STD_LOGIC;
            R : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            G : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            B : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)

        );
    END COMPONENT;

    -- states
    TYPE sub_state_type IS (Position_Update, Accumulate, RAM_write, Next_Address);
    SIGNAL cur_state : sub_state_type := Position_Update;
    SIGNAL filter_comp : STD_LOGIC := '1';
    SIGNAL filter_comp_substate_max_min : STD_LOGIC := '1';
    -- end states
    --signals in this gaurd
    SIGNAL enable : STD_LOGIC := '1';
    SIGNAL pix_bus : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL hcounter : INTEGER := 0;
    SIGNAL vcounter : INTEGER := 0;
    --    signal sw : std_logic := '0';
    --    constant clk_period : time := 10ns;
    --    signal rclk : std_logic := '1';
    --signal l1 : std_logic := '1';
    SIGNAL clock_25 : STD_LOGIC := '1';
    SIGNAL flag2 : INTEGER := 0;

    SIGNAL rom_address : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rom_out_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL ker_addr : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL kerdata : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL ram_out_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ram_address : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ram_in_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ram_write_enable : STD_LOGIC_VECTOR(0 DOWNTO 0) := (OTHERS => '1');

    SIGNAL mac_control : STD_LOGIC := '1';
    SIGNAL mac_input1 : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mac_input2 : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mac_output : INTEGER := 0;

    SIGNAL x : INTEGER := 0;
    SIGNAL y : INTEGER := 0;
    SIGNAL ker_pos : INTEGER := 0;
    SIGNAL mac_done : STD_LOGIC := '1';

    SIGNAL infimum : INTEGER := 9999;
    SIGNAL supremum : INTEGER := - 9999;
    SIGNAL temp_ram_address : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL valid_rom_data : STD_LOGIC := '1';

    SIGNAL rom_driver_during_comp : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rom_driver_during_disp : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ram_driver_during_comp : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ram_driver_during_disp : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');

    --end signal gaurd 

BEGIN

    -- port mapping in this gaurd

    ROMmap : blk_mem_gen_0
    PORT MAP(
        clka => rclk,
        douta => rom_out_data,
        addra => rom_address
    );

    KernalMap : blk_mem_gen_1
    PORT MAP(
        clka => rclk,
        douta => kerdata,
        addra => ker_addr
    );

    RAMmap : blk_mem_gen_2
    PORT MAP(
        clka => rclk,
        douta => ram_out_data,
        dina => ram_in_data,
        wea => ram_write_enable,
        addra => ram_address
    );
    MAC_map : MAC
    PORT MAP(
        input_1 => mac_input1,
        input_2 => mac_input2,
        clk => clock_25,
        output => mac_output,
        cntrl => mac_control
    );

    uut : vga
    PORT MAP(
        hcter => hcounter,
        vcter => vcounter,
        clk25hz => clock_25,
        pixel_value => pix_bus,
        RST => enable,

        HSYNC => HSYNC,
        VSYNC => VSYNC,
        R(0) => R0,
        R(1) => R1,
        R(2) => R2,
        R(3) => R3,
        B(0) => B0,
        B(1) => B1,
        B(2) => B2,
        B(3) => B3,
        G(0) => G0,
        G(1) => G1,
        G(2) => G2,
        G(3) => G3
    );
    --  end mapping gaurd
    clk_proc : PROCESS (rclk)
    BEGIN
        IF (rising_edge (rclk)) THEN
            IF (flag2 = 0) THEN
                clock_25 <= '1';
                flag2 <= flag2 + 1;
            ELSIF (flag2 = 2) THEN
                clock_25 <= '0';
                flag2 <= - 1;
            ELSE
                flag2 <= flag2 + 1;
            END IF;
        END IF;
    END PROCESS;

    --    c_proc: process
    --    begin
    --    rclk <= '1';
    --    wait for clk_period/2 ;
    --    rclk <='0';
    --    wait for clk_period/2;
    --    end process;

    process_to_choose_which_image : PROCESS (sw, clock_25)
    BEGIN
        IF (rising_edge(clock_25)) THEN
            IF (sw = '0') THEN

                pix_bus <= rom_out_data;
            ELSE
                pix_bus <= ram_out_data;
            END IF;
        END IF;
    END PROCESS;

    ram_address_process : PROCESS (filter_comp, ram_driver_during_comp, ram_driver_during_disp)
    BEGIN
        IF (filter_comp = '1') THEN
            ram_address <= ram_driver_during_comp;
        ELSE
            ram_address <= ram_driver_during_disp;
        END IF;
    END PROCESS;
    rom_address_process : PROCESS (filter_comp, rom_driver_during_comp, rom_driver_during_disp)
    BEGIN
        IF (filter_comp = '1') THEN
            rom_address <= rom_driver_during_comp;
        ELSE
            rom_address <= rom_driver_during_disp;
        END IF;
    END PROCESS;

    vga_display_address_drivers : PROCESS (clock_25)
    BEGIN
        IF (rising_edge(clock_25)) THEN
            IF (filter_comp = '0') THEN
                l1 <= '1';
                ram_driver_during_disp <= STD_LOGIC_VECTOR(to_unsigned((64 * (vcounter - 200) + hcounter - 198), 12));
                rom_driver_during_disp <= STD_LOGIC_VECTOR(to_unsigned((64 * (vcounter - 200) + hcounter - 198), 12));
            END IF;
        END IF;
    END PROCESS;
    FSM_process_seq_combined : PROCESS (clock_25)

    BEGIN
        IF (rising_edge(clock_25)) THEN
            IF (filter_comp = '1') THEN
                CASE Cur_state IS
                        --                if(cur_state = Position_Update ) then
                    WHEN Position_Update =>
                        ram_write_enable <= "1";

                        mac_control <= '1';
                        mac_input1 <= "00000000";
                        mac_input2 <= "00000000";

                        temp_ram_address <= STD_LOGIC_VECTOR(to_unsigned((64 * y + x), 12));
                        ker_addr <= STD_LOGIC_VECTOR(to_unsigned(ker_pos, 4));

                        IF (ker_pos < 3) THEN
                            rom_driver_during_comp <= STD_LOGIC_VECTOR(to_unsigned((64 * y + x - 65 + ker_pos), 12));
                            IF (y = 0) THEN
                                valid_rom_data <= '0';
                            ELSIF (x = 0 AND ker_pos = 0) THEN
                                valid_rom_data <= '0';
                            ELSIF (x = 63 AND ker_pos = 2) THEN
                                valid_rom_data <= '0';
                            ELSE
                                valid_rom_data <= '1';
                            END IF;
                        ELSIF (ker_pos < 6) THEN
                            rom_driver_during_comp <= STD_LOGIC_VECTOR(to_unsigned((64 * y + x - 4 + ker_pos), 12));
                            IF (x = 0 AND ker_pos = 3) THEN
                                valid_rom_data <= '0';
                            ELSIF (x = 63 AND ker_pos = 5) THEN
                                valid_rom_data <= '0';
                            ELSE
                                valid_rom_data <= '1';
                            END IF;
                        ELSIF (ker_pos < 9) THEN
                            IF (y = 63) THEN
                                valid_rom_data <= '0';
                            ELSIF (x = 0 AND ker_pos = 6) THEN
                                valid_rom_data <= '0';
                            ELSIF (x = 63 AND ker_pos = 8) THEN
                                valid_rom_data <= '0';
                            ELSE
                                valid_rom_data <= '1';
                            END IF;
                            rom_driver_during_comp <= STD_LOGIC_VECTOR(to_unsigned((64 * y + x + 57 + ker_pos), 12));
                        END IF;

                        cur_state <= Accumulate;

                        --                elsif(cur_state <= Accumulate ) then
                    WHEN Accumulate =>
                        ram_driver_during_comp <= temp_ram_address;

                        mac_control <= '1';
                        IF (valid_rom_data = '1') THEN
                            mac_input1 <= rom_out_data;
                        ELSE
                            mac_input1 <= "00000000";
                        END IF;
                        mac_input2 <= kerdata;

                        IF (ker_pos = 8) THEN
                            cur_state <= RAM_write;
                        ELSE

                            cur_state <= Position_Update;
                            ker_pos <= ker_pos + 1;
                        END IF;

                        --                elsif ( cur_state  =  RAM_write ) then
                    WHEN RAM_write =>

                        IF (filter_comp_substate_max_min = '1') THEN

                            IF (mac_output < infimum) THEN
                                infimum <= mac_output;
                            END IF;
                            IF (mac_output > supremum) THEN
                                supremum <= mac_output;
                            END IF;
                        ELSE
                            ram_in_data <= STD_LOGIC_VECTOR(to_unsigned(255 * (mac_output - infimum)/(supremum - infimum), 8));
                        END IF;
                        cur_state <= Next_Address;

                        mac_control <= '0';
                        ker_pos <= 0;

                        --                elsif( cur_state <= Next_Address ) then
                    WHEN Next_Address =>
                        mac_control <= '1';
                        x <= x + 1;
                        IF (x = 63) THEN
                            IF (y = 63) THEN
                                IF (filter_comp_substate_max_min = '1') THEN
                                    filter_comp_substate_max_min <= '0';
                                    x <= 0;
                                    y <= 0;
                                    ker_pos <= 0;
                                    mac_control <= '1';
                                    cur_state <= Position_Update;

                                ELSE
                                    ram_write_enable <= "0";
                                    filter_comp <= '0';
                                    enable <= '0';

                                END IF;
                            END IF;
                            IF (NOT(y = 63)) THEN
                                y <= y + 1;
                            END IF;
                            x <= 0;
                        END IF;

                        cur_state <= Position_Update;
                END CASE;
            END IF;

        END IF;
    END PROCESS;

END MACHINE;