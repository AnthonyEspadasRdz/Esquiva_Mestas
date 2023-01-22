library ieee;
use ieee.std_logic_1164.all;

entity vga is
port( input_clk: in std_logic;
		pixel_clk: out std_logic;
		mov: in std_logic_vector(3 downto 0);
		reset_n: in std_logic;
	   h_sync, v_sync: out std_logic;
		--n_blank, n_sync: out std_logic;
	   puntos_3: out std_logic_vector(7 downto 0); -- Hex 3
	   puntos_2: out std_logic_vector(7 downto 0); -- Hex 2
	   puntos_1: out std_logic_vector(7 downto 0); -- Hex 1
	   puntos_0: out std_logic_vector(7 downto 0); -- Hex 0
	   red, green, blue: out std_logic_vector(3 downto 0));
end entity;

architecture arqvga of vga is

signal ccolumn, crow: integer;
signal pxl_clk: std_logic;
signal disp_ena: std_logic;
signal game_clk: std_logic;
signal bullet_clk: std_logic;
signal point_clk: std_logic;

begin

u1: entity work.Gen25(bhv) port map (input_clk, pxl_clk);
u2: entity work.reloj_juego port map (input_clk, game_clk, bullet_clk, point_clk);
u3: entity work.vga_controller(behavior) port map (pxl_clk, '1', h_sync, v_sync, disp_ena, ccolumn, crow);
u4: entity work.hw_image_generator(behavior) port map (point_clk, bullet_clk, game_clk, mov, disp_ena, reset_n, crow, ccolumn, puntos_3, puntos_2, puntos_1, puntos_0, red, green, blue);

end architecture;

