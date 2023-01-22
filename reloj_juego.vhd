library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;

entity reloj_juego is port(
	Clk_50    : in std_logic;
	Clk_juego : buffer std_logic:= '0';
   Clk_balas : buffer std_logic:= '0';
   Clk_puntos: buffer std_logic:= '0');
end reloj_juego;

architecture bhv of reloj_juego is

signal contador_juego : integer range 0 to 350000;
signal contador_balas : integer range 0 to 250000;
signal contador_puntos: integer range 0 to 2500000;

begin
   
   process(contador_juego, Clk_juego) -- Genera un reloj para el movimiento del cuadro
   begin
      if rising_edge(Clk_50) then
         contador_juego <= contador_juego+1;
         if(contador_juego = 350000) then
            contador_juego <= 0;
            Clk_juego <= not(Clk_juego);
         end if;
      end if;
   end process;

   process(contador_balas, Clk_balas)  -- Genera un reloj para el movimiento de las balas
   begin
      if rising_edge(Clk_50) then
         contador_balas <= contador_balas+1;
         if(contador_balas = 250000) then
            contador_balas <= 0;
            Clk_balas <= not(Clk_balas);
         end if;
      end if;
   end process;

   process(contador_puntos, Clk_puntos)  -- Genera un reloj para el contador de puntos
   begin
      if rising_edge(Clk_50) then
         contador_puntos <= contador_puntos+1;
         if (contador_puntos = 2500000) then
            contador_puntos <= contador_puntos+1;
            Clk_puntos <= not(Clk_balas);
         end if;
      end if;
   end process;

end architecture;