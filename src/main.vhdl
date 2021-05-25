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
	component randomNumGen is
		port(
			clk							: 		in std_logic;
			seed          				:   	in natural range 1 to 1023;
			randNum  					: 		out std_logic_vector(3 downto 0)
		);
	end component randomNumGen;
	
	signal text_vector: textengine_vector := (others => init_textengine_row);
	
	signal tvec_mode_title: textengine_vector := (others => init_textengine_row);
	signal tvec_mode_game: textengine_vector := (others => init_textengine_row);
	signal tvec_mode_over: textengine_vector := (others => init_textengine_row);
	signal tvec_mode_train: textengine_vector := (others=> init_textengine_row);
	
	
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
	signal initial_lclick : std_logic := '0';
	signal health_flag : std_logic := '0';
	
	
	-- (sprite size, y0, x0, addr, sprite, colour, in_range, scale_x, scale_y, visible, underflow, passed_pipe)  

	signal bird : all_sprites(0 to 1)  := (
		(32, to_unsigned(195, 10), to_unsigned(50,10), "000000000000", bird0, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(150, 10), to_unsigned(50,10), "000000000000", bird0, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE)
	);
	signal grassplane : all_sprites(0 to 10) := (
		(32, to_unsigned(448, 10), to_unsigned(0,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(64,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(128,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(192,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(256,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(320,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(384,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(448,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(512,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(576,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE),
		(32, to_unsigned(448, 10), to_unsigned(640,10), "000000000000", grass, "0000000000000000", false, 2, 1, TRUE, FALSE, FALSE)
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
		(64, to_unsigned(420, 10), to_unsigned(80, 10), "000000000000", tree0, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE),
		(64, to_unsigned(380, 10), to_unsigned(200, 10), "000000000000", tree0, "0000000000000000", false, 1, 2, FALSE, FALSE, FALSE),
		(64, to_unsigned(380, 10), to_unsigned(400, 10), "000000000000", tree0, "0000000000000000", false, 2, 2, FALSE, FALSE, FALSE)
	);
	
	signal mousecursor : all_sprites(0 to 1) := (
		(16, to_unsigned(236, 10), to_unsigned(316,10), "000000000000", cursor, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE),
		(16, to_unsigned(150, 10), to_unsigned(50,10), "000000000000", cursor, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE)
	);
	
	signal hearts: all_sprites(0 to 2) := (
		(16, to_unsigned(8, 10), to_unsigned(8,10), "000000000000", heart, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE),
		(16, to_unsigned(8, 10), to_unsigned(32,10), "000000000000", heart, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE),
		(16, to_unsigned(8, 10), to_unsigned(56,10), "000000000000", heart, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE)
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
	
	
	signal game_mode : integer range 0 to 7 := MODE_TITLE;
	signal seed : natural range 1 to 1023;
	signal randNum : std_logic_vector(3 downto 0);
	-- ========================
	
	-- Player Stats
	
	signal health: natural range 0 to 3 := 3;
	signal pipe_points: natural range 0 to 8000 := 0;
	
	
	-- ========================
begin

	spriteengine0 : spriteengine port map (clk, vga_row, vga_col, sprites_addrs, sprites_out);
	textengine0: textengine port map(clk, text_vector, vga_row, vga_col, txt_r, txt_g, txt_b, txt_not_a);
	randomNumGen0 : randomNumGen port map(clk, seed, randNum);
		
--	str2text(text_vector, 0, 0, 1, 1, '1' & red_in, '0' & green_in, '1' & blue_in, " __  __           _      _     _            __  __       _         _");
--	str2text(text_vector, 1, 0, 1, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "|  \/  |         | |    | |   (_)          |  \/  |     | |       | |");
--	str2text(text_vector, 2, 0, 1, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "| \  / | ___   __| | ___| |___ _ _ __ ___  | \  / | ___ | |__  ___| |_ ___ _ __");
--	str2text(text_vector, 3, 0, 1, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "| |\/| |/ _ \ / _` |/ _ \ / __| | '_ ` _ \ | |\/| |/ _ \| '_ \/ __| __/ _ \ '__|");
--	str2text(text_vector, 4, 0, 1, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "| |  | | (_) | (_| |  __/ \__ \ | | | | | || |  | | (_) | |_) \__ \ ||  __/ |");
--	str2text(text_vector, 5, 0, 1, 1, '1' & red_in, '0' & green_in, '1' & blue_in, "|_|  |_|\___/ \__,_|\___|_|___/_|_| |_| |_||_|  |_|\___/|_.__/|___/\__\___|_|");
	
	-- Title Screen Text Vector 
	str2text(tvec_mode_title, 1, 2, 8, 8, "0011", "0100", "1010", "Flappy");
	str2text(tvec_mode_title, 9, 3, 8, 8, "0011", "0100", "1010", "Bird");
	str2text(tvec_mode_title, 40, 8, 2, 2, "0011", "0100", "1010", "Created and Developed by");
	str2text(tvec_mode_title, 42, 10, 2, 2, "0011", "0100", "1010", "The Modelsim Mobsters");
	str2text(tvec_mode_title, 50, 16, 1, 1, "0011", "0100", "1010", "Based on the concept of https://flappybird.io/");
	
	
	-- =================
	
	-- Game Mode Screen Text Vector
	
	str2text(tvec_mode_game, 4, 2, 1, 1, "0011", "0100", "1010", "Points " & int2str(pipe_points));
	
	-- =================
	
	-- Game Over Screen Text Vector
	
	str2text(tvec_mode_over, 9, 3, 8, 8, "0011", "0100", "1010", "Game");
	str2text(tvec_mode_over, 17, 3, 8, 8, "0011", "0100", "1010", "Over");
	str2text(tvec_mode_over, 30, 4, 4, 4, "0001", "0000", "0001", "You've Scored");
	str2text(tvec_mode_over, 35, 4, 4, 4, "0001", "0000", "0001", int2str(pipe_points) & "Points !");
	
	--==================

	-- Training Mode Text Vector
	str2text(tvec_mode_train, 2, 3, 4, 4, "0011", "0100", "1010", "Training Mode");

	--==================

	
	-- Set the text vector depending on game mode
	

	
	
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


	
	sprite_r <= unsigned(mousecursor(mousecursor_idx).colours(3 downto 0))	when mousecursor(mousecursor_idx).colours(15 downto 12) /= "1111" and mousecursor(mousecursor_idx).in_range else
				unsigned(bird(bird_idx).colours(3 downto 0))				when bird(bird_idx).colours(15 downto 12) /= "1111" and bird(bird_idx).in_range else
				unsigned(hearts(heart_idx).colours(3 downto 0))				when hearts(heart_idx).colours(15 downto 12) /= "1111" and hearts(heart_idx).in_range else
				unsigned(grassplane(grass_idx).colours(3 downto 0))			when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range else
				unsigned(bottompipe(bottompipe_idx).colours(3 downto 0))	when bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" and bottompipe(bottompipe_idx).in_range else
				unsigned(toppipes(toppipe_idx).colours(3 downto 0))			when toppipes(toppipe_idx).colours(15 downto 12) /= "1111" and toppipes(toppipe_idx).in_range else
				unsigned(tree0s(tree0_idx).colours(3 downto 0))				when tree0s(tree0_idx).colours(15 downto 12) /= "1111" and tree0s(tree0_idx).in_range else
				"1111";
				
	
	sprite_g <= unsigned(mousecursor(mousecursor_idx).colours(7 downto 4))	when mousecursor(mousecursor_idx).colours(15 downto 12) /= "1111" and mousecursor(mousecursor_idx).in_range else 
				unsigned(bird(bird_idx).colours(7 downto 4))				when bird(bird_idx).colours(15 downto 12) /= "1111" and bird(bird_idx).in_range else
				unsigned(hearts(heart_idx).colours(7 downto 4))				when hearts(heart_idx).colours(15 downto 12) /= "1111" and hearts(heart_idx).in_range else
				unsigned(grassplane(grass_idx).colours(7 downto 4))			when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range else				
				unsigned(bottompipe(bottompipe_idx).colours(7 downto 4))	when bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" and bottompipe(bottompipe_idx).in_range else
				unsigned(toppipes(toppipe_idx).colours(7 downto 4))			when toppipes(toppipe_idx).colours(15 downto 12) /= "1111" and toppipes(toppipe_idx).in_range else
				unsigned(tree0s(tree0_idx).colours(7 downto 4))				when tree0s(tree0_idx).colours(15 downto 12) /= "1111" and tree0s(tree0_idx).in_range else
				"1111";
				
				
	
	sprite_b <= unsigned(mousecursor(mousecursor_idx).colours(11 downto 8)) when mousecursor(mousecursor_idx).colours(15 downto 12) /= "1111" and mousecursor(mousecursor_idx).in_range else
				unsigned(bird(bird_idx).colours(11 downto 8)) 				when bird(bird_idx).colours(15 downto 12) /= "1111" and bird(bird_idx).in_range else
				unsigned(hearts(heart_idx).colours(11 downto 8))			when hearts(heart_idx).colours(15 downto 12) /= "1111" and hearts(heart_idx).in_range else
				unsigned(grassplane(grass_idx).colours(11 downto 8))		when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range else
				unsigned(bottompipe(bottompipe_idx).colours(11 downto 8))	when bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" and bottompipe(bottompipe_idx).in_range else
				unsigned(toppipes(toppipe_idx).colours(11 downto 8))		when toppipes(toppipe_idx).colours(15 downto 12) /= "1111" and toppipes(toppipe_idx).in_range else
				unsigned(tree0s(tree0_idx).colours(11 downto 8))			when tree0s(tree0_idx).colours(15 downto 12) /= "1111" and tree0s(tree0_idx).in_range else
				"1111";
				

	sprite_z <= "0000" when mousecursor_idx /= -1 and mousecursor(mousecursor_idx).in_range and mousecursor(mousecursor_idx).colours(15 downto 12) /= "1111" else
				"0000" when bird_idx /= -1 and bird(bird_idx).in_range and bird(bird_idx).colours(15 downto 12) /= "1111" else
				"0000" when heart_idx /= -1 and hearts(heart_idx).in_range and hearts(heart_idx).colours(15 downto 12) /= "1111" else
				"0000" when grass_idx /= -1 and grassplane(grass_idx).in_range and grassplane(grass_idx).colours(15 downto 12) /= "1111" else
				"0000" when bottompipe_idx /= -1 and bottompipe(bottompipe_idx).in_range and bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" else
				"0000" when toppipe_idx /= -1 and toppipes(toppipe_idx).in_range and toppipes(toppipe_idx).colours(15 downto 12) /= "1111" else
				"0000" when tree0_idx /= -1 and tree0s(tree0_idx).in_range and tree0s(tree0_idx).colours(15 downto 12) /= "1111" else
				"1111";
	
	red_out		<=	txt_r when txt_not_a = "1111" else sprite_r when sprite_z = "0000" else "0111"; -- 0111
	green_out	<=	txt_g when txt_not_a = "1111" else sprite_g when sprite_z = "0000" else "1100"; -- 1100
	blue_out	<= 	txt_b when txt_not_a = "1111" else sprite_b when sprite_z = "0000" else "1100"; -- 1100
	
	
	process(clk)
		variable ticks : integer := 0;
		variable seedTicks : natural range 1 to 1023;
		variable seedDone : boolean := false;
	begin
		if (rising_edge(clk)) then
			ticks := ticks + 1;
			if (ticks >= 25000000) then
				-- things to happen every second
				
				sec <= sec + 1;
				ticks := 0;
			end if;
			
			if(initial_lclick = '0' and seedDone = false and (game_mode = MODE_GAME or game_mode = MODE_TRAIN)) then
				seedTicks := seedTicks + 1;
			end if;
			
			if (mouse_col <= 624) then
				mousecursor(0).x0 <= mouse_col;
			end if;
			if (mouse_row <= 464) then
				mousecursor(0).y0 <= mouse_row;
			end if;
			
			if (mouse_lbtn = '1') then
				mouse_btn <= var_len_str("Left Mouse button Pressed", mouse_btn'length);
				if (game_mode = GAME_MODE) then
					initial_lclick <= '1';
					seedDone := True;
					seed <= seedTicks;					
				end if;
			elsif (mouse_rbtn = '1') then
				mouse_btn <= var_len_str("Right Mouse button Pressed", mouse_btn'length);
			else
				mouse_btn <= var_len_str("No Mouse button Pressed", mouse_btn'length);
			end if;
		
			if (game_mode = MODE_TITLE) then
				text_vector <= tvec_mode_title;
			elsif (game_mode = MODE_GAME) then
				text_vector <= tvec_mode_game;
			elsif (game_mode = MODE_OVER) then
				text_vector <= tvec_mode_over;
			elsif (game_mode = MODE_TRAIN) then
				text_vector <= tvec_mode_train;
			end if;
	
			
		end if;

	end process;
	
	Pipe: process(v_sync)
	variable mouse_flag : std_logic := '0';
	variable birdxpos, birdypos : unsigned (9 downto 0);
	variable pipexpos, pipeypos : unsigned (9 downto 0);
	variable t_flag: std_logic := '0';
	variable bird_pos : unsigned (9 downto 0);
	variable toppipe_pos : unsigned (11 downto 0);
	variable collision_flag : std_logic := '0';
	variable enable_collision : std_logic := '1';
	variable frame : natural range 0 to 60 := 0;
	variable ticks : natural range 0 to 255 := 0;
	variable qtr_seconds : natural range 0 to 3 := 0;	
	-- total number of pixels to shift bird up by per mouse click
	constant h_boost : natural range 0 to 256 := 60;
	-- apply this much h_boost per frame to get it done in 8 frames
	constant h_boost_per_frame : natural range 0 to 8 := h_boost / 8; 
	-- If > 0 the mouse bird should be boosted this frame. Decremented by 1 each frame a hboost is applied
	variable apply_h_boost : natural range 0 to 8 := 0; 
	begin
		if (rising_edge(v_sync)) then

		
			if (health_flag = '1' and game_mode = MODE_GAME) then
				ticks := ticks + 1;
				if (ticks = 5) then
					health <= health - 1;
					hearts(health - 1).visible <= FALSE;
					bird(0).visible <= FALSE;
				elsif (ticks = 10) then
					bird(0).visible <= TRUE;
				elsif (ticks = 15) then
					bird(0).visible <= FALSE;
				elsif (ticks = 20) then
					bird(0).visible <= TRUE;
				elsif (ticks = 25) then
					bird(0).visible <= FALSE;
				elsif (ticks = 30) then
					bird(0).visible <= TRUE;
				elsif (ticks = 35) then
					bird(0).visible <= FALSE;
				elsif (ticks = 40) then
					bird(0).visible <= TRUE;
				elsif (ticks = 45) then 
					bird(0).visible <= FALSE;	
				elsif (ticks = 50) then
					bird(0).visible <= TRUE;
				elsif (ticks = 55) then
					bird(0).visible <= FALSE;
				elsif (ticks = 60) then
					bird(0).visible <= TRUE;
				elsif (ticks = 65) then
					bird(0).visible <= FALSE;
				elsif (ticks = 70) then
					bird(0).visible <= TRUE;
				elsif (ticks = 75) then
					bird(0).visible <= FALSE;
				elsif (ticks = 80) then
					bird(0).visible <= TRUE;
				elsif (ticks = 85) then
					bird(0).visible <= FALSE;
				elsif (ticks = 90) then
					bird(0).visible <= TRUE;
				elsif (ticks = 95) then
					bird(0).visible <= FALSE;
				elsif (ticks = 100) then
					bird(0).visible <= TRUE;
				elsif (ticks = 105) then 
					bird(0).visible <= FALSE;	
				elsif (ticks = 110) then
					bird(0).visible <= TRUE;
				elsif (ticks = 115) then
					bird(0).visible <= FALSE;
				elsif (ticks = 120) then
					bird(0).visible <= TRUE;
				elsif (ticks = 125) then
					bird(0).visible <= FALSE;
				elsif (ticks = 130) then
					bird(0).visible <= TRUE;
				elsif (ticks = 135) then
					bird(0).visible <= FALSE;
				elsif (ticks = 140) then
					bird(0).visible <= TRUE;
				elsif (ticks = 145) then
					bird(0).visible <= FALSE;
				elsif (ticks = 150) then
					bird(0).visible <= TRUE;
				elsif (ticks = 155) then
					bird(0).visible <= FALSE;
				elsif (ticks = 160) then
					bird(0).visible <= TRUE;
				elsif (ticks = 165) then 
					bird(0).visible <= FALSE;	
				elsif (ticks = 170) then
					bird(0).visible <= TRUE;
				elsif (ticks = 175) then
					bird(0).visible <= FALSE;
				elsif (ticks = 180) then
					bird(0).visible <= TRUE;
					health_flag <= '0';
					enable_collision := '1';
					ticks := 0;
				end if;
			end if;


			if (pb_0 = '1') then
				if (game_mode = MODE_TITLE) then
					game_mode <= MODE_GAME;
					hearts(0).visible <= true;
					hearts(1).visible <= true;
					hearts(2).visible <= true;
				end if;
			end if;			
			
			if (pb_1 = '1') then
				if (game_mode = MODE_TITLE) then
					game_mode <=MODE_TRAIN;
					hearts(0).visible <= FALSE;
					hearts(1).visible <= FALSE;
					hearts(2).visible <= FALSE;
				end if;	
			end if;

			frame := frame + 1;
			if (frame > 59) then
				frame := 0;
			end if;
			
			-- Pipe Collision Detection, and Pipe Movement
	
			if (health = 0) then
				game_mode <= MODE_OVER;
			end if;

			for i in 0 to (bottompipe'length - 1) loop
			
				if (game_mode = MODE_TITLE) then
					bottompipe(i).visible <= FALSE;
					toppipes(i).visible <= FALSE;
				else
					bottompipe(i).visible <= TRUE;
					toppipes(i).visible <= TRUE;
				end if;		
			
				-- if the user has just passed through this pipe, give them a point			
				if (enable_collision = '1' and bottompipe(i).passed_pipe = false and bird(0).x0 > bottompipe(i).x0 + bottompipe(i).size * bottompipe(i).scaling_factor_x) then
					bottompipe(i).passed_pipe <= true;
					pipe_points <= pipe_points + 1; 
				end if;		
		
				if (initial_lclick = '1') then
					if (collision_flag = '0' and (game_mode = MODE_GAME or game_mode = MODE_TRAIN)) then
						if (bottompipe(i).x0 <= 640) then
							bottompipe(i).underflow <= false;
							bottompipe(i).x0 <= bottompipe(i).x0 - 2;
							if (bottompipe(i).x0 < 1) then
								bottompipe(i).underflow <= true;
							end if;
						elsif (bottompipe(i).x0 >= 1023 - bottompipe(i).size * bottompipe(i).scaling_factor_x) then
							bottompipe(i).x0 <= bottompipe(i).x0 - 2;
						elsif (bottompipe(i).x0 < 1023 - bottompipe(i).size * bottompipe(i).scaling_factor_x) then
							bottompipe(i).underflow <= false;
							bottompipe(i).x0 <= to_unsigned(640, 10);
							-- the pipe is being recycled, it should gives points again
							bottompipe(i).passed_pipe <= false;
						end if;
							
						if (toppipes(i).x0 <= 640) then
							toppipes(i).underflow <= false;
							toppipes(i).x0 <= toppipes(i).x0 - 2;
							if (toppipes(i).x0 < 1) then
								toppipes(i).underflow <= true;
							end if;
						elsif (toppipes(i).x0 >= 1023 - toppipes(i).size * toppipes(i).scaling_factor_x) then
							toppipes(i).x0 <= toppipes(i).x0 - 2;
						elsif (toppipes(i).x0 < 1023 - toppipes(i).size * toppipes(i).scaling_factor_x) then
							toppipes(i).underflow <= false;
							toppipes(i).x0 <= to_unsigned(640, 10); 
						end if;
					
							if (bird(0).visible = true and enable_collision = '1') then
								-- Do collision and point detection here
								if (((bird(0).x0 + 2 >= toppipes(i).x0) and ((bird(0).x0 + bird(0).size - 1) <= toppipes(i).x0 + toppipes(i).size - 1)) and 
									(((bird(0).y0 + 4 >= toppipes(i).y0) and (bird(0).y0 + 4 <= toppipes(i).y0 + toppipes(i).size*toppipes(i).scaling_factor_y + 1)) or
									((bird(0).y0 + bird(0).size - 6 >= bottompipe(i).y0) and (bird(0).y0 + bird(0).size - 8 <= bottompipe(i).y0 + bottompipe(1).size*bottompipe(i).scaling_factor_y - 1)))) then
									health_flag <= '1';
									enable_collision := '0';
									if (health - 1 = 0 and game_mode = MODE_GAME) then
										collision_flag := '1';
									end if;
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
											health_flag <= '1';
											enable_collision := '0';
											if (health - 1 = 0 and game_mode = MODE_GAME) then
												collision_flag := '1';
											end if;
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
											health_flag <= '1';
											enable_collision := '0';
											if (health - 1 = 0 and game_mode = MODE_GAME) then
												collision_flag := '1';
											end if;
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
											health_flag <= '1';
											enable_collision := '0';
											if (health - 1 = 0 and game_mode = MODE_GAME) then
												collision_flag := '1';
											end if;
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
											health_flag <= '1';
											enable_collision := '0';
											if (health - 1 = 0 and game_mode = MODE_GAME) then
												collision_flag := '1';
											end if;
										end if;
									end if;
								end if;
							end if;
					end if;
				end if;	
			end loop;
		
			-- Boost the bird up on mouse click, otherwise make it fall 
			-- Don't let the bird flap if we have detected a collision (remember we are drawing the next frame here)
--			if (collision_flag = '0' and initial_lclick = '1') then
--				if (apply_h_boost > 0) then
--					if (bird(0).y0 - h_boost_per_frame >= 0 and bird(0).y0 - h_boost_per_frame < 480) then
--						bird(0).y0 <= bird(0).y0 - h_boost_per_frame;
--						apply_h_boost := apply_h_boost - 1;
--					end if;
--				else
--					-- lower bird by 3 pixels (make it 'fall' 3 pixels)
--					if (bird(0).y0 + 3 <= 452)	then
--						bird(0).y0 <= bird(0).y0 + 3;
--					end if;
--				end if;
--			end if;
			if (collision_flag = '0' and initial_lclick = '1') then
				if (apply_h_boost > 0 and bird(0).y0 - h_boost_per_frame >= 0 and bird(0).y0 - h_boost_per_frame < 480) then
					bird(0).y0 <= bird(0).y0 - h_boost_per_frame;
					apply_h_boost := apply_h_boost - 1;
				else
					-- lower bird by 3 pixels (make it 'fall' 3 pixels)
					if (bird(0).y0 + 3 <= 452)	then
						bird(0).y0 <= bird(0).y0 + 3;
					else
						hearts(0).visible <= false;
						hearts(1).visible <= false;
						hearts(2).visible <= false;
						game_mode <= MODE_OVER;
						collision_flag := '1';
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
					if (tree0s(i).x0 <= 640) then
							tree0s(i).underflow <= false;
							tree0s(i).x0 <= tree0s(i).x0 - 2;
							if (tree0s(i).x0 < 1) then
								tree0s(i).underflow <= true;
							end if;
						elsif (tree0s(i).x0 >= 1023 - tree0s(i).size * tree0s(i).scaling_factor_x) then
							tree0s(i).x0 <= tree0s(i).x0 - 2;
						elsif (tree0s(i).x0 < 1023 - tree0s(i).size * tree0s(i).scaling_factor_x) then
							tree0s(i).underflow <= false;
							tree0s(i).x0 <= to_unsigned(640, 10); 
						end if;
				end loop;
				
				for i in 0 to (grassplane'length - 1) loop
					if (grassplane(i).x0 <= 640) then
							grassplane(i).underflow <= false;
							grassplane(i).x0 <= grassplane(i).x0 - 2;
							if (grassplane(i).x0 < 1) then
								grassplane(i).underflow <= true;
							end if;
						elsif (grassplane(i).x0 >= 1023 - grassplane(i).size * grassplane(i).scaling_factor_x) then
							grassplane(i).x0 <= grassplane(i).x0 - 2;
						elsif (grassplane(i).x0 < 1023 - grassplane(i).size * grassplane(i).scaling_factor_x) then
							grassplane(i).underflow <= false;
							grassplane(i).x0 <= to_unsigned(640, 10);
						end if;
				end loop;
			end if;
			
			if (game_mode = MODE_OVER) then
				if (bird(0).y0 + 5 <= 672) then
					bird(0).y0 <= bird(0).y0 + 5;
				end if;
				collision_flag := '0';
			end if;
			

		end if; 
	end process;
	
end architecture;
