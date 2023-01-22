LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.math_real.all;

ENTITY hw_image_generator IS
  GENERIC(
	 borde_inferior : INTEGER := 20;
	 borde_superior_row : INTEGER := 459;
	 borde_superior_column : INTEGER := 619;
    pixels_y :  INTEGER := 640;   --row that first color will persist until
    pixels_x :  INTEGER := 480);  --column that first color will persist until
  PORT(
	 point_clk:  in   std_logic; -- Controla el tiempo del contador
	 bullet_clk: in 	 std_logic; -- Controla el tiempo para las balas
	 game_clk :  in   std_logic;  -- Control de tiempo para el cuadrado
	 mov      :  in   std_logic_vector(3 downto 0); -- Vector con los valores de los switches
    disp_ena :  IN   STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    reset_n  :  in   std_logic;	-- Reinica el juego a la posicion de arranque
    row      :  IN   INTEGER;    --row pixel coordinate
    column   :  IN   INTEGER;    --column pixel coordinate
	 score_3	 :  buffer  std_logic_vector(7 downto 0);
	 score_2	 :  buffer  std_logic_vector(7 downto 0);
	 score_1	 :  buffer  std_logic_vector(7 downto 0); 
	 score_0  :  buffer  std_logic_vector(7 downto 0);
    red      :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS

signal inicio: std_logic := '1';					  -- Controla que se muestre la pantallad de inicio

signal x: integer range 19 to 459 := 215; 	  -- Controla posicion x del cuadrado
signal y: integer range 19 to 619 := 295; 	  -- Controla posicion y del cuadrado
signal game_over: std_logic := '0';		   	  -- Controla la pantalla que se muestra
signal balazo: std_logic := '0';					  -- Registra si el cuadrado choco con una bala

signal x_b3: integer range 19 to 459 := 19; 	  -- Controla posicion x de la bala izquierda
signal y_b3: integer range 0 to 619 := 0; 	  -- Controla posicion y de la bala izquierda
signal is_b3: std_logic := '0'; 	  	      	  -- Registra si hay o no bala en pantalla

signal x_b2: integer range 0 to 459 := 0; 	  -- Controla posicion x de la bala superior
signal y_b2: integer range 19 to 619 := 19; 	  -- Controla posicion y de la bala superior
signal is_b2: std_logic := '0'; 	  	  	    	  -- Registra si hay o no bala en pantalla

signal x_b1: integer range 19 to 459 := 19; 	  -- Controla posicion x de la bala derecha
signal y_b1: integer range 0 to 619 := 619; 	  -- Controla posicion y de la bala derecha
signal is_b1: std_logic := '0'; 	  	      	  -- Registra si hay o no bala en pantalla

signal x_b0: integer range 0 to 459 := 459; 	  -- Controla posicion x de la bala inferior
signal y_b0: integer range 19 to 619 := 19; 	  -- Controla posicion y de la bala inferior
signal is_b0: std_logic := '0'; 	  	      	  -- Registra si hay o no bala en pantalla

signal puntos_3: integer range 0 to 10 := 0;	  -- Controla el digito "X00.0" del contador
signal puntos_2: integer range 0 to 10 := 0;	  -- Controla el digito "0X0.0" del contador
signal puntos_1: integer range 0 to 10 := 0;	  -- Controla el digito "00X.0" del contador
signal puntos_0: integer range 0 to 10 := 0;	  -- Controla el digito "X00.X" del contador

BEGIN 

  PROCESS(row, column) -- Process para el dibujado del borde y el cuadro
  BEGIN

    IF(disp_ena = '1') THEN        
      IF (inicio = '1') THEN -- Pantalla de inicio
			if ((row < borde_inferior or row > borde_superior_row) or 
				(column < borde_inferior OR column > borde_superior_column)) 
			then -- Dibuja bordes
				red <= (OTHERS => '0');      
				green  <= (OTHERS => '0');
				blue <= (OTHERS => '1');
			elsif ( ((row > 168 and row < 220) and (column > 123 and column < 135)) or
			((row > 168 and row < 180) and (column > 123 and column < 175)) or
			((row > 188 and row < 200) and (column > 123 and column < 165)) or
			((row > 208 and row < 220) and (column > 123 and column < 175)) ) 
			then -- Dibuja la primer E
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '0');
			elsif( ((column > 178 and column < 230) and ((row > 168 and row < 180) or (row > 188 and row < 200) or (row > 208 and row < 220))) or
			((column > 178 and column < 190) and (row > 168 and row < 200)) or
			((column > 218 and column < 230) and (row > 188 and row < 220)) )
			then --Dibuja la primer S
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '0');
			elsif ( ((row > 168 and row < 220) and ((column > 233 and column < 245) or (column > 273 and column < 285))) or
			((column > 233 and column < 285) and ((row > 168 and row < 180) or (row > 208 and row < 220))) or
			((row > 178 and row < 190) and (column > 243 and column < 255)) or
			((row > 188 and row < 200) and (column > 253 and column < 265)) or
			((row > 198 and row < 210) and (column > 263 and column < 275)) )
			then -- Dibuja la Q
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '0');			
			elsif ( ((row > 168 and row < 220) and ((column > 288 and column < 300) or (column > 328 and column < 340))) or
			((row > 208 and row < 220) and (column > 288 and column < 340)) )
			then -- Dibuja la U
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '0');
			elsif ( ((column > 343 and column < 395) and ((row > 168 and row < 180) or (row > 208 and row < 220))) or
			((row > 168 and row < 220) and (column > 363 and column < 375)) )
			then -- Dibuja la I
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '0');
			elsif (((row > 168 and row < 190) and ((column > 398 and column < 410) or (column > 438 and column < 450))) or
			((row > 188 and row < 210) and ((column > 408 and column < 420) or (column > 428 and column < 440))) or
			((row > 208 and row < 220) and (column > 418 and column < 430)))
			then -- Dibuja la  V
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '0');
			elsif (((row > 178 and row < 220) and ((column > 453 and column < 475) or (column > 483 and column < 505))) or
			(((row > 168 and row < 180) or (row > 198 and row < 210)) and (column > 463 and column < 495))) 
			then -- Dibuja la primer A
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '0');
			elsif (((row > 223 and row < 275) and ((column > 148 and column < 160) or (column > 188 and column < 200))) or
			((row > 233 and row < 255) and ((column > 158 and column < 170) or (column > 178 and column < 190))) or
			((row > 243 and row < 265) and (column > 168 and column < 180))) 
			then -- Dibuja la  M
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '0');
			elsif ( ((row > 223 and row < 275) and (column > 203 and column < 215)) or
			((row > 223 and row < 235) and (column > 203 and column < 255)) or
			((row > 243 and row < 255) and (column > 203 and column < 245)) or
			((row > 263 and row < 275) and (column > 203 and column < 255)) ) 
			then -- Dibuja la segunda E
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '0');
			elsif( ((column > 258 and column < 310) and ((row > 223 and row < 235) or (row > 243 and row < 255) or (row > 263 and row < 275))) or
			((column > 258 and column < 270) and (row > 223 and row < 255)) or
			((column > 298 and column < 310) and (row > 243 and row < 275)) )
			then --Dibuja la segunda S
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '0');
			elsif ( ((column > 313 and column < 365) and (row > 223 and row < 235)) or
			((row > 223 and row < 275) and (column > 333 and column < 345)) )
			then -- Dibuja la T
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '0');			
			elsif (((row > 233 and row < 275) and ((column > 368 and column < 390) or (column > 398 and column < 420))) or
			(((row > 223 and row < 235) or (row > 253 and row < 265)) and (column > 378 and column < 410))) 
			then -- Dibuja la segunda A
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '0');
			elsif( ((column > 423 and column < 475) and ((row > 223 and row < 235) or (row > 243 and row < 255) or (row > 263 and row < 275))) or
			((column > 423 and column < 435) and (row > 223 and row < 255)) or
			((column > 463 and column < 475) and (row > 243 and row < 275)) )
			then --Dibuja la tercera S
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '0');
			else
				red <= (OTHERS => '0');
				green <= (OTHERS => '0');
				blue <= (OTHERS => '0');
			end if;
		ELSIF (game_over = '1' or balazo = '1') THEN			-- Pantalla de game over
			IF ((row < borde_inferior or row > borde_superior_row) or 
			(column < borde_inferior OR column > borde_superior_column)) THEN -- Dibuja bordes
				red <= (OTHERS => '0');      
				green  <= (OTHERS => '0');
				blue <= (OTHERS => '1');
			elsif (((row > 168 and row < 220) and (column > 218 and column < 230)) or 
			(((row > 168 and row < 220) and not(row > 178 and row < 190)) and (column > 258	and column < 270)) or
			(((row > 168 and row < 180) or (row > 208 and row < 220)) and (column > 218 and column < 270)) or
			((row > 189 and row < 200) and (column > 248 and column < 270)))
			then -- Dibuja la  G
				red <= (OTHERS => '1');
				green <= (OTHERS => '0');
				blue <= (OTHERS => '0');
			elsif (((row > 178 and row < 220) and ((column > 278 and column < 290) or (column > 298 and column < 310))) or
			(((row > 168 and row < 180) or (row > 198 and row < 210)) and (column > 288 and column < 300))) 
			then -- Dibuja la  A
				red <= (OTHERS => '1');
				green <= (OTHERS => '0');
				blue <= (OTHERS => '0');
			elsif (((row > 168 and row < 220) and ((column > 318 and column < 330) or (column > 358 and column < 370))) or
			((row > 178 and row < 200) and ((column > 328 and column < 340) or (column > 348 and column < 360))) or
			((row > 188 and row < 210) and (column > 338 and column < 350))) 
			then -- Dibuja la  M
				red <= (OTHERS => '1');
				green <= (OTHERS => '0');
				blue <= (OTHERS => '0');
			elsif (((row > 168 and row < 220) and ((column > 373 and column < 385))) or 
			((column > 373 and column < 405) and ((row > 168 and row < 180) or (row > 208 and row < 220))) or
			((row > 188 and row < 200) and (column > 373 and column < 395)))
			then -- Dibuja la 1er E
				red <= (OTHERS => '1');
				green <= (OTHERS => '0');
				blue <= (OTHERS => '0');
			elsif ((((row > 233 and row < 265) and ((column > 218 and column < 230 ) or (column > 258 and column < 270)))) or 
			((column > 228 and column < 260) and ((row > 223 and  row < 235) or (row > 263 and row < 275)))) 
			then -- Dibuja la  O
				red <= (OTHERS => '1');
				green <= (OTHERS => '0');
				blue <= (OTHERS => '0');
			elsif (((row > 223 and row < 255) and ((column > 273 and column < 285) or (column > 313 and column < 325))) or
			((row > 243 and row < 265) and ((column > 283 and column < 295) or (column > 303 and column < 315))) or
			((row > 253 and row < 275) and (column > 293 and column < 305)))
			then -- Dibuja la  V
				red <= (OTHERS => '1');
				green <= (OTHERS => '0');
				blue <= (OTHERS => '0');
			elsif (((row > 223 and row < 275) and ((column > 328 and column < 340))) or 
			((column > 328 and column < 360) and ((row > 223 and row < 235) or (row > 263 and row < 275))) or
			((row > 243 and row < 255) and (column > 328 and column < 350)))
			then -- Dibuja la 2a E
				red <= (OTHERS => '1');
				green <= (OTHERS => '0');
				blue <= (OTHERS => '0');
			elsif (((row > 223 and row < 275) and ((column > 368 and column < 380))) or
			((row > 223 and row < 255) and (column > 378 and column < 390)) or
			(((row > 223 and row < 275) and not(row > 243 and row < 255)) and (column > 388 and column < 400)))
			then -- Dibuja la  R
				red <= (OTHERS => '1');
				green <= (OTHERS => '0');
				blue <= (OTHERS => '0');
			else -- Dibuja el fondo
				red <= (OTHERS => '0');
				green <= (OTHERS => '0');
				blue <= (OTHERS => '0');
			END IF;
		ELSIF ((row < borde_inferior or row > borde_superior_row) or 	   						--Pantalla de juego juego
			(column < borde_inferior OR column > borde_superior_column)) THEN 					-- Dibuja bordes
				red <= (OTHERS => '0');
				green  <= (OTHERS => '0');
				blue <= (OTHERS => '1');
		
		ELSIF((row > x AND row < (x+50)) AND (column < (y+50) AND column > y)) THEN 			-- Dibuja cuadrado
				red <= (OTHERS => '0');
				green  <= (OTHERS => '1');
				blue <= (OTHERS => '0');
			
		elsif ((is_b3 = '1') and 
		((row > x_b3 AND row < (x_b3+20)) AND (column < (y_b3+20) AND column > y_b3))) then -- Dibuja la bala 3
					red <= (OTHERS => '1');
					green  <= (OTHERS => '1');
					blue <= (OTHERS => '0');
				
		elsif ((is_b2 = '1') and 
		((row > x_b2 AND row < (x_b2+20)) AND (column < (y_b2+20) AND column > y_b2))) then -- Dibuja la bala 2
						red <= (OTHERS => '1');
						green  <= (OTHERS => '1');
						blue <= (OTHERS => '0');
			
		elsif ((is_b1 = '1') and 
		((row > x_b1 AND row < (x_b1+20)) AND (column < (y_b1+20) AND column > y_b1))) then -- Dibuja la bala 1
				red <= (OTHERS => '1');
        		green  <= (OTHERS => '1');
        		blue <= (OTHERS => '0');
		
		elsif ((is_b0 = '1') and
		((row > x_b0 AND row < (x_b0+20)) AND (column < (y_b0+20) AND column > y_b0))) then -- Dibuja la bala 0
				red <= (OTHERS => '1');
        		green  <= (OTHERS => '1');
        		blue <= (OTHERS => '0');
	
		ELSE		-- Dibuja el fondo
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
      END IF;							  -- Cierra el dibujado de juego
    ELSE                           --blanking time (else de disp_ena)
      red <= (OTHERS => '0');
      green <= (OTHERS => '0');
      blue <= (OTHERS => '0');
    END IF; 								-- Cierra disp_ena 
  END PROCESS;
  
  process(game_over, mov, reset_n, -- Process que controla la posicion del cuadro y las balas
  x_b3, y_b3, is_b3, 
  x_b2, y_b2, is_b2, 
  x_b1, y_b1, is_b1,
  x_b0, y_b0, is_b0)
  
  begin
  
  if (rising_edge(game_clk)) then -- Sección que controla el cuadro
	if (mov(3) = '1') then 
		if (y = borde_inferior-1) then
			game_over <= '1';
			y <= y;
		else
			y <= y-1;
		end if;
	end if;
	
	if (mov(2) = '1') then 
		if (x = borde_inferior-1) then
			game_over <= '1';
			x <= x;
		else
			x <= x-1;
		end if;
	end if;
	
	if (mov(1) = '1') then 
		if (x = borde_superior_row-49) then
			game_over <= '1';
			x <= x;
		else
			x <= x+1;
		end if;
	end if;
	
	if (mov(0) = '1') then 
		if (y = borde_superior_column-49) then
			game_over <= '1';
			y <= y;
		else
			y <= y+1;
		end if;
	end if;

	if reset_n = '0' then
		x <= 215;
     	y <= 295;
     	game_over <= '0';
		inicio <= '0';
   end if ;	
  end if;

	if rising_edge(bullet_clk) then -- Seccion que controla las balas
		
		if is_b3 = '0' then		-- Validaciones para la bala izquierda(3)	
			is_b3 <= '1';			-- Si la bala no existe, se crea
			x_b3 <= x;				-- Asignación de vavlor segun posicion
		elsif y_b3 < borde_superior_column then
			y_b3 <= y_b3 + 1;		-- Si la bala esta en la zona visible, se mueve
			
			if (y_b3 < y+50 and y_b3+20 > y and x_b3 < x+50 and x_b3+20 > x) 
			then -- Valida si la bala coindice en zonas con el cuadro
				balazo <= '1'; -- 
			end if;
			
		else 						-- Cuando la bala existe pero alcanza el borde, reinicia sus parametros
			is_b3 <= '0';
			y_b3 <= 0;
			x_b3 <= 19; 
		end if ;
		
		if is_b2 = '0' then		-- Validaciones para la bala superior(2)	
			is_b2 <= '1';			
			y_b2 <= y;				-- Asignación de vavlor segun posicion
		elsif x_b2 < borde_superior_row then
			x_b2 <= x_b2 + 1;		
			
			if (y_b2 < y+50 and y_b2+20 > y and x_b2 < x+50 and x_b2+20 > x) 
			then -- Valida si la bala coindice en zonas con el cuadro
				balazo <= '1'; -- 
			end if;
			
		else 						-- Cuando la bala existe pero alcanza el borde, reinicia sus parametros
			is_b2 <= '0';
			x_b2 <= 0;
			y_b2 <= 19;
		end if ;
		
		if is_b1 = '0' then		-- Validaciones para la bala derecha(1)	
			is_b1 <= '1';			
			x_b1 <= x+40;				-- Asignación de vavlor segun posicion
		elsif y_b1 > borde_inferior then
			y_b1 <= y_b1 - 1;		
			
			if (y_b1 < y+50 and y_b1+20 > y and x_b1 < x+50 and x_b1+20 > x) 
			then -- Valida si la bala coindice en zonas con el cuadro
				balazo <= '1'; -- 
			end if;
			
		else 						-- Cuando la bala existe pero alcanza el borde, reinicia sus parametros
			is_b1 <= '0';
			y_b1 <= 619;
			x_b1 <= 19; 
		end if ;
		
		if is_b0 = '0' then		-- Validaciones para la bala inferior(0)	
			is_b0 <= '1';			
			y_b0 <= y+40;				-- Asignación de vavlor segun posicion
		elsif x_b0 > borde_inferior then
			x_b0 <= x_b0 - 1;		
			
			if (y_b0 < y+50 and y_b0+20 > y and x_b0 < x+50 and x_b0+20 > x) 
			then -- Valida si la bala coindice en zonas con el cuadro
				balazo <= '1'; -- 
			end if;
			
		else 						-- Cuando la bala existe pero alcanza el borde, reinicia sus parametros
			is_b0 <= '0';
			y_b0 <= 19;
			x_b0 <= 459; 
		end if ;
		
		if reset_n = '0' then	--devuelve las balas a la posicion por defecto
			balazo <= '0';
			is_b3 <= '0';
			y_b3 <= 0;
			x_b3 <= 19;
			is_b2 <= '0';
			y_b2 <= 19;
			x_b2 <= 0;
			is_b1 <= '0';
			y_b1 <= 619;
			x_b1 <= 19;
			is_b0 <= '0';
			y_b0 <= 19;
			x_b0 <= 459;
		end if ;
	end if ;

  end process;

  process (score_2, score_1, score_0, puntos_2, puntos_1, puntos_0) -- Control de puntaje en tarjeta
  begin
  if rising_edge(point_clk) then
  
	if (game_over = '1' or balazo = '1' or inicio = '1') then -- El contador no avanza fuera de la pantalla de juego
		puntos_0 <= puntos_0;
		puntos_1 <= puntos_1;
		puntos_2 <= puntos_2;
		puntos_3 <= puntos_3;
	
	elsif reset_n = '0' then -- Reiniciar el juego vuelve el contador a 0
		puntos_0 <= 0;
		puntos_1 <= 0;
		puntos_2 <= 0;
		puntos_3 <= 0;
	
	else
		puntos_0 <= puntos_0+1; -- Registra el paso de una decima de segundo
	
		if puntos_0 = 10 then
			puntos_0 <= 0;
			puntos_1 <= puntos_1+1;
	
			if puntos_1 = 9 then
				puntos_1 <= 0;
				puntos_2 <= puntos_2+1;
				
				if puntos_2 = 9 then
					puntos_2 <= 0;
					puntos_3 <= puntos_3+1;
				end if;
			end if;
		end if;
		
		case puntos_0 is 
			when 0 =>
				score_0 <= x"03";
			when 1 =>
				score_0 <= x"9F";
			when 2 =>
				score_0 <= x"25";
			when 3 =>
				score_0 <= x"0D";
			when 4 =>
				score_0 <= x"99";
			when 5 =>
				score_0 <= x"49";
			when 6 =>
				score_0 <= x"41";
			when 7 =>
				score_0 <= x"1F";
			when 8 =>
				score_0 <= x"01";
			when 9 =>
				score_0 <= x"09";
			when others =>
				score_0 <= x"03";
		end case;

		case puntos_1 is 
			when 0 =>
				score_1 <= x"02";
			when 1 =>
				score_1 <= x"9E";
			when 2 =>
				score_1 <= x"24";
			when 3 =>
				score_1 <= x"0C";
			when 4 =>
				score_1 <= x"98";
			when 5 =>
				score_1 <= x"48";
			when 6 =>
				score_1 <= x"40";
			when 7 =>
				score_1 <= x"1E";
			when 8 =>
				score_1 <= x"00";
			when 9 =>
				score_1 <= x"08";
			when others =>
				score_1 <= x"02";
		end case;
	
		case puntos_2 is
			when 0 =>
				score_2 <= x"03";
			when 1 =>
				score_2 <= x"9F";
			when 2 =>
				score_2 <= x"25";
			when 3 =>
				score_2 <= x"0D";
			when 4 =>
				score_2 <= x"99";
			when 5 =>
				score_2 <= x"49";
			when 6 =>
				score_2 <= x"41";
			when 7 =>
				score_2 <= x"1F";
			when 8 =>
				score_2 <= x"01";
			when 9 =>
				score_2 <= x"09";
			when others =>
				score_2 <= x"03";
		end case;
		
		case puntos_3 is
			when 0 =>
				score_3 <= x"03";
			when 1 =>
				score_3 <= x"9F";
			when 2 =>
				score_3 <= x"25";
			when 3 =>
				score_3 <= x"0D";
			when 4 =>
				score_3 <= x"99";
			when 5 =>
				score_3 <= x"49";
			when 6 =>
				score_3 <= x"41";
			when 7 =>
				score_3 <= x"1F";
			when 8 =>
				score_3 <= x"01";
			when 9 =>
				score_3 <= x"09";
			when others =>
				score_3 <= x"03";
		end case;
	
	end if;
  end if;
  end process;

END architecture;