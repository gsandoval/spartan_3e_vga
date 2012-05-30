----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Guillermo Alberto Sandoval Sanchez
-- 
-- Create Date:    23:31:24 05/29/2012 
-- Design Name: 
-- Module Name:    Main - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: VGADriver
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Main is
port(
	reset : in std_logic;
	mclock : in std_logic;
	hsync : out std_logic;
	vsync : out std_logic;
	rgb : out std_logic_vector(2 downto 0);
	mode : in std_logic_vector(2 downto 0);
	player1up : in std_logic;
	player1down : in std_logic;
	player2up : in std_logic;
	player2down : in std_logic
);
end Main;

architecture Behavioral of Main is

	component VGADriver is
	port(
		reset : in std_logic;
		clock : in std_logic;
		hsync : out std_logic;
		vsync : out std_logic;
		hpos : out std_logic_vector(10 downto 0);
		vpos : out std_logic_vector(10 downto 0);
		blank : out std_logic
	);
	end component;
	
	signal hpos : std_logic_vector(10 downto 0);
	signal vpos : std_logic_vector(10 downto 0);
	signal blank : std_logic;
	
	signal animation_clock : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal xballpos : unsigned(10 downto 0) := "00110010000"; -- 400
	signal yballpos : unsigned(10 downto 0) := "00100101100"; -- 300
	signal ballsize : unsigned(5 downto 0) := "001010"; -- 10
	signal xincrement : integer := 1;
	signal yincrement : integer := 1;
	signal palette_width : unsigned(5 downto 0) := "001010"; -- 10
	signal palette_height : unsigned(6 downto 0) := "1111000"; -- 120
	signal palette1_ypos : unsigned(10 downto 0) := "00011110000"; -- 240
	signal palette2_ypos : unsigned(10 downto 0) := "00011110000"; -- 240
	signal palette1_xpos : unsigned(10 downto 0) := "00000001010"; -- 10
	signal palette2_xpos : unsigned(10 downto 0) := "01100001100"; -- 780
	signal palette1_increment : integer := 0;
	signal palette2_increment : integer := 0;
	signal xball_limit, yball_limit : unsigned(10 downto 0);
	signal xpalette1_limit, ypalette1_limit : unsigned(10 downto 0);
	signal xpalette2_limit, ypalette2_limit : unsigned(10 downto 0);
	
begin

	anim_clock : process(mclock)
	begin
		if (rising_edge(mclock)) then
			animation_clock <= animation_clock + '1';
		end if;
	end process;
	
	vgadriver_instance : VGADriver
	port map (
		reset => reset,
		clock => mclock,
		hsync => hsync,
		vsync => vsync,
		hpos => hpos,
		vpos => vpos,
		blank => blank
	);
	
	xball_limit <= xballpos + ballsize;
	yball_limit <= yballpos + ballsize;
	palette1_ypos <= palette1_ypos + palette1_increment when rising_edge(animation_clock(16)) else palette1_ypos;
	palette2_ypos <= palette2_ypos + palette2_increment when rising_edge(animation_clock(16)) else palette2_ypos;
	xpalette1_limit <= palette1_xpos + palette_width;
	ypalette1_limit <= palette1_ypos + palette_height;
	xpalette2_limit <= palette2_xpos + palette_width;
	ypalette2_limit <= palette2_ypos + palette_height;
	
	xball_movement : process(animation_clock(17), xincrement)
	begin
		if (rising_edge(animation_clock(17))) then
			xballpos <= xballpos + xincrement;
			if (mode = "100") then
				if (xballpos <= 0) then
					xballpos <= "00110010000"; -- 400
				end if;
			elsif (mode = "101") then
				if (xballpos <= 0 or xball_limit >= 800) then
					xballpos <= "00110010000"; -- 400
				end if;
			end if;
		end if;
	end process;
	
	yball_movement : process(animation_clock(17), yincrement)
	begin
		if (rising_edge(animation_clock(17))) then
			yballpos <= yballpos + yincrement;
		end if;
	end process;
	
	move_ball : process(animation_clock(17), xballpos, yballpos)
	begin
		if (rising_edge(animation_clock(17))) then
			if (mode = "100" or mode = "101") then
				if (xballpos <= xpalette1_limit and xballpos > palette1_xpos and
					yballpos <= ypalette1_limit and yball_limit >= palette1_ypos) then
					xincrement <= 1;
				elsif (xball_limit >= palette1_xpos and xball_limit < xpalette1_limit and
					yballpos <= ypalette1_limit and yball_limit >= palette1_ypos) then
					xincrement <= -1;
				elsif (yballpos <= ypalette1_limit and xballpos <= xpalette1_limit and xball_limit >= palette1_xpos) then
					yincrement <= 1;
				elsif (yball_limit >= palette1_ypos and xballpos <= xpalette1_limit and xball_limit >= palette1_xpos) then
					yincrement <= -1;
				end if;
			end if;
			
			if (mode = "101") then
				if (xballpos <= xpalette2_limit and xballpos > palette2_xpos and
					yballpos <= ypalette2_limit and yball_limit >= palette2_ypos) then
					xincrement <= 1;
				elsif (xball_limit >= palette2_xpos and xball_limit < xpalette2_limit and
					yballpos <= ypalette2_limit and yball_limit >= palette2_ypos) then
					xincrement <= -1;
				elsif (yballpos <= ypalette2_limit and xballpos <= xpalette2_limit and xball_limit >= palette2_xpos) then
					yincrement <= 1;
				elsif (yball_limit >= palette2_ypos and xballpos <= xpalette2_limit and xball_limit >= palette2_xpos) then
					yincrement <= -1;
				end if;
			end if;
			
			if (xballpos <= 0) then
				xincrement <= 1;
			elsif (xball_limit >= 800) then
				xincrement <= -1;
			end if;
			
			if (yballpos <= 0) then
				yincrement <= 1;
			elsif (yball_limit >= 600) then
				yincrement <= -1;
			end if;
		end if;
	end process;
	
	move_palette1 : process(animation_clock(16), player1up, player1down)
	begin
		if (rising_edge(animation_clock(16)) and (mode = "100" or mode = "101")) then
			if (player1up = '1' and player1down = '0') then
				if (palette1_ypos > 10) then
					palette1_increment <= -1;
				else
					palette1_increment <= 0;
				end if;
			elsif (player1up = '0' and player1down = '1') then
				if (ypalette1_limit < 590) then
					palette1_increment <= 1;
				else
					palette1_increment <= 0;
				end if;
			else
				palette1_increment <= 0;
			end if;
		end if;
	end process;
	
	move_palette2 : process(animation_clock(16), player2up, player2down)
	begin
		if (rising_edge(animation_clock(16)) and mode = "101") then
			if (player2up = '1' and player2down = '0') then
				if (palette2_ypos > 10) then
					palette2_increment <= -1;
				else
					palette2_increment <= 0;
				end if;
			elsif (player2up = '0' and player2down = '1') then
				if (ypalette2_limit < 590) then
					palette2_increment <= 1;
				else
					palette2_increment <= 0;
				end if;
			else
				palette2_increment <= 0;
			end if;
		end if;
	end process;
	
	paint : process(hpos, vpos, blank, mode)
		variable res : integer range 0 to 7 := 0;
		variable local_copy : signed(10 downto 0);
		variable xpos, ypos : unsigned(10 downto 0);
	begin
		if (blank = '0') then
			if (mode = "001") then -- Color palette
				local_copy := signed(hpos);
				for i in 0 to 7 loop
					local_copy := local_copy - 100;
					res := i;
					exit when local_copy <= 0;
				end loop;
				rgb <= std_logic_vector(to_unsigned(res, 3));
			elsif (mode = "010") then -- Moving ball
				xpos := unsigned(hpos);
				ypos := unsigned(vpos);
				if (xpos >= xballpos and xpos < xball_limit and ypos >= yballpos and ypos < yball_limit) then
					rgb <= "111";
				else
					rgb <= "100";
				end if;				
			elsif (mode = "100") then -- Moving ball and palette
				xpos := unsigned(hpos);
				ypos := unsigned(vpos);
				if ((xpos >= xballpos and xpos < xball_limit and ypos >= yballpos and ypos < yball_limit) or 
					(xpos >= palette1_xpos and xpos < xpalette1_limit and ypos >= palette1_ypos and ypos < ypalette1_limit)) then
					rgb <= "111";
				else
					rgb <= "100";
				end if;
			elsif (mode = "101") then -- Moving ball and palettes
				xpos := unsigned(hpos);
				ypos := unsigned(vpos);
				if ((xpos >= xballpos and xpos < xball_limit and ypos >= yballpos and ypos < yball_limit) or 
					(xpos >= palette1_xpos and xpos < xpalette1_limit and ypos >= palette1_ypos and ypos < ypalette1_limit) or
					(xpos >= palette2_xpos and xpos < xpalette2_limit and ypos >= palette2_ypos and ypos < ypalette2_limit)) then
					rgb <= "111";
				else
					rgb <= "100";
				end if;
			else -- Blue screen
				rgb <= "100";
			end if;
		else
			rgb <= "000";
		end if;
	end process;
	
end Behavioral;

