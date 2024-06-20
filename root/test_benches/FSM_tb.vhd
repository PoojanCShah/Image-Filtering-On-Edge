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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ComputeUnit is
    port(

--        l1: out std_logic;
--        --     hPo: out integer;
--        --      vPo: out integer;
--        rclk: in STD_LOGIC;
--        sw : in std_logic ;
        pixel_value: in STD_LOGIC_VECTOR(7 downto 0);
        RST: in STD_LOGIC;
        HSYNC: out STD_LOGIC;
        VSYNC: out STD_LOGIC;
        R0: out STD_LOGIC;
        R1: out STD_LOGIC;
        R2: out STD_LOGIC;
        R3: out STD_LOGIC;
        B0: out STD_LOGIC;
        B1: out STD_LOGIC;
        B2: out STD_LOGIC;
        B3: out STD_LOGIC;
        G0: out STD_LOGIC;
        G1: out STD_LOGIC;
        G2: out STD_LOGIC;
        G3: out STD_LOGIC
    );
end ComputeUnit;



architecture MACHINE of ComputeUnit is

    component blk_mem_gen_0
        port(
            addra : in std_logic_vector(11 downto 0);
            douta : out std_logic_vector(7 downto 0);
            clka : in std_logic
        );
    end component;

    component blk_mem_gen_1
        port(
            addra : in std_logic_vector(3 downto 0);
            douta : out std_logic_vector(7 downto 0);
            clka : in std_logic
        );
    end component;

    component blk_mem_gen_2
        port(
            addra : in std_logic_vector(11 downto 0);
            douta : out std_logic_vector(7 downto 0);
            clka : in std_logic;
            wea : in std_logic_vector ( 0 downto 0);
            dina : in std_logic_vector(7 downto 0)
        );
    end component;

    component MAC
        Port (
            clk : IN STD_LOGIC;
            cntrl : IN STD_LOGIC;
            input_1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            input_2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            --        output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
            output : out integer
        );
    end component;

    component vga
        port(
            hcter: out integer;
            vcter: out integer;
            clk25hz: in STD_LOGIC;
            pixel_value: in STD_LOGIC_VECTOR(7 downto 0);
            RST: in STD_LOGIC;

            HSYNC: out STD_LOGIC;
            VSYNC: out STD_LOGIC;
           R : OUT std_logic_vector(3 DOWNTO 0);
              G : OUT std_logic_vector(3 DOWNTO 0);
                 B : OUT std_logic_vector(3 DOWNTO 0)

        );
    end component;

    -- states
    type sub_state_type is (Position_Update, Accumulate , RAM_write , Next_Address ) ;
    signal cur_state : sub_state_type  := Position_Update  ;
    signal filter_comp : std_logic := '1' ;
    signal filter_comp_substate_max_min : std_logic := '1' ;
    -- end states


    --signals in this gaurd


    signal enable : std_logic := '1';
    signal pix_bus : std_logic_vector(7 downto 0) ;
    signal hcounter : integer :=0;
    signal vcounter : integer := 0;
    signal sw : std_logic := '0';
    constant clk_period : time := 10ns;
    signal rclk : std_logic := '1';
signal l1 : std_logic := '1';
    signal clock_25 : std_logic := '1';
    signal flag2 : integer := 0;

    signal rom_address : std_logic_vector(11 downto 0) := (others => '0');
    signal rom_out_data : std_logic_vector(7 downto 0 ):= (others => '0');

    signal ker_addr : std_logic_vector(3 downto 0 ):= (others => '0');
    signal kerdata : std_logic_vector(7 downto 0 ) := (others => '0');

    signal ram_out_data : std_logic_vector(7 downto 0):= (others => '0');
    signal ram_address  : std_logic_vector(11 downto 0):= (others => '0');
    signal ram_in_data : std_logic_vector( 7 downto 0 ):= (others => '0');
    signal ram_write_enable : std_logic_vector( 0 downto 0 ) := (others => '1') ;

    signal mac_control : std_logic := '1';
    signal mac_input1 : std_logic_vector (7 downto 0 ) := (others => '0');
    signal mac_input2 : std_logic_vector (7 downto 0 ) := (others => '0');
    signal mac_output : integer := 0;

    signal x : integer := 0;
    signal y : integer := 0;
    signal ker_pos : integer := 0;
    signal mac_done : std_logic := '1';

    signal infimum : integer := 9999   ;
    signal supremum : integer := -9999 ;
    signal temp_ram_address : std_logic_vector(11 downto 0 ) := (others => '0') ;
    signal valid_rom_data : std_logic := '1' ;

    signal rom_driver_during_comp : std_logic_vector(11 downto 0) := (others => '0' ) ;
    signal rom_driver_during_disp : std_logic_vector(11 downto 0) := (others => '0' ) ;
    signal ram_driver_during_comp : std_logic_vector(11 downto 0) := (others => '0' ) ;
    signal ram_driver_during_disp : std_logic_vector(11 downto 0) := (others => '0' ) ;

    --end signal gaurd

begin

    -- port mapping in this gaurd

    ROMmap : blk_mem_gen_0
        Port map(
            clka => rclk,
            douta => rom_out_data,
            addra => rom_address
        );

    KernalMap : blk_mem_gen_1
        Port map(
            clka => rclk,
            douta => kerdata,
            addra => ker_addr
        );

    RAMmap : blk_mem_gen_2
        Port map(
            clka => rclk,
            douta => ram_out_data,
            dina => ram_in_data ,
            wea => ram_write_enable,
            addra => ram_address
        );


    MAC_map : MAC
        Port Map(
            input_1 => mac_input1 ,
            input_2 => mac_input2,
            clk => clock_25,
            output => mac_output,
            cntrl => mac_control
        );

    uut: vga
        port map(
            hcter => hcounter,
            vcter => vcounter,
            clk25hz => clock_25,
            pixel_value => pix_bus  ,
            RST => enable ,

            HSYNC => HSYNC ,
            VSYNC => VSYNC,
            R(0) => R0,
            R(1) => R1,
            R(2) =>R2,
            R(3)  =>R3,
            B(0)  =>B0,
            B(1) =>B1,
            B(2) =>B2,
            B(3) =>B3,
            G(0) =>G0,
            G(1) =>G1,
            G(2) =>G2,
            G(3) =>G3
        );


    --  end mapping gaurd


    clk_proc : process(rclk)
    begin
        if(rising_edge (rclk)) then
            if(flag2 = 0) then
                clock_25  <= '1';
                flag2 <= flag2 +1;
            elsif (flag2 = 2) then
                clock_25 <= '0';
                flag2 <= -1;
            else
                flag2 <= flag2 + 1;
            end if;
        end if;
    end process;

    c_proc: process
    begin
    rclk <= '1';
    wait for clk_period/2 ;
    rclk <='0';
    wait for clk_period/2;
    end process;





    process_to_choose_which_image :process(sw,clock_25)
    begin
        if(rising_edge(clock_25)) then
            if(sw = '0') then

                pix_bus <= rom_out_data;
            else
                pix_bus <= ram_out_data ;
            end if;
        end if;
    end process ;



    ram_address_process : process(filter_comp,ram_driver_during_comp, ram_driver_during_disp)
    begin
        if(filter_comp = '1' ) then
            ram_address <= ram_driver_during_comp ;
        else
            ram_address <= ram_driver_during_disp ;
        end if;
    end process ;


    rom_address_process : process(filter_comp,rom_driver_during_comp, rom_driver_during_disp)
    begin
        if(filter_comp = '1' ) then
            rom_address <= rom_driver_during_comp ;
        else
            rom_address <= rom_driver_during_disp ;
        end if;
    end process ;



    vga_display_address_drivers : process(clock_25)
    begin
        if(rising_edge(clock_25)) then
            if(filter_comp = '0' ) then
                l1 <= '1' ;
                ram_driver_during_disp  <= std_logic_vector(to_unsigned((64*(vcounter-200) + hcounter - 198),12)) ;
                rom_driver_during_disp  <= std_logic_vector(to_unsigned((64*(vcounter-200) + hcounter - 198),12)) ;
            end if ;
        end if;
    end process ;




    FSM_process_seq_combined  : process(clock_25)

    begin
        if(rising_edge(clock_25)) then
            if(filter_comp = '1') then
            CASE Cur_state is
--                if(cur_state = Position_Update ) then
                  when Position_Update =>
                    ram_write_enable <= "1";

                    mac_control <= '1';
                    mac_input1 <= "00000000";
                    mac_input2 <= "00000000";

                    temp_ram_address <= std_logic_vector(to_unsigned((64*y +x),12));
                    ker_addr <= std_logic_vector(to_unsigned(ker_pos,4));

                    if(ker_pos < 3) then
                        rom_driver_during_comp <= std_logic_vector(to_unsigned((64*y +x-65+ker_pos),12));
                        if(y = 0 ) then
                            valid_rom_data  <= '0' ;
                        elsif ( x = 0 and ker_pos = 0 ) then
                            valid_rom_data <= '0' ;
                        elsif ( x = 63 and ker_pos = 2 ) then
                            valid_rom_data  <= '0';
                        else
                            valid_rom_data <= '1' ;
                        end if;
                    elsif (ker_pos < 6 ) then
                        rom_driver_during_comp <= std_logic_vector(to_unsigned((64*y +x - 4 + ker_pos),12));
                        if( x= 0 and ker_pos = 3 ) then
                            valid_rom_data  <= '0';
                        elsif(x=63 and ker_pos = 5 ) then
                            valid_rom_data  <= '0';
                        else
                            valid_rom_data <= '1' ;
                        end if;
                    elsif ( ker_pos < 9 ) then
                        if(y = 63 ) then
                            valid_rom_data  <= '0' ;
                        elsif ( x = 0 and ker_pos = 6 ) then
                            valid_rom_data <= '0' ;
                        elsif ( x = 63 and ker_pos = 8 ) then
                            valid_rom_data  <= '0';
                        else
                            valid_rom_data <= '1' ;
                        end if;
                        rom_driver_during_comp <= std_logic_vector(to_unsigned((64*y +x+ 57 + ker_pos ),12));
                    end if;

                    cur_state  <= Accumulate  ;

--                elsif(cur_state <= Accumulate ) then
                    when Accumulate =>


                    ram_driver_during_comp <= temp_ram_address;

                    mac_control <= '1' ;
                    if(valid_rom_data  = '1') then
                        mac_input1 <= rom_out_data  ;
                    else
                        mac_input1  <= "00000000";
                    end if;
                    mac_input2 <= kerdata ;

                    if(ker_pos = 8) then
                        cur_state <= RAM_write ;
                    else

                        cur_state  <= Position_Update  ;
                        ker_pos <= ker_pos +1 ;
                    end if;

--                elsif ( cur_state  =  RAM_write ) then
                    when RAM_write =>

                    if(filter_comp_substate_max_min = '1' ) then

                        if(mac_output < infimum ) then
                            infimum <= mac_output;
                        end if;
                        if(mac_output > supremum ) then
                            supremum <= mac_output  ;
                        end if;
                    else
                        ram_in_data  <= std_logic_vector(to_unsigned(255*(mac_output -infimum )/(supremum -infimum ),8));
                    end if;
                    cur_state  <= Next_Address  ;

                    mac_control <= '0' ;
                    ker_pos <= 0 ;

--                elsif( cur_state <= Next_Address ) then
                    when Next_Address =>
                    mac_control <= '1' ;


                    x <= x + 1 ;
                    if( x = 63 ) then
                        if(y = 63 ) then
                            if(filter_comp_substate_max_min = '1') then
                                filter_comp_substate_max_min <= '0' ;
                                x <= 0 ;
                                y<= 0 ;
                                ker_pos <= 0 ;
                                mac_control <= '1' ;
                                cur_state  <= Position_Update ;

                            else
                                ram_write_enable  <= "0" ;
                                filter_comp <= '0' ;
                                enable <= '0' ;

                            end if;


                        end if;
                        if(not(y=63)) then
                            y <= y +1 ;
                        end if;
                        x <= 0 ;
                    end if ;

                    cur_state <= Position_Update  ;


                end case;


            end if;

        end if;




    end process ;







end MACHINE;