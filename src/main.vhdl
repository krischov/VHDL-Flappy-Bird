library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib;
use lib.textengine_package.all;
use lib.spriteengine_package.all;

entity main is
	port (clk : in std_ulogic;
		 vga_row, vga_col : in unsigned(9 downto 0);
		 mouse_lbtn, mouse_rbtn : in std_logic;
		 mouse_row 			: in unsigned(9 DOWNTO 0); 
		 mouse_col 		: in unsigned(9 DOWNTO 0);
		 pb_0, pb_1 : in std_logic;
		 h_sync, v_sync : in  std_logic;
		 red_in, green_in, blue_in : in unsigned (2 downto 0);
		 red_out, green_out, blue_out : OUT unsigned(3 downto 0));
end entity;

architecture x of main is 
	
	-- components --
	component spriteengine is
		port(
			clk			: in std_ulogic;
			vga_row		: in unsigned(9 downto 0);
			vga_col		: in unsigned(9 downto 0);
			sprite_addrs	: in sprite_addr_array;
			sprites_out : out sprite_output_array
			);
	end component spriteengine;
	-- signals -- 
	

	
	signal text_vector: textengine_vector := (others => init_textengine_row);
	signal txt_r : unsigned(3 downto 0) := "0000";
	signal txt_g : unsigned(3 downto 0) := "0000";
	signal txt_b : unsigned(3 downto 0) := "0000";
	signal txt_not_a : unsigned(3 downto 0) := "0000";
	signal sprite_r : unsigned(3 downto 0);
	signal sprite_g : unsigned(3 downto 0);
	signal sprite_b : unsigned(3 downto 0);
	signal sprite_z : unsigned(3 downto 0);
	signal mouse_btn : string(1 to 50) := var_len_str("No Mouse Button Pressed", 50);
	signal next_frame_collision_flag : std_logic := '0';
	signal sec : natural range 0 to 59 := 0;
	signal birdcollision_addr : unsigned (11 downto 0);
	signal pipecollision_addr : unsigned (11 downto 0);
	
	
	-- (sprite size, y0, x0, addr, sprite, colour, in_range, scale_x, scale_y, visible, underflow, passed_pipe)  

	signal bird : all_sprites(0 to 1)  := (
		(32, to_unsigned(195, 10), to_unsigned(50,10), "000000000000", bird0, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(150, 10), to_unsigned(50,10), "000000000000", bird0, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE)
	);
	signal grassplane : all_sprites(0 to 9) := (
		(32, to_unsigned(448, 10), to_unsigned(0,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(64,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(128,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(192,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(256,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(320,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(384,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(448,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(512,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(576,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE)
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
		(64, to_unsigned(60, 10), to_unsigned(50, 10), "000000000000", tree0, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE),
		(64, to_unsigned(60, 10), to_unsigned(200, 10), "000000000000", tree0, "0000000000000000", false, 2, 2, FALSE, FALSE, FALSE),
		(64, to_unsigned(200, 10), to_unsigned(10, 10), "000000000000", tree0, "0000000000000000", false, 2, 2, FALSE, FALSE, FALSE)
	);
	
	signal mousecursor : all_sprites(0 to 1) := (
		(16, to_unsigned(236, 10), to_unsigned(316,10), "000000000000", cursor, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE),
		(16, to_unsigned(150, 10), to_unsigned(50,10), "000000000000", cursor, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE)
	);
	
	signal hearts: all_sprites(0 to 1) := (
		(16, to_unsigned(8, 10), to_unsigned(8,10), "000000000000", heart, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE),
		(16, to_unsigned(8, 10), to_unsigned(32,10), "000000000000", heart, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE)
	);
	
	
	signal sprites_addrs : sprite_addr_array;
	signal sprites_out : sprite_output_array;
	signal grass_idx, bottompipe_idx, bird_idx, tree0_idx, toppipe_idx , mousecursor_idx, heart_idx : integer := -1;
	
	
	signal pipe_points: natural range 0 to 8000 := 0;
	
begin

	spriteengine0 : spriteengine port map (clk, vga_row, vga_col, sprites_addrs, sprites_out);
	textengine0: textengine port map(clk, text_vector, vga_row, vga_col, txt_r, txt_g, txt_b, txt_not_a);
		
--	str2text(text_vector, 0, 0, 1, 1, '1' & red_in, '0' & green_in, '1' & blue_in, " __  __           _      _     _            __  __       _         _");
--	str2text(text_vector, 1, 0, 1, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "|  \/  |         | |    | |   (_)          |  \/  |     | |       | |");
--	str2text(text_vector, 2, 0, 1, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "| \  / | ___   __| | ___| |___ _ _ __ ___  | \  / | ___ | |__  ___| |_ ___ _ __");
--	str2text(text_vector, 3, 0, 1, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "| |\/| |/ _ \ / _` |/ _ \ / __| | '_ ` _ \ | |\/| |/ _ \| '_ \/ __| __/ _ \ '__|");
--	str2text(text_vector, 4, 0, 1, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "| |  | | (_) | (_| |  __/ \__ \ | | | | | || |  | | (_) | |_) \__ \ ||  __/ |");
--	str2text(text_vector, 5, 0, 1, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "|_|  |_|\___/ \__,_|\___|_|___/_|_| |_| |_||_|  |_|\___/|_.__/|___/\__\___|_|");
	
	str2text(text_vector, 1, 65, 1, 1, "0011", "0100", "1010", "Points " & int2str(pipe_points));
	str2text(text_vector, 2, 0, 1, 2, "0011", "0100", "1010", "1,2");
	str2text(text_vector, 5, 0, 1, 3, "0011", "0100", "1010", "1,3");
	str2text(text_vector, 9, 0, 1, 4, "0011", "0100", "1010", "1,4");
	str2text(text_vector, 14, 0, 1, 5, "0011", "0100", "1010", "1,5");
	str2text(text_vector, 20, 0, 1, 6, "0011", "0100", "1010", "1,6");
	str2text(text_vector, 27, 0, 1, 7, "0011", "0100", "1010", "1,7");
	str2text(text_vector, 34, 0, 1, 8, "0011", "0100", "1010", "1,8");
	str2text(text_vector, 42, 0, 2, 2, "0011", "0100", "1010", "2,2");
	str2text(text_vector, 44, 0, 4, 3, "0011", "0100", "1010", "4,3");
	str2text(text_vector, 47, 0, 2, 3, "0011", "0100", "1010", "2,3");
	str2text(text_vector, 50, 0, 2, 1, "0011", "0100", "1010", "2,1");
	str2text(text_vector, 51, 0, 4, 1, "0011", "0100", "1010", "4,1");
	str2text(text_vector, 52, 0, 8, 1, "0011", "0100", "1010", "8,1");

	
	--Sprites

	grass_idx <= get_active_idx(grassplane, vga_row, vga_col);	
	grassplane(grass_idx).address <= calc_addr_f(grassplane(grass_idx), vga_row, vga_col);
	
	bottompipe_idx <= get_active_idx(bottompipe, vga_row, vga_col);
	bottompipe(bottompipe_idx).address <= calc_addr_f(bottompipe(bottompipe_idx), vga_row, vga_col);
	
	toppipe_idx <= get_active_idx(toppipes, vga_row, vga_col);
	toppipes(toppipe_idx).address <= calc_addr_f(toppipes(toppipe_idx), vga_row, vga_col);
		
	mousecursor_idx <= get_active_idx(mousecursor, vga_row, vga_col);
	mousecursor(mousecursor_idx).address <= calc_addr_f(mousecursor(mousecursor_idx), vga_row, vga_col);
	
	tree0_idx <= get_active_idx(tree0s, vga_row, vga_col);
	tree0s(tree0_idx).address <= calc_addr_f(tree0s(tree0_idx), vga_row, vga_col);
	
	bird_idx <= get_active_idx(bird, vga_row, vga_col);	
	bird(bird_idx).address <= calc_addr_f(bird(bird_idx), vga_row, vga_col);
	
	heart_idx <= get_active_idx(hearts, vga_row, vga_col);	
	hearts(heart_idx).address <= calc_addr_f(hearts(heart_idx), vga_row, vga_col);
	
	
	
	bird(bird_idx).in_range <= return_in_range(bird(bird_idx), vga_row, vga_col) when bird_idx /= -1 else false;
	grassplane(grass_idx).in_range <= return_in_range(grassplane(grass_idx), vga_row, vga_col) when grass_idx /= -1 else false;
	bottompipe(bottompipe_idx).in_range <= return_in_range(bottompipe(bottompipe_idx), vga_row, vga_col) when bottompipe_idx /= -1 else false;
	toppipes(toppipe_idx).in_range <= return_in_range(toppipes(toppipe_idx), vga_row, vga_col) when toppipe_idx /= -1 else false;
	tree0s(tree0_idx).in_range <= return_in_range(tree0s(tree0_idx), vga_row, vga_col) when tree0_idx /= -1 else false;
	mousecursor(mousecursor_idx).in_range <= return_in_range(mousecursor(mousecursor_idx), vga_row, vga_col) when mousecursor_idx /= -1 else false;
	hearts(heart_idx).in_range <= return_in_range(hearts(heart_idx), vga_row, vga_col) when heart_idx /= -1 else false;
	
	

	sprites_addrs(grass) <= grassplane(grass_idx).address;	
	sprites_addrs(crackpipe) <= bottompipe(bottompipe_idx).address;
	sprites_addrs(toppipe) <= toppipes(toppipe_idx).address;
	sprites_addrs(tree0) <= tree0s(tree0_idx).address;
	sprites_addrs(bird0) <= bird(bird_idx).address;
	sprites_addrs(cursor) <= mousecursor(mousecursor_idx).address;
	sprites_addrs(heart) <= hearts(heart_idx).address;
	
	
	bird(bird_idx).colours <= sprites_out(bird0);
	grassplane(grass_idx).colours <= sprites_out(grass);
	tree0s(tree0_idx).colours <= sprites_out(tree0);
	bottompipe(bottompipe_idx).colours <= sprites_out(crackpipe);
	toppipes(toppipe_idx).colours <= sprites_out(toppipe);
	mousecursor(mousecursor_idx).colours <= sprites_out(cursor);
	hearts(heart_idx).colours <= sprites_out(heart);


	
	sprite_r <= unsigned(mousecursor(mousecursor_idx).colours(3 downto 0))				when mousecursor(mousecursor_idx).colours(15 downto 12) /= "1111" and mousecursor(mousecursor_idx).in_range else
				unsigned(bird(bird_idx).colours(3 downto 0))				when bird(bird_idx).colours(15 downto 12) /= "1111" and bird(bird_idx).in_range else
				unsigned(grassplane(grass_idx).colours(3 downto 0))			when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range else
				unsigned(bottompipe(bottompipe_idx).colours(3 downto 0))	when bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" and bottompipe(bottompipe_idx).in_range else
				unsigned(toppipes(toppipe_idx).colours(3 downto 0))			when toppipes(toppipe_idx).colours(15 downto 12) /= "1111" and toppipes(toppipe_idx).in_range else
				unsigned(tree0s(tree0_idx).colours(3 downto 0))				when tree0s(tree0_idx).colours(15 downto 12) /= "1111" and tree0s(tree0_idx).in_range else
				unsigned(hearts(heart_idx).colours(3 downto 0))				when hearts(heart_idx).colours(15 downto 12) /= "1111" and hearts(heart_idx).in_range;
	
	sprite_g <= unsigned(mousecursor(mousecursor_idx).colours(7 downto 4))				when mousecursor(mousecursor_idx).colours(15 downto 12) /= "1111" and mousecursor(mousecursor_idx).in_range else 
				unsigned(bird(bird_idx).colours(7 downto 4))				when bird(bird_idx).colours(15 downto 12) /= "1111" and bird(bird_idx).in_range else
				unsigned(grassplane(grass_idx).colours(7 downto 4))			when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range else
				unsigned(bottompipe(bottompipe_idx).colours(7 downto 4))	when bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" and bottompipe(bottompipe_idx).in_range else
				unsigned(toppipes(toppipe_idx).colours(7 downto 4))			when toppipes(toppipe_idx).colours(15 downto 12) /= "1111" and toppipes(toppipe_idx).in_range else
				unsigned(tree0s(tree0_idx).colours(7 downto 4))				when tree0s(tree0_idx).colours(15 downto 12) /= "1111" and tree0s(tree0_idx).in_range else
				unsigned(hearts(heart_idx).colours(7 downto 4))				when hearts(heart_idx).colours(15 downto 12) /= "1111" and hearts(heart_idx).in_range;
	
	sprite_b <= unsigned(mousecursor(mousecursor_idx).colours(11 downto 8)) 			when mousecursor(mousecursor_idx).colours(15 downto 12) /= "1111" and mousecursor(mousecursor_idx).in_range else
				unsigned(bird(bird_idx).colours(11 downto 8)) 				when bird(bird_idx).colours(15 downto 12) /= "1111" and bird(bird_idx).in_range else
				unsigned(grassplane(grass_idx).colours(11 downto 8))		when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range else
				unsigned(bottompipe(bottompipe_idx).colours(11 downto 8))	when bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" and bottompipe(bottompipe_idx).in_range else
				unsigned(toppipes(toppipe_idx).colours(11 downto 8))		when toppipes(toppipe_idx).colours(15 downto 12) /= "1111" and toppipes(toppipe_idx).in_range else
				unsigned(tree0s(tree0_idx).colours(11 downto 8))			when tree0s(tree0_idx).colours(15 downto 12) /= "1111" and tree0s(tree0_idx).in_range else
				unsigned(hearts(heart_idx).colours(11 downto 8))				when hearts(heart_idx).colours(15 downto 12) /= "1111" and hearts(heart_idx).in_range;

	sprite_z <= "0000" when mousecursor_idx /= -1 and mousecursor(mousecursor_idx).in_range and mousecursor(mousecursor_idx).colours(15 downto 12) /= "1111" else
				"0000" when bird_idx /= -1 and bird(bird_idx).in_range and bird(bird_idx).colours(15 downto 12) /= "1111" else
				"0000" when grass_idx /= -1 and grassplane(grass_idx).in_range and grassplane(grass_idx).colours(15 downto 12) /= "1111" else
				"0000" when bottompipe_idx /= -1 and bottompipe(bottompipe_idx).in_range and bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" else
				"0000" when toppipe_idx /= -1 and toppipes(toppipe_idx).in_range and toppipes(toppipe_idx).colours(15 downto 12) /= "1111" else
				"0000" when tree0_idx /= -1 and tree0s(tree0_idx).in_range and tree0s(tree0_idx).colours(15 downto 12) /= "1111" else
				"0000" when heart_idx /= -1 and hearts(heart_idx).in_range and hearts(heart_idx).colours(15 downto 12) /= "1111" else
				"1111";
		
	
	process(clk)
		variable ticks : integer := 0;
	begin
		if (rising_edge(clk)) then
			ticks := ticks + 1;
--			if (ticks >= 25000000) then
--				-- things to happen every second
--	
--				sec <= sec + 1;
--				ticks := 0;
--			end if;
				--sec <= sec + 1;
				ticks := 0;
			
			if (mouse_col <= 624) then
				mousecursor(0).x0 <= mouse_col;
			end if;
			if (mouse_row <= 464) then
				mousecursor(0).y0 <= mouse_row;
			end if;
			
			if (mouse_lbtn = '1') then
				mouse_btn <= var_len_str("Left Mouse button Pressed", mouse_btn'length);
			elsif (mouse_rbtn = '1') then
				mouse_btn <= var_len_str("Right Mouse button Pressed", mouse_btn'length);
			else
				mouse_btn <= var_len_str("No Mouse button Pressed", mouse_btn'length);
			end if;


			if (txt_not_a = "1111") then
				red_out <= txt_r;
				green_out <= txt_g;
				blue_out <= txt_b;
			elsif (sprite_z = "0000") then
				red_out <= sprite_r;
				green_out <= sprite_g;
				blue_out <= sprite_b;
			else
				red_out <= "0111";
				green_out <= "1100";
				blue_out <= "1100";
			end if;
			
		end if;

	end process;
	
	VSYNC: process(v_sync)
	variable mouse_flag : std_logic := '0';
	variable birdxpos, birdypos : unsigned (9 downto 0);
	variable pipexpos, pipeypos : unsigned (9 downto 0);
	variable t_flag: std_logic := '0';
	variable bird_pos : unsigned (9 downto 0);
	variable toppipe_pos : unsigned (11 downto 0);
	variable collision_flag : std_logic := '0';
	variable frame : natural range 0 to 60 := 0;
	-- total number of pixels to shift bird up by per mouse click
	constant h_boost : natural range 0 to 256 := 60;
	-- apply this much h_boost per frame to get it done in 8 frames
	constant h_boost_per_frame : natural range 0 to 8 := h_boost / 8; 
	-- If > 0 the mouse bird should be boosted this frame. Decremented by 1 each frame a hboost is applied
	variable apply_h_boost : natural range 0 to 8 := 0; 
	begin
		if (v_sync = '1') then
			
			frame := frame + 1;
			if (frame > 59) then
				frame := 0;
			end if;

			for i in 0 to (bottompipe'length - 1) loop

				if (collision_flag = '0') then
					if (bottompipe(i).x0 <= 640) then
						bottompipe(i).underflow <= false;
						bottompipe(i).x0 <= bottompipe(i).x0 - 2;
						if (bottompipe(i).x0 < 1) then
							bottompipe(i).underflow <= true;
						end if;
					elsif (bottompipe(i).x0 >= 959) then
						bottompipe(i).x0 <= bottompipe(i).x0 - 2;
					elsif (bottompipe(i).x0 < 959) then
						bottompipe(i).underflow <= false;
						bottompipe(i).x0 <= to_unsigned(640, 10); 
						-- this pipe is being recycled, it should earn points again
						bottompipe(i).passed_pipe <= false;
					end if;

					
					if (toppipes(i).x0 <= 640) then
						toppipes(i).underflow <= false;
						toppipes(i).x0 <= toppipes(i).x0 - 2;
						if (toppipes(i).x0 < 1) then
							toppipes(i).underflow <= true;
						end if;
					elsif (toppipes(i).x0 >= 959) then
						toppipes(i).x0 <= toppipes(i).x0 - 2;
					elsif (toppipes(i).x0 < 959) then
						toppipes(i).underflow <= false;
						toppipes(i).x0 <= to_unsigned(640, 10); 
						-- this pipe is being recycled, it should earn points again
						toppipes(i).passed_pipe <= false;
					end if;
				
						
						-- Do collision and point detection here
						if (((bird(0).x0 + 2 >= toppipes(i).x0) and ((bird(0).x0 + bird(0).size - 1) <= toppipes(i).x0 + toppipes(i).size - 1)) and 
							(((bird(0).y0 + 4 >= toppipes(i).y0) and (bird(0).y0 + 4 <= toppipes(i).y0 + toppipes(i).size*toppipes(i).scaling_factor_y + 1)) or
							((bird(0).y0 + bird(0).size - 6 >= bottompipe(i).y0) and (bird(0).y0 + bird(0).size - 8 <= bottompipe(i).y0 + bottompipe(1).size*bottompipe(i).scaling_factor_y - 1)))) then
							collision_flag := '1';
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
								end if;
							end if;
						end if;
						
				-- if the user has just passed through this pipe, give them a point
					if (bottompipe(i).passed_pipe = false and bird(0).x0 > bottompipe(i).x0 + bottompipe(i).size * bottompipe(i).scaling_factor_x) then
						bottompipe(i).passed_pipe <= true;
						pipe_points <= pipe_points + 1; 
					end if;
				end if;
			end loop;
		
			-- Boost the bird up on mouse click, otherwise make it fall 
			-- Don't let the bird flap if we have detected a collision (remember we are drawing the next frame here)
			if (collision_flag = '0') then
				if (apply_h_boost > 0) then
					bird(0).y0 <= bird(0).y0 - h_boost_per_frame;
					apply_h_boost := apply_h_boost - 1;
				else
					-- lower bird by 3 pixels (make it 'fall' 3 pixels)
					bird(0).y0 <= bird(0).y0 + 3;
				end if;
			end if;
			
			-- Mouse input (make the bird flap)
			-- Don't let the bird flap if we have detected a collision (remember we are drawing the next frame here)
			if (collision_flag = '0') then
				if (mouse_lbtn = '1' and mouse_flag = '0') then
					mouse_flag := '1';
					apply_h_boost := 8;
				end if;
			end if;
			
			if (mouse_lbtn = '0' and mouse_flag = '1') then
				mouse_flag := '0';
			end if;
		end if; 
	end process;
end architecture;
