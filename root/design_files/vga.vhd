library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity vga is

    Port(clk25hz: in STD_LOGIC;

         pixel_value: in STD_LOGIC_VECTOR(7 downto 0);

         RST: in STD_LOGIC;

         HSYNC: out STD_LOGIC;

         VSYNC: out STD_LOGIC;

         R : out std_logic_vector(3 downto 0);
         G : out std_logic_vector(3 downto 0);
         B : out std_logic_vector(3 downto 0);



         hcter: out integer;

         vcter: out integer);

end vga;

-- THE DISPLAY SPECIFICATIONS ACCORDING TO THE ASSIGNMENT

architecture Behavioral of vga is



    signal hct: integer := 0;

    signal vct: integer := 0;





    signal Ready_to_disp: std_logic:= '0';



begin



    -- n summary, this VHDL code represents a process that acts as a horizontal counter for a video or timing application. It resets the counter to zero when a reset condition (RST) is asserted, and it increments the counter on each rising edge of a clock signal (clk25hz). When the counter reaches a specific value, it wraps around to zero. The current count value is stored in hcter.


    DISPLAY_CONTROLLER_LOGIC_PROCESS:process(clk25hz,hct,vct,Ready_to_disp,RST)

    begin

        if(RST='1')then

        elsif(rising_edge(clk25hz))then
            if((vct >= 200 and vct < 264) and Ready_to_disp ='1' and (hct >= 200 and hct < 264) )then

                --    

                R <= pixel_value(7 DOWNTO 4);
                G <= pixel_value(7 DOWNTO 4);
                B <= pixel_value(7 DOWNTO 4);

            elsif(Ready_to_disp = '1' ) then

                R <= "0000";
                G <= "0000";
                B <= "0000";
                --           
            end if;

        end if;




    end process;

    CHECK_VIDEO_ON_PROCESS:process(clk25hz,RST,hct,vct)

    begin

        if(RST='1')then -- if reset, then the counter value should become zero

            Ready_to_disp <='0';

        elsif(rising_edge(clk25hz))then

            if(hct <=639 and vct<=479)then

                Ready_to_disp <='1';

            else

                Ready_to_disp <='0';

            end if;

        end if;

    end process;



    -- THE PIXEL VALUES ARE FED ONLY DURING THE ACTIVE REGION


    HORIZONTAL_COUNTER_PROCESS: process(clk25hz,RST)

    begin

        if(RST='1')then

            hct<=0;

        elsif(rising_edge(clk25hz))then

            if(hct = 799)then

                hct<=0;

            else

                hct<=hct+1;

            end if;

        end if;

        hcter <= hct;

    end process;



    VERTICAL_COUNTER_PROCESS: process(clk25hz,RST,hct)

    begin

        if(RST='1')then

            vct<=0;

        elsif(rising_edge(clk25hz))then -- after one horizontal line gets completed, go to the next line

            if(hct = 799) then

                if(vct = 524)then

                    vct<=0;

                else

                    vct<=vct+1;

                end if;

            end if;

        end if;

        vcter <= vct;

    end process;



    HSYNC_PROCESS:process(clk25hz,RST,hct)

    begin

        if(RST='1')then

            HSYNC<='0';

        elsif(rising_edge(clk25hz))then

            if(hct <=655 OR (hct > 751))then

                HSYNC <='1';

            else

                HSYNC<='0';

            end if;

        end if;

    end process;



    VSYNC_PROCESS:process(clk25hz,RST,vct)

    begin

        if(RST='1')then  -- if reset, then the counter value should become zero

            VSYNC <='0';

        elsif(rising_edge(clk25hz))then

            if(vct <=489 OR (vct > 491))then

                VSYNC <='1';

            else

                VSYNC<='0';

            end if;

        end if;

    end process;







end Behavioral;