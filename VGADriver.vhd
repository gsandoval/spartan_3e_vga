----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Guillermo Alberto Sandoval Sanchez
-- 
-- Create Date:    10:12:28 05/26/2012 
-- Design Name: 
-- Module Name:    VGADriver - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

-- Información del timing de la señal VGA con distintas resoluciones y relojes
-- http://www.epanorama.net/documents/pc/vga_timing.html

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGADriver is
port(
	reset : in std_logic;
	clock : in std_logic;
	hsync : out std_logic;
	vsync : out std_logic;
	hpos : out std_logic_vector(10 downto 0);
	vpos : out std_logic_vector(10 downto 0);
	blank : out std_logic
);
end VGADriver;

architecture Behavioral of VGADriver is

	constant HMAX : std_logic_vector(10 downto 0) := "10000010000"; -- 1040
	constant HDISP : std_logic_vector(10 downto 0) := "01100100000"; --  800
	constant HFP : std_logic_vector(10 downto 0) := "01101011000"; --  856
	constant HS : std_logic_vector(10 downto 0) := "01111010000"; --  976
	constant VMAX : std_logic_vector(10 downto 0) := "01010011010"; --  666
	constant VDISP : std_logic_vector(10 downto 0) := "01001011000"; --  600
	constant VFP : std_logic_vector(10 downto 0) := "01001111101"; --  637
	constant VS : std_logic_vector(10 downto 0) := "01010000011"; --  643
	constant SYNC_SIGNAL : std_logic := '0';

	signal hcounter : std_logic_vector(10 downto 0) := (others => '0');
	signal vcounter : std_logic_vector(10 downto 0) := (others => '0');
	signal video_enable : std_logic;

begin

   hpos <= hcounter;
   vpos <= vcounter;
	
	blank_signal : process(clock, hcounter, vcounter)
	begin
		if (rising_edge(clock)) then
			if (hcounter < HDISP and vcounter < VDISP) then
				blank <= '0';
			else
				blank <= '1';
			end if;
		end if;
	end process;

   horizontal_count : process(clock, reset)
   begin
      if (rising_edge(clock)) then
         if (reset = '1') then
            hcounter <= (others => '0');
         else
				if (hcounter = HMAX) then
					hcounter <= (others => '0');
				else
					hcounter <= hcounter + 1;
				end if;
         end if;
      end if;
   end process;

   vertical_count : process(clock, reset, hcounter)
   begin
      if (rising_edge(clock)) then
         if (reset = '1') then
            vcounter <= (others => '0');
         elsif (hcounter = HMAX) then
            if(vcounter = VMAX) then
               vcounter <= (others => '0');
            else
               vcounter <= vcounter + 1;
            end if;
         end if;
      end if;
   end process;

   horizontal_sync : process(clock, hcounter)
   begin
      if (rising_edge(clock)) then
         if (hcounter >= HFP and hcounter < HS) then
            hsync <= SYNC_SIGNAL;
         else
            hsync <= not SYNC_SIGNAL;
         end if;
      end if;
   end process;

   vertical_sync : process(clock, vcounter)
   begin
      if (rising_edge(clock)) then
         if (vcounter >= VFP and vcounter < VS) then
            vsync <= SYNC_SIGNAL;
         else
            vsync <= not SYNC_SIGNAL;
         end if;
      end if;
   end process;

end Behavioral;