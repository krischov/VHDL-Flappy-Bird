library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib;
use lib.textengine_package.all;

entity main is
	port (clk : in std_ulogic;
		 vga_row, vga_col : in unsigned(9 downto 0);
		 mouse_lbtn, mouse_rbtn : in std_logic;
		 mouse_row 			: in unsigned(9 DOWNTO 0); 
		 mouse_col 		: in unsigned(9 DOWNTO 0);
		 pb_0, pb_1 : in std_logic;
		 red_in, green_in, blue_in : in unsigned (2 downto 0);
		 red_out, green_out, blue_out : OUT unsigned(3 downto 0));
end entity;

architecture x of main is 
	signal y0, x0: unsigned(9 downto 0) := to_unsigned(50, 10);
	signal w, h: unsigned(9 downto 0) := to_unsigned(100, 10);
	signal colour: unsigned(3 downto 0) := "0000";
	
	signal text_vector: textengine_vector := (others => init_textengine_row);
	signal txt_r : unsigned(3 downto 0) := "0000";
	signal txt_g : unsigned(3 downto 0) := "0000";
	signal txt_b : unsigned(3 downto 0) := "0000";
	signal txt_not_a : unsigned(3 downto 0) := "0000";
<<<<<<< Updated upstream
=======
	signal sprite_r : unsigned(3 downto 0);
	signal sprite_g : unsigned(3 downto 0);
	signal sprite_b : unsigned(3 downto 0);
	signal sprite_z : unsigned(3 downto 0);
	signal mouse_btn : string(1 to 50) := var_len_str("No Mouse Button Pressed", 50);
	signal next_frame_collision_flag : std_logic := '0';
	signal sec : natural range 0 to 59 := 0;
	signal birdcollision_addr : unsigned (11 downto 0);
	signal pipecollision_addr : unsigned (11 downto 0);
	signal initial_lclick : std_logic := '0';
	signal initial_rclick : std_logic := '0'
	signal health_flag : std_logic := '0';
	
	
	-- (sprite size, y0, x0, addr, sprite, colour, in_range, scale_x, scale_y, visible, underflow, passed_pipe)  

	signal bird : all_sprites(0 to 1)  := (
		(32, to_unsigned(195, 10), to_unsigned(50,10), "000000000000", bird0, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(150, 10), to_unsigned(50,10), "000000000000", bird0, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE)
	);
	signal grassplane : all_sprites(0 to 9) := (
		(32, to_unsigned(448, 10), to_unsigned(0,10), "000000000000", grass, "0000000000000000", false, 2, 1, FALSE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(64,10), "000000000000", grass, "0000000000000000", false, 2, 1, FALSE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(128,10), "000000000000", grass, "0000000000000000", false, 2, 1, FALSE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(192,10), "000000000000", grass, "0000000000000000", false, 2, 1, FALSE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(256,10), "000000000000", grass, "0000000000000000", false, 2, 1, FALSE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(320,10), "000000000000", grass, "0000000000000000", false, 2, 1, FALSE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(384,10), "000000000000", grass, "0000000000000000", false, 2, 1, FALSE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(448,10), "000000000000", grass, "0000000000000000", false, 2, 1, FALSE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(512,10), "000000000000", grass, "0000000000000000", false, 2, 1, FALSE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(576,10), "000000000000", grass, "0000000000000000", false, 2, 1, FALSE, FALSE, FALSE)
	);

	signal bottompipe : all_sprites(0 to 1) := (
		(64, to_unsigned(288, 10), to_unsigned(340, 10), "000000000000", crackpipe, "0000000000000000", false, 1, 3, TRUE, FALSE, FALSE),
		(64, to_unsigned(288, 10), to_unsigned(540, 10), "000000000000", crackpipe, "0000000000000000", false, 1, 3, TRUE, FALSE, FALSE)
	);
	
	signal toppipes : all_sprites(0 to 1) := (
		(64, to_unsigned(0, 10), to_unsigned(340, 10), "000000000000", toppipe, "0000000000000000", false, 1, 3, TRUE, FALSE, FALSE),
		(64, to_unsigned(0, 10), to_unsigned(540, 10), "000000000000", toppipe, "0000000000000000", false, 1, 3, TRUE, FALSE, FALSE)
	);

	
	signal tree0s : all_sprites(0 to 2) := (
		(64, to_unsigned(380, 10), to_unsigned(80, 10), "000000000000", tree0, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE),
		(64, to_unsigned(380, 10), to_unsigned(200, 10), "000000000000", tree0, "0000000000000000", false, 1, 2, FALSE, FALSE, FALSE),
		(64, to_unsigned(380, 10), to_unsigned(400, 10), "000000000000", tree0, "0000000000000000", false, 2, 2, FALSE, FALSE, FALSE)
	);
	
	signal mousecursor : all_sprites(0 to 1) := (
		(16, to_unsigned(236, 10), to_unsigned(316,10), "000000000000", cursor, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE),
		(16, to_unsigned(150, 10), to_unsigned(50,10), "000000000000", cursor, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE)
	);
	
	signal hearts: all_sprites(0 to 2) := (
		(16, to_unsigned(8, 10), to_unsigned(8,10), "000000000000", heart, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE),
		(16, to_unsigned(8, 10), to_unsigned(32,10), "000000000000", heart, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE),
		(16, to_unsigned(8, 10), to_unsigned(56,10), "000000000000", heart, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE)
	);
	
	
	-- Sprite Indexes
	
	signal sprites_addrs : sprite_addr_array := (others => "000000000000");
	signal sprites_out : sprite_output_array := (others => "0000000000000000");
	signal grass_idx, bottompipe_idx, bird_idx, tree0_idx, toppipe_idx , mousecursor_idx, heart_idx : integer := -1;
	
	-- ========================
	
	-- Game mode, and associated constants
	
	constant MODE_TITLE : integer range 0 to 7 := 0;
	constant MODE_GAME : integer range 0 to 7 := 1;
	constant MODE_TRAIN : integer range 0 to 7 := 2;
	constant MODE_HARD : integer range 0 to 7 := 3;
	constant MODE_OVER : integer range 0 to 7 := 4;
	
	
	signal game_mode : integer range 0 to 7 := MODE_GAME;
	
	-- ========================
	
	-- Player Stats
	
	signal health: natural range 0 to 3 := 3;
	signal pipe_points: natural range 0 to 8000 := 0;
>>>>>>> Stashed changes
	
	signal mouse_btn : string(1 to 50) := var_len_str("No Mouse Button Pressed", 50);
	
	signal sec : natural range 0 to 59 := 0;
begin
	textengine0: textengine port map(clk, text_vector, vga_row, vga_col, txt_r, txt_g, txt_b, txt_not_a);
	
	str2text(text_vector, 0, 0, 1, '1' & red_in, '0' & green_in, '1' & blue_in, " __  __           _      _     _            __  __       _         _");
	str2text(text_vector, 1, 0, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "|  \/  |         | |    | |   (_)          |  \/  |     | |       | |");
	str2text(text_vector, 2, 0, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "| \  / | ___   __| | ___| |___ _ _ __ ___  | \  / | ___ | |__  ___| |_ ___ _ __");
	str2text(text_vector, 3, 0, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "| |\/| |/ _ \ / _` |/ _ \ / __| | '_ ` _ \ | |\/| |/ _ \| '_ \/ __| __/ _ \ '__|");
	str2text(text_vector, 4, 0, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "| |  | | (_) | (_| |  __/ \__ \ | | | | | || |  | | (_) | |_) \__ \ ||  __/ |");
	str2text(text_vector, 5, 0, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "|_|  |_|\___/ \__,_|\___|_|___/_|_| |_| |_||_|  |_|\___/|_.__/|___/\__\___|_|");
	
	--str2text(text_vector, 2, 20, 1, "1111", "1111", "1111", "The Modelsim Mobsters:");
	str2text(text_vector, 8, 30, 1, "1010", "0101", "1100", " Project Demo ");
	str2text(text_vector, 10, 20, 1, "0011", "1100", "1001", mouse_btn);
	str2text(text_vector, 13, 20, 1, "0011", "1100", "1001", "HOLD DOWN BUTTON0 and BUTTON1 to move the square up or down");
	str2text(text_vector, 14, 20, 1, "0011", "1100", "1001", "The 7segmment shows the x or y position of the mouse");
	str2text(text_vector, 15, 20, 1, "0011", "1100", "1001", "SW9 Down shows Mouse Y pos, SW0 Up shows Mouse X pos");
	str2text(text_vector, 16, 20, 1, "0011", "1100", "1001", "SW0 to SW8 control the colours");
	
	process(clk)
		variable ticks : integer := 0;
	begin
		if (rising_edge(clk)) then
			ticks := ticks + 1;
			if (ticks >= 25000000) then
				-- things to happen every second
				sec <= sec + 1;

				
				-- make the red square move in a square
				if (not (y0 < 1) and pb_0 = '1') then
					y0 <= y0 - 25;
				elsif(not (y0 > 375) and pb_1 = '1') then
					y0 <= y0 + 25;
				end if;
				
				ticks := 0;
			end if;
			
			-- change background colour
			if (mouse_lbtn = '1') then
				colour <= "0101";
				mouse_btn <= var_len_str("Left Mouse button Pressed", mouse_btn'length);
			elsif (mouse_rbtn = '1') then
				colour <= "1010";
				mouse_btn <= var_len_str("Right Mouse button Pressed", mouse_btn'length);
			else
				colour <= "1111";
				mouse_btn <= var_len_str("No Mouse button Pressed", mouse_btn'length);
			end if;
			
<<<<<<< Updated upstream
			-- draw text
			if (txt_not_a = "1111") then
				red_out <= txt_r;
				green_out <= txt_g;
				blue_out <= txt_b;
			-- draw red square
			elsif (vga_row < y0 + h and vga_row > y0 and 
					vga_col < x0 + w and vga_col > x0) then
				red_out <= red_in & '0';
				green_out <= green_in & '0';
				blue_out <= blue_in & '0';
			else
				red_out <= "0000";
				green_out <= "0000";
				blue_out <= "0000";
			end if;
=======
			if (pb_0 = '1') then
			
			end if;
			
		
			if (game_mode = MODE_TITLE) then
				text_vector <= tvec_mode_title;
			elsif (game_mode = MODE_GAME) then
				text_vector <= tvec_mode_game;
			elsif (game_mode = MODE_OVER) then
				text_vector <= tvec_mode_over;
			end if;
			
--			if (health_flag = '1') then
--				initial_lclick <= '0';
--			end if;
			
>>>>>>> Stashed changes
		end if;
	end process;
<<<<<<< Updated upstream
=======
	
	Pipe: process(v_sync)
	variable mouse_flag : std_logic := '0';
	variable birdxpos, birdypos : unsigned (9 downto 0);
	variable pipexpos, pipeypos : unsigned (9 downto 0);
	variable t_flag: std_logic := '0';
	variable bird_pos : unsigned (9 downto 0);
	variable toppipe_pos : unsigned (11 downto 0);
	variable collision_flag : std_logic := '0';
	variable frame : natural range 0 to 60 := 0;
	variable ticks : integer := 0;
	variable seconds : integer := 0;
	-- total number of pixels to shift bird up by per mouse click
	constant h_boost : natural range 0 to 256 := 60;
	-- apply this much h_boost per frame to get it done in 8 frames
	constant h_boost_per_frame : natural range 0 to 8 := h_boost / 8; 
	-- If > 0 the mouse bird should be boosted this frame. Decremented by 1 each frame a hboost is applied
	variable apply_h_boost : natural range 0 to 8 := 0; 
	begin
		if (rising_edge(v_sync)) then
			ticks := ticks + 1
			if (ticks >= 60 and seconds <= 3) then
				seconds := seconds + 1
			else
				seconds := 0;
			end if;
			frame := frame + 1;
			if (frame > 59) then
				frame := 0;
			end if (ticks 
			-- Pipe Collision Detection, and Pipe Movement
			if (health_flag = '1') then
				if (health = 0) then
					game_mode <= MODE_OVER;
				elsif (health > 0) then
					health <= health - 1;
					hearts(health - 1).visible <= FALSE;
					health_flag <= '0';
					collision_flag := '0';
--					bird(0).x0 <= to_unsigned(50, 10);
--					bird(0).y0 <= to_unsigned(195, 10);
--					--Resets pipe values when bird collides 
--					bottompipe(0).y0 <= to_unsigned(288, 10);
--					bottompipe(0).x0 <= to_unsigned(340, 10);
--					toppipes(0).y0 <= to_unsigned(0, 10);
--					toppipes(0).x0 <= to_unsigned(340, 10);
--					bottompipe(1).y0 <= to_unsigned(288, 10);
--					bottompipe(1).x0 <= to_unsigned(540, 10);
--					toppipes(1).y0 <= to_unsigned(0, 10);
--					toppipes(1).x0 <= to_unsigned(540, 10);
					if 
					
				end if;
				
			end if;
			
				
			for i in 0 to (bottompipe'length - 1) loop
			
				if (game_mode = MODE_TITLE) then
					bottompipe(i).visible <= FALSE;
					toppipes(i).visible <= FALSE;
				else
					bottompipe(i).visible <= TRUE;
					toppipes(i).visible <= TRUE;
				end if;
				
				if (initial_lclick = '1')then

--					if (collision_flag = '0' and game_mode = MODE_GAME and health_flag = '0') then
					if (game_mode = MODE_GAME and health_flag = '0') then
						if (bottompipe(i).underflow = false) then
							bottompipe(i).x0 <= bottompipe(i).x0 - 2;
							if (bottompipe(i).x0 > 640) then
								bottompipe(i).underflow <= true;
							end if;
						elsif (bottompipe(i).underflow = true and (1023 - bottompipe(i).x0 <= (bottompipe(i).size * bottompipe(i).scaling_factor_x))) then
							bottompipe(i).x0 <= bottompipe(i).x0 - 2;
						elsif (bottompipe(i).underflow = true and (1023 - bottompipe(i).x0 > (bottompipe(i).size * bottompipe(i).scaling_factor_x))) then
							bottompipe(i).x0 <= to_unsigned(640, 10);
							bottompipe(i).underflow <= false;
						end if;
						
						if (toppipes(i).underflow = false) then
							toppipes(i).x0 <= toppipes(i).x0 - 2;
							if (toppipes(i).x0 > 640) then
								toppipes(i).underflow <= true;
							end if;
						elsif (toppipes(i).underflow = true and (1023 - toppipes(i).x0 <= (toppipes(i).size * toppipes(i).scaling_factor_x))) then
							toppipes(i).x0 <= toppipes(i).x0 - 2;
						elsif (toppipes(i).underflow = true and (1023 - toppipes(i).x0 > (toppipes(i).size * toppipes(i).scaling_factor_x))) then
							toppipes(i).x0 <= to_unsigned(640, 10);
							toppipes(i).underflow <= false;
						end if;
					
						if (bird(0).visible = true and seconds = ) then
							-- Do collision and point detection here
							if (((bird(0).x0 + 2 >= toppipes(i).x0) and ((bird(0).x0 + bird(0).size - 1) <= toppipes(i).x0 + toppipes(i).size - 1)) and 
								(((bird(0).y0 + 4 >= toppipes(i).y0) and (bird(0).y0 + 4 <= toppipes(i).y0 + toppipes(i).size*toppipes(i).scaling_factor_y + 1)) or
								((bird(0).y0 + bird(0).size - 6 >= bottompipe(i).y0) and (bird(0).y0 + bird(0).size - 8 <= bottompipe(i).y0 + bottompipe(1).size*bottompipe(i).scaling_factor_y - 1)))) then
								collision_flag := '1';
								health_flag <= '1';
							else
										
								if (((bird(0).x0 + 2 >= toppipes(i).x0) and (bird(0).x0 + 2 <= toppipes(i).x0 + toppipes(i).size - 1)) and 
									((bird(0).y0 + 4 >= toppipes(i).y0) and (bird(0).y0 + 4 <= toppipes(i).y0 + toppipes(i).size*toppipes(i).scaling_factor_y - 1))) then
									birdxpos := (toppipes(i).x0 + toppipes(i).size - 1) - (bird(0).x0);
									birdypos := (toppipes(i).size*toppipes(i).scaling_factor_y - 1) - (bird(0).y0);
									pipexpos := (toppipes(i).size - 1) - birdxpos;
									pipeypos := (toppipes(i).y0 + toppipes(i).size*toppipes(i).scaling_factor_y - 1);
									bird_pos := resize(birdypos * 32 + birdxpos, 10);
									toppipe_pos := resize(pipeypos * 64 + pipeypos, 12);
									if (bird_transparency(to_integer(bird_pos)) /= '1' and top_pipe_transparency(to_integer(toppipe_pos)) /= '1') then
										collision_flag := '1';
										health_flag <= '1';
									end if;
								end if;
								
								if (((bird(0).x0 + bird(0).size - 1 >= toppipes(i).x0) and (bird(0).x0 + bird(0).size - 1 <= toppipes(i).x0 + bird(0).size - 1)) and 
									((bird(0).y0 + 4 >= toppipes(i).y0) and (bird(0).y0 + 4 <= toppipes(i).y0 + toppipes(i).size*toppipes(i).scaling_factor_y - 1))) then
									birdxpos := (bird(0).size -  1) - ((bird(0).x0 + bird(0).size - 1) - toppipes(i).x0);
									birdypos := (toppipes(i).size*toppipes(i).scaling_factor_y - 1) - (bird(0).y0);
									pipexpos := bird(0).x0 + bird(0).size - 1;
									pipeypos := (toppipes(i).y0 + toppipes(i).size*toppipes(i).scaling_factor_y - 1);
									bird_pos := resize(birdypos * 32 + birdxpos, 10);
									toppipe_pos := resize(pipeypos * 64 + pipeypos, 12);
									if (bird_transparency(to_integer(bird_pos)) /= '1' and top_pipe_transparency(to_integer(toppipe_pos)) /= '1') then
										collision_flag := '1';
										health_flag <= '1';
									end if;
								end if;
									
								if (((bird(0).x0 + bird(0).size - 1 >= bottompipe(i).x0) and (bird(0).x0 + bird(0).size - 1 <= bottompipe(i).x0 + bird(0).size - 1)) and 
									((bird(0).y0 + bird(0).size - 6 >= bottompipe(i).y0) and (bird(0).y0 + bird(0).size - 6 <= bottompipe(i).y0 + bottompipe(i).size*bottompipe(i).scaling_factor_y - 1))) then
									birdxpos := (bird(0).size -  1) - ((bird(0).x0 + bird(0).size - 1) - toppipes(i).x0);
									birdypos := bottompipe(i).y0 - (bird(0).y0);
									pipexpos := bird(0).x0 + bird(0).size - 1;
									pipeypos := bottompipe(i).y0;
									bird_pos := resize(birdypos * 32 + birdxpos, 10);
									toppipe_pos := resize(pipeypos * 64 + pipeypos, 12);
									if (bird_transparency(to_integer(bird_pos)) /= '1' and top_pipe_transparency(to_integer(toppipe_pos)) /= '1') then
										collision_flag := '1';
										health_flag <= '1';
									end if;
								end if;
								
								if (((bird(0).x0 + 2 >= bottompipe(i).x0) and (bird(0).x0 + 2 <= bottompipe(i).x0 + bottompipe(i).size - 1)) and 
									((bird(0).y0 + bird(0).size - 6 >= bottompipe(i).y0) and (bird(0).y0 + bird(0).size - 6 <= bottompipe(i).y0 + bottompipe(i).size*bottompipe(i).scaling_factor_y - 1))) then
									birdxpos := (bottompipe(i).x0 + bottompipe(i).size - 1) - (bird(0).x0);
									birdypos := bottompipe(i).y0 - (bird(0).y0);
									pipexpos := (bottompipe(i).size - 1) - birdxpos;
									pipeypos := bottompipe(i).y0;
									bird_pos := resize(birdypos * 32 + birdxpos, 10);
									toppipe_pos := resize(pipeypos * 64 + pipeypos, 12);
									if (bird_transparency(to_integer(bird_pos)) /= '1' and top_pipe_transparency(to_integer(toppipe_pos)) /= '1') then
										collision_flag := '1';
										health_flag <= '1';
									end if;
								end if;
							end if;
						end if;
		
					
						-- if the user has just passed through this pipe, give them a point
							if (bottompipe(i).passed_pipe = false and bird(0).x0 > bottompipe(i).x0 + bottompipe(i).size * bottompipe(i).scaling_factor_x) then
								bottompipe(i).passed_pipe <= true;
								pipe_points <= pipe_points + 1; 
							end if;
						end if;
					end if;
			end loop;
		
			-- Boost the bird up on mouse click, otherwise make it fall 
			-- Don't let the bird flap if we have detected a collision (remember we are drawing the next frame here)
			if (collision_flag = '0' and initial_lclick = '1') then
				if (apply_h_boost > 0) then
					if (bird(0).y0 - h_boost_per_frame >= 0) then
						bird(0).y0 <= bird(0).y0 - h_boost_per_frame;
						apply_h_boost := apply_h_boost - 1;
					end if;
				else
					-- lower bird by 3 pixels (make it 'fall' 3 pixels)
					if (bird(0).y0 + 3 <= 452)	then
						bird(0).y0 <= bird(0).y0 + 3;
					end if;
				end if;
			end if;
			
			-- Mouse input (make the bird flap)
			-- Don't let the bird flap if we have detected a collision (remember we are drawing the next frame here)
			if (collision_flag = '0' and initial_lclick = '1') then
				if (mouse_lbtn = '1' and mouse_flag = '0') then
					mouse_flag := '1';
					apply_h_boost := 8;
				end if;
			end if;
			
			if (mouse_lbtn = '0' and mouse_flag = '1') then
				mouse_flag := '0';
			end if;
			if (game_mode = MODE_GAME or game_mode = MODE_TITLE or game_mode = MODE_TRAIN) then
				for i in 0 to (tree0s'length - 1) loop
					if (tree0s(i).underflow = false) then
						tree0s(i).x0 <= tree0s(i).x0 - 2;
						if (tree0s(i).x0 > 640) then
							tree0s(i).underflow <= true;
						end if;
					elsif (tree0s(i).underflow = true and (1023 - tree0s(i).x0 <= (tree0s(i).size * tree0s(i).scaling_factor_x))) then
						tree0s(i).x0 <= tree0s(i).x0 - 2;
					elsif (tree0s(i).underflow = true and (1023 - tree0s(i).x0 > (tree0s(i).size * tree0s(i).scaling_factor_x))) then
						tree0s(i).x0 <= to_unsigned(640, 10);
						tree0s(i).underflow <= false;
					end if;
				end loop;
				
				for i in 0 to (grassplane'length - 1) loop
					if (grassplane(i).underflow = false) then
						grassplane(i).x0 <= grassplane(i).x0 - 2;
						if (grassplane(i).x0 > 640) then
							grassplane(i).underflow <= true;
						end if;
					elsif (grassplane(i).underflow = true and (1023 - grassplane(i).x0 <= (grassplane(i).size * grassplane(i).scaling_factor_x))) then
						grassplane(i).x0 <= grassplane(i).x0 - 2;
					elsif (grassplane(i).underflow = true and (1023 - grassplane(i).x0 > (grassplane(i).size * grassplane(i).scaling_factor_x))) then
						grassplane(i).x0 <= to_unsigned(640, 10);
						grassplane(i).underflow <= false;
					end if;
				end loop;
			end if;
			
			if (game_mode = MODE_OVER) then
				if (bird(0).y0 + 5 <= 672) then
					bird(0).y0 <= bird(0).y0 + 5;
				end if;
			end if;
			
		end if; 
	end process;
	
>>>>>>> Stashed changes
end architecture;
