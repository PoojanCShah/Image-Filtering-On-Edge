----------------------------------------------------------------------------------
-- Company:
-- Engineer:
-- 
-- Create Date: 10/10/2023 03:06:05 PM
-- Design Name:
-- Module Name: VGATEST - Behavioral
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



entity FASTFILTER is

    port(
    sw : in std_logic ;
    l1: out std_logic;
--     hPo: out integer;
--      vPo: out integer;
    rclk: in STD_LOGIC;

--    pixel_value: in STD_LOGIC_VECTOR(7 downto 0);
--        RST: in STD_LOGIC;
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
end FASTFILTER;




architecture Behavioral of FASTFILTER is

signal flag : integer := 0;

--constant clk_period : time := 10ns;
--signal rclk : std_logic :='1';
--signal sw : std_logic := '1';
signal clock_25 : std_logic := '1';
signal enable : std_logic := '1';
signal pix_bus : std_logic_vector(7 downto 0) ;
signal rom_address : std_logic_vector(11 downto 0) := (others => '0');
signal rom_out_data : std_logic_vector(7 downto 0) := (others => '0');
signal i : integer := 0;
signal hcounter : integer :=0;
signal vcounter : integer := 0;
signal ram_address: std_logic_vector(11 downto 0) := (others => '0');
signal data_to_feed_ram: std_logic_vector(7 downto 0) := (others => '0');
signal ram_out_data : std_logic_vector(7 downto 0) := (others => '0');
signal write_enable : std_logic := '1';

signal flag2 :integer :=0;
signal flag3 : integer := 0;
signal ram_driver_during_comp : std_logic_vector(11 downto 0) := (others => '0');
signal ram_driver_during_disp : std_logic_vector(11 downto 0) := (others => '0');

signal cur : std_logic_vector (7 downto 0);
signal prv :  std_logic_vector( 7 downto 0 );
signal nxt : std_logic_vector(7 downto 0 );

signal cur1 : std_logic_vector (7 downto 0);
signal prv1 :  std_logic_vector( 7 downto 0 );
signal nxt1 : std_logic_vector(7 downto 0 );

signal cur2 : std_logic_vector (7 downto 0);
signal prv2 :  std_logic_vector( 7 downto 0 );
signal nxt2 : std_logic_vector(7 downto 0 );



signal curval : integer := 0;
signal nxtval : integer := 0;
signal prvval : integer := 0;

signal curval1 : integer := 0;
signal nxtval1: integer := 0;
signal prvval1 : integer := 0;

signal curval2 : integer := 0;
signal nxtval2: integer := 0;
signal prvval2 : integer := 0;


signal control: std_logic := '0';
signal maxvalue: integer := -9999;
signal minvalue : integer := 9999;


signal kernal_addr : std_logic_vector(3 downto 0);
signal dataKernal : std_logic_vector(7 downto 0);


signal a11 : integer := 0;
signal a12 : integer := 0;
signal a13 : integer := 0;
signal a21 : integer := 0;
signal a22 : integer := 0;
signal a23 : integer := 0;
signal a31 : integer := 0;
signal a32 : integer := 0;
signal a33 : integer := 0;
signal flag4 : integer := 0 ;


signal dataval : integer :=0;
signal dataval_final : integer := 0;

signal rom_driver_during_comp : std_logic_vector(11 downto 0) := (others => '0');
signal rom_driver_during_disp : std_logic_vector(11 downto 0) := (others => '0');





component dist_mem_gen_2
port(
    a : in std_logic_vector(3 downto 0);
    spo : out std_logic_vector(7 downto 0)

);
end component ;
component vga
port(
 hcter: out integer;
      vcter: out integer;
clk25hz: in STD_LOGIC;
    pixel_value: in STD_LOGIC_VECTOR(7 downto 0);
        RST: in STD_LOGIC;

        HSYNC: out STD_LOGIC;
       VSYNC: out STD_LOGIC;
           R : out std_logic_vector(3 downto 0);
         G : out std_logic_vector(3 downto 0);
         B : out std_logic_vector(3 downto 0)



);
end component;

component dist_mem_gen_0
port(
        clk : in std_logic ;
      a : in std_logic_vector(11 downto 0);
      spo : out std_logic_vector(7 downto 0)
      );
end component;


component dist_mem_gen_1
port(
    a : in std_logic_vector(11 downto 0);
    d: in std_logic_vector(7 downto 0);
    we: in std_logic;
    clk: in std_logic;
    spo: out std_logic_vector(7 downto 0)
);
end component;

begin

--c_proc: process
--begin
--rclk <= '1';
--wait for clk_period/2 ;
--rclk <='0';
--wait for clk_period/2;
--end process;



clk_proc : process(rclk)
begin
if(rising_edge (rclk)) then
if(flag = 0) then
clock_25  <= '1';
flag <= flag +1;
elsif (flag = 2) then
clock_25 <= '0';
flag <= -1;
else
flag <= flag + 1;

end if;
end if;
end process;



kernalMAP : dist_mem_gen_2
port map(
a => kernal_addr ,
spo => dataKernal
);


ROMmap : dist_mem_gen_0
port map(
    clk => rclk ,
    a => rom_address,
    spo => rom_out_data
);

RAMmap : dist_mem_gen_1
port map(
    a => ram_address ,
    d => data_to_feed_ram ,
    clk => clock_25 ,
    spo => ram_out_data ,
    we => write_enable

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

process(sw,clock_25)
begin
    if(rising_edge(clock_25)) then
    if(sw = '0') then

        pix_bus <= rom_out_data;
    else
        pix_bus <= ram_out_data ;
    end if;
    end if;
end process ;


rom_add_proc: process(clock_25,sw)
begin
if(rising_edge (clock_25)) then

if(sw ='1') then
    rom_address <= rom_driver_during_comp;
else
    rom_address <= ram_driver_during_disp;
end if;
end if;
end process;




ram_add_proc: process(clock_25)
begin
if(rising_edge (clock_25)) then

if(write_enable ='1') then
    ram_address <= ram_driver_during_comp;
else
 ram_address <= ram_driver_during_disp;
end if;
end if;
end process;


computation_assgRamData_proc : process(clock_25,write_enable)
begin
    if(rising_edge(clock_25)) then
        if(i>0 and write_enable = '1') then
           data_to_feed_ram  <= std_logic_vector(to_unsigned(dataval_final,8));
        end if;
     end if ;
end process;



kernalcoeff_proc : process (clock_25)
begin
    if(rising_edge(clock_25)) then
        if(flag4 = 0) then
        kernal_addr <= std_logic_vector(to_unsigned(0,4));
           flag4 <= flag4 +1;
        elsif (flag4 = 1) then
        a11 <= to_integer(signed(dataKernal));
        flag4 <= flag4 +1;
         elsif (flag4 = 2) then
              kernal_addr <= std_logic_vector(to_unsigned(1,4));
        flag4 <= flag4 +1;
         elsif (flag4 = 3) then
                 a12 <= to_integer(signed(dataKernal));
        flag4 <= flag4 +1;
                   kernal_addr <= std_logic_vector(to_unsigned(2,4));
         elsif (flag4 = 4) then
                   a13 <= to_integer(signed(dataKernal));
        flag4 <= flag4 +1;
         elsif(flag4 = 5) then
        kernal_addr <= std_logic_vector(to_unsigned(3,4));
           flag4 <= flag4 +1;
        elsif (flag4 = 6) then
        a21 <= to_integer(signed(dataKernal));
        flag4 <= flag4 +1;
         elsif (flag4 = 7) then
              kernal_addr <= std_logic_vector(to_unsigned(4,4));
        flag4 <= flag4 +1;
         elsif (flag4 = 8) then
                 a22 <= to_integer(signed(dataKernal));
        flag4 <= flag4 +1;
                   kernal_addr <= std_logic_vector(to_unsigned(5,4));
         elsif (flag4 = 9) then
                   a23 <= to_integer(signed(dataKernal));
        flag4 <= flag4 +1;
        elsif(flag4 = 10) then
        kernal_addr <= std_logic_vector(to_unsigned(6,4));
           flag4 <= flag4 +1;
        elsif (flag4 = 11) then
        a31 <= to_integer(signed(dataKernal));
        flag4 <= flag4 +1;
         elsif (flag4 = 12) then
              kernal_addr <= std_logic_vector(to_unsigned(7,4));
        flag4 <= flag4 +1;
         elsif (flag4 = 13) then
                 a32 <= to_integer(signed(dataKernal));
        flag4 <= flag4 +1;
                   kernal_addr <= std_logic_vector(to_unsigned(8,4));
         elsif (flag4 = 14) then
                   a33 <= to_integer(signed(dataKernal));
            flag4 <= flag4 +1;
         elsif (flag4 = 15) then
         flag4<= flag4+1;
        end if;
    end if;
end process;






computation_bus_proc: process(clock_25)
begin
if(rising_edge(clock_25)) then
if(i<=3968 and flag4 = 16) then

        if(i = 0) then
--            if(rising_edge(clock_25)) then

            if(flag3 = 0) then
            rom_driver_during_comp  <= std_logic_vector(to_unsigned(0,12));
            flag3 <= flag3 +1 ;
            elsif ( flag3 = 1 ) then
            flag3 <= flag3 +1 ;
            elsif (flag3 = 2) then
            cur <= rom_out_data;
                flag3 <= flag3+ 1;
            elsif (flag3 = 3) then
            rom_driver_during_comp  <= std_logic_vector(to_unsigned(64,12));
                flag3 <= flag3+ 1;
            elsif (flag3 = 4) then
                flag3 <= flag3+ 1;
            elsif (flag3 = 5) then
            cur1 <= rom_out_data ;
                flag3 <= flag3+ 1;
             elsif (flag3 = 6) then
            rom_driver_during_comp  <= std_logic_vector(to_unsigned(128,12));
                flag3 <= flag3+ 1;
            elsif (flag3 = 7) then
                flag3 <= flag3+ 1;
            elsif (flag3 = 8) then
            cur2 <= rom_out_data ;
                flag3 <= flag3+ 1;
            else

            i <= i+1;
            flag3 <= 0;

            end if;

--            end if;
        else

--            if(rising_edge(clock_25)) then


            if(flag2 =0) then
            if(i<4096) then
            rom_driver_during_comp <= std_logic_vector(to_unsigned(i,12));
            end if;
                    flag2 <= flag2+1;
            elsif (flag2 =1) then
                    flag2 <= flag2+ 1;
            elsif ( flag2 = 2) then
            nxt <= rom_out_data;
                    flag2 <= flag2 +1;
            elsif (flag2 =3) then
            if((i+64) < 4096) then
            rom_driver_during_comp <= std_logic_vector(to_unsigned(i+64,12));
            end if;
                    flag2 <= flag2+1;
            elsif (flag2 =4) then
                    flag2 <= flag2+ 1;
            elsif ( flag2 = 5) then
            nxt1 <= rom_out_data;
                    flag2 <= flag2 +1;
            elsif (flag2 =6) then
            if((i+128) < 4096) then
            rom_driver_during_comp <= std_logic_vector(to_unsigned(i+128,12));
            end if;
                    flag2 <= flag2+1;
            elsif (flag2 =7) then
                    flag2 <= flag2+ 1;
            elsif ( flag2 = 8) then
            nxt2 <= rom_out_data;
                    flag2 <= flag2 +1;
            elsif ( flag2 = 9) then
                    flag2 <= flag2 +1;

--             elsif ( flag2 = 10) then

--                    flag2 <= flag2 +1;
--            elsif ( flag2 =11) then

--                    flag2 <= flag2 +1;
             elsif (flag2 = 10) then
             ram_driver_during_comp <= std_logic_vector(to_unsigned(i-1,12));

                 if((i-1) mod 64 = 0) then
                    curval <= to_integer(unsigned(cur));
                    nxtval <= to_integer(unsigned(nxt));
--                    data_to_feed_ram <= std_logic_vector(to_unsigned((nxtval -2*curval),8));
                    prv <= cur;
                    cur <= nxt;

                    curval1 <= to_integer(unsigned(cur1));
                    nxtval1 <= to_integer(unsigned(nxt1));
--                    data_to_feed_ram <= std_logic_vector(to_unsigned((nxtval -2*curval),8));
                    prv1 <= cur1;
                    cur1 <= nxt1;

                    curval2 <= to_integer(unsigned(cur2));
                    nxtval2 <= to_integer(unsigned(nxt2));
--                    data_to_feed_ram <= std_logic_vector(to_unsigned((nxtval -2*curval),8));
                    prv2 <= cur2;
                    cur2 <= nxt2;


                 elsif ((i-1) mod 64 = 63) then
                                     curval <= to_integer(unsigned(cur));
                    prvval <= to_integer(unsigned(prv));
--                    data_to_feed_ram <= std_logic_vector(to_unsigned((nxtval -2*curval),8));
                    prv <= cur;
                    cur <= nxt;

                    curval1 <= to_integer(unsigned(cur1));
                    prvval1 <= to_integer(unsigned(prv1));
--                    data_to_feed_ram <= std_logic_vector(to_unsigned((nxtval -2*curval),8));
                    prv1 <= cur1;
                    cur1 <= nxt1;

                    curval2 <= to_integer(unsigned(cur2));
                    prvval2 <= to_integer(unsigned(prv2));
--                    data_to_feed_ram <= std_logic_vector(to_unsigned((nxtval -2*curval),8));
                    prv2 <= cur2;
                    cur2 <= nxt2;


                 else
                    curval <= to_integer(unsigned(cur));
                    nxtval <= to_integer(unsigned(nxt));
                    prvval <= to_integer(unsigned(prv));
--                     data_to_feed_ram <= std_logic_vector(to_unsigned((nxtval + prvval -2*curval),8));
                         prv <= cur;
                         cur <= nxt;

                       curval1 <= to_integer(unsigned(cur1));
                    nxtval1 <= to_integer(unsigned(nxt1));
                    prvval1 <= to_integer(unsigned(prv1));
--                     data_to_feed_ram <= std_logic_vector(to_unsigned((nxtval + prvval -2*curval),8));
                         prv1 <= cur1;
                         cur1 <= nxt1;

                    curval2 <= to_integer(unsigned(cur2));
                    nxtval2 <= to_integer(unsigned(nxt2));
                    prvval2 <= to_integer(unsigned(prv2));
--                     data_to_feed_ram <= std_logic_vector(to_unsigned((nxtval + prvval -2*curval),8));
                         prv2 <= cur2;
                        cur2 <= nxt2;




                 end if;
                    flag2 <= flag2 + 1;

              elsif (flag2 = 11) then
                    flag2 <= flag2 + 1;
              elsif ( flag2 = 12) then

                    flag2 <= flag2 +1;
             elsif ( flag2 = 13) then

        if( i > 0 ) then
        if((i-1) mod 64 = 0) then
            dataval <= (a22*curval1 + a12*curval + a32*curval2 + a23*nxtval1 + a33*nxtval2 + a13*nxtval1) ;

        elsif ((i-1) mod 64 = 63 ) then
            dataval <= (a22*curval1 + a12*curval + a32*curval2 + a21*prvval1 + a31*prvval2 + a11*prvval1) ;

        else
            dataval <= (a22*curval1 + a12*curval + a32*curval2 + a23*nxtval1 + a33*nxtval2 + a13*nxtval1 + a21*prvval1 + a31*prvval2 + a11*prvval1) ;
        end if ;
    end if;


                 flag2 <= flag2 +1;
              elsif ( flag2 = 14) then

                 flag2 <= flag2 +1;
                 elsif ( flag2 = 15) then

                 flag2 <= flag2 +1;


            elsif ( flag2 = 16) then
             if(control =  '0') then

                if(minvalue  > dataval ) then
                minvalue <= dataval  ;
                end if ;
                if(maxvalue < dataval ) then
                maxvalue  <= dataval ;
                end if ;
             else
                dataval_final <= 255*(dataval - minvalue )/(maxvalue - minvalue);
             end if;


--                if(dataval <= 0 ) then
--                    dataval_final  <= 0;
--                elsif(dataval >= 255 ) then
--                dataval_final <= 255;
--             else
--                 dataval_final <= dataval;
--             end if;

                 flag2 <= flag2 +1;
             elsif ( flag2 = 17) then

                 flag2 <= flag2 +1;
                 elsif ( flag2 = 18) then

                 flag2 <= flag2 +1;

             else
--                   prv <= cur;
--               cur <= nxt;



                    flag2 <= 0;
                    i <= i+1;

                 end if;



             end if;

--        if(rising_edge(clock_25)) then
--        rom_address <= std_logic_vector(to_unsigned(i,16));
--        ram_driver_during_comp <= std_logic_vector(to_unsigned(i,16));
--        data_to_feed_ram <= not rom_out_data;
--        i <= i+1;
--        end if;

elsif(flag4 = 16) then
    if(control = '0') then
    control <= '1';

    i <= 0;
    else
    write_enable <='0';
    end if;

end if;
end if;

end process;




--(hcounter.vcounter sensitivity)

stim_proc : process(clock_25)
begin
   if(rising_edge(clock_25)) then
    if(i >= 3969) then
     if(write_enable = '0') then
--    if(rising_edge(clock_25)) then
        enable <= '0';
        l1 <= '1';
        ram_driver_during_disp <= std_logic_vector(to_unsigned((64*(vcounter-200)+hcounter-200+3),12));
        end if;

end if;
--end if;

end if;
end process;

--pixel_value <= pix_bus ;


end Behavioral;