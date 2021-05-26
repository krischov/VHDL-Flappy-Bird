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

	component randomNumGen is
		port(
			clk							: 		in std_logic;
			seed          				:   	in natural range 1 to 1023;
			randNum  					: 		out std_logic_vector(3 downto 0)
		);
	end component randomNumGen;

	-- signals -- 

	
	signal text_vector: textengine_vector := (others => init_textengine_row);
	
	signal tvec_mode_title: textengine_vector := (others => init_textengine_row);
	signal tvec_mode_game: textengine_vector := (others => init_textengine_row);
	signal tvec_mode_over: textengine_vector := (others => init_textengine_row);
	signal tvec_mode_train: textengine_vector := (others=> init_textengine_row);
	signal hide_click2start_text: boolean := false;

	
	
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
		(64, to_unsigned(288, 10), to_unsigned(128, 10), "000000000000", crackpipe, "0000000000000000", false, 1, 3, TRUE, FALSE, FALSE),
		(64, to_unsigned(288, 10), to_unsigned(500, 10), "000000000000", crackpipe, "0000000000000000", false, 1, 3, TRUE, FALSE, FALSE)
	);
	
	signal toppipes : all_sprites(0 to 1) := (
		(64, to_unsigned(0, 10), to_unsigned(128, 10), "000000000000", toppipe, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE),
		(64, to_unsigned(0, 10), to_unsigned(500, 10), "000000000000", toppipe, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE)
	);

	
	signal tree0s : all_sprites(0 to 2) := (
		(64, to_unsigned(416, 10), to_unsigned(144, 10), "000000000000", tree0, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE),
		(64, to_unsigned(380, 10), to_unsigned(272, 10), "000000000000", tree0, "0000000000000000", false, 1, 2, FALSE, FALSE, FALSE),
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
	
	signal coins: all_sprites(0 to 1) := (
		(16, to_unsigned(335, 10), to_unsigned(250, 10), "000000000000", coin, "0000000000000000", false, 1, 1, FALSE, FALSE, FALSE),
		(16, to_unsigned(335, 10), to_unsigned(280, 10), "000000000000", coin, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE)
	);


	signal cloud0s : all_sprites(0 to 2) := (
		(32, to_unsigned(150, 10), to_unsigned(80, 10), "000000000000", cloud0, "0000000000000000", false, 4, 2, TRUE, FALSE, FALSE),
		(32, to_unsigned(220, 10), to_unsigned(200, 10), "000000000000", cloud0, "0000000000000000", false, 4, 2, TRUE, FALSE, FALSE),
		(32, to_unsigned(300, 10), to_unsigned(60, 10), "000000000000", cloud0, "0000000000000000", false, 4, 2, TRUE, FALSE, FALSE)
	);
	
	signal tree2s : all_sprites(0 to 2) := (
		(64, to_unsigned(416, 10), to_unsigned(80, 10), "000000000000", tree2, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE),
		(64, to_unsigned(416, 10), to_unsigned(208, 10), "000000000000", tree2, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE),
		(64, to_unsigned(416, 10), to_unsigned(336, 10), "000000000000", tree2, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE)
	);
	
	
	
	-- Sprite Indexes
	
	signal sprites_addrs : sprite_addr_array := (others => "000000000000");
	signal sprites_out : sprite_output_array := (others => "0000000000000000");
	signal grass_idx, bottompipe_idx, bird_idx, tree0_idx, toppipe_idx , mousecursor_idx, 
				heart_idx, coin_idx, cloud0_idx, tree_idx, tree2_idx: integer := -1;
	
	-- ========================
	
	-- Game mode, and associated constants
	
	constant MODE_TITLE : integer range 0 to 7 := 0;
	constant MODE_GAME : integer range 0 to 7 := 1;
	constant MODE_TRAIN : integer range 0 to 7 := 2;
	constant MODE_OVER : integer range 0 to 7 := 4;
	
	
	signal game_mode : integer range 0 to 7 := MODE_TITLE;
	
	signal seed : natural range 1 to 1023;
	signal randNum : std_logic_vector(3 downto 0);
	signal storedRandNum : std_logic_vector(3 downto 0) := "1111";
	-- ========================
	
	-- Player Stats
	
	signal health: natural range 0 to 3 := 3;
	signal pipe_points: natural range 0 to 8000 := 0;
	
	
	-- ========================
begin

	spriteengine0 : spriteengine port map (clk, vga_row, vga_col, sprites_addrs, sprites_out);
	textengine0: textengine port map(clk, text_vector, vga_row, vga_col, txt_r, txt_g, txt_b, txt_not_a);
	randomNumGen0 : randomNumGen port map(clk, seed, randNum);
		
	
	-- Title Screen Text Vector 
	str2text(tvec_mode_title, 1, 2, 8, 8, "0011", "0100", "1010", "Flappy");
	str2text(tvec_mode_title, 9, 3, 8, 8, "0011", "0100", "1010", "Bird");
	str2text(tvec_mode_title, 40, 8, 2, 2, "0011", "0100", "1010", "Created and Developed by");
	str2text(tvec_mode_title, 42, 10, 2, 2, "0011", "0100", "1010", "The Modelsim Mobsters");
	str2text(tvec_mode_title, 44, 23, 1, 1, "0011", "0100", "1010", "Based on the concept of flappybird.io");
	
	
	-- =================
	
	-- Game Mode Screen Text Vector
	str2text(tvec_mode_game, 4, 1, 1, 1, "0011", "0100", "1010", "Points " & int2str(pipe_points));
	str2text(tvec_mode_game, 6, 1, 2, 3, "0011", "0011", "0111", "Ready? Press the mouse to get started!", hide_click2start_text);

	-- Training Mode Text Vector
	str2text(tvec_mode_train, 0, 0, 4, 4, "1111", "0000", "0000", "Training Mode");
	str2text(tvec_mode_train, 5, 1, 1, 1, "0011", "0100", "1010", "Successfully Passed Pipes " & int2str(pipe_points));
	str2text(tvec_mode_train, 8, 1, 2, 3, "0011", "0011", "0111", "Ready? Press the mouse to get started!", hide_click2start_text);

	-- =================
	
	-- Game Over Screen Text Vector
	
	str2text(tvec_mode_over, 9, 3, 8, 8, "0011", "0100", "1010", "Game");
	str2text(tvec_mode_over, 17, 3, 8, 8, "0011", "0100", "1010", "Over");
	
	
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
	
	coin_idx <= get_active_idx(coins, vga_row, vga_col);
	coins(coin_idx).address <= calc_addr_f(coins(coin_idx), vga_row, vga_col);
	
	
	cloud0_idx <= get_active_idx(cloud0s, vga_row, vga_col);
	cloud0s(cloud0_idx).address <= calc_addr_f(cloud0s(cloud0_idx), vga_row, vga_col);
	
	tree2_idx <= get_active_idx(tree2s, vga_row, vga_col);
	tree2s(tree2_idx).address <= calc_addr_f(tree2s(tree2_idx), vga_row, vga_col);
	
	
	
	
	bird(bird_idx).in_range <= return_in_range(bird(bird_idx), vga_row, vga_col) when bird_idx /= -1 else false;
	grassplane(grass_idx).in_range <= return_in_range(grassplane(grass_idx), vga_row, vga_col) when grass_idx /= -1 else false;
	bottompipe(bottompipe_idx).in_range <= return_in_range(bottompipe(bottompipe_idx), vga_row, vga_col) when bottompipe_idx /= -1 else false;
	toppipes(toppipe_idx).in_range <= return_in_range(toppipes(toppipe_idx), vga_row, vga_col) when toppipe_idx /= -1 else false;
	tree0s(tree0_idx).in_range <= return_in_range(tree0s(tree0_idx), vga_row, vga_col) when tree0_idx /= -1 else false;
	mousecursor(mousecursor_idx).in_range <= return_in_range(mousecursor(mousecursor_idx), vga_row, vga_col) when mousecursor_idx /= -1 else false;
	hearts(heart_idx).in_range <= return_in_range(hearts(heart_idx), vga_row, vga_col) when heart_idx /= -1 else false;
	coins(coin_idx).in_range <= return_in_range(coins(coin_idx), vga_row, vga_col) when coin_idx /= -1 else false;
	cloud0s(cloud0_idx).in_range <= return_in_range(cloud0s(cloud0_idx), vga_row, vga_col) when cloud0_idx /= -1 else false;
	tree2s(tree2_idx).in_range <= return_in_range(tree2s(tree2_idx), vga_row, vga_col) when tree2_idx /= -1 else false;
	

	sprites_addrs(grass) <= grassplane(grass_idx).address;	
	sprites_addrs(crackpipe) <= bottompipe(bottompipe_idx).address;
	sprites_addrs(toppipe) <= toppipes(toppipe_idx).address;
	sprites_addrs(tree0) <= tree0s(tree0_idx).address;
	sprites_addrs(bird0) <= bird(bird_idx).address;
	sprites_addrs(cursor) <= mousecursor(mousecursor_idx).address;
	sprites_addrs(heart) <= hearts(heart_idx).address;
	sprites_addrs(coin) <= coins(coin_idx).address;
	sprites_addrs(cloud0) <= cloud0s(cloud0_idx).address;
	sprites_addrs(tree2) <= tree2s(tree2_idx).address;
	
	
	bird(bird_idx).colours <= sprites_out(bird0);
	grassplane(grass_idx).colours <= sprites_out(grass);
	tree0s(tree0_idx).colours <= sprites_out(tree0);
	bottompipe(bottompipe_idx).colours <= sprites_out(crackpipe);
	toppipes(toppipe_idx).colours <= sprites_out(toppipe);
	mousecursor(mousecursor_idx).colours <= sprites_out(cursor);
	hearts(heart_idx).colours <= sprites_out(heart);
	coins(coin_idx).colours <= sprites_out(coin);
	cloud0s(cloud0_idx).colours <= sprites_out(cloud0);
	tree2s(tree2_idx).colours <= sprites_out(tree2);
	
	sprite_r <= unsigned(mousecursor(mousecursor_idx).colours(3 downto 0))	when mousecursor(mousecursor_idx).colours(15 downto 12) /= "1111" and mousecursor(mousecursor_idx).in_range else
				unsigned(bird(bird_idx).colours(3 downto 0))				when bird(bird_idx).colours(15 downto 12) /= "1111" and bird(bird_idx).in_range else
				unsigned(hearts(heart_idx).colours(3 downto 0))				when hearts(heart_idx).colours(15 downto 12) /= "1111" and hearts(heart_idx).in_range else
				unsigned(coins(coin_idx).colours(3 downto 0))				when coins(coin_idx).colours(15 downto 12) /= "1111" and coins(coin_idx).in_range else
				unsigned(grassplane(grass_idx).colours(3 downto 0))			when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range else
				unsigned(bottompipe(bottompipe_idx).colours(3 downto 0))	when bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" and bottompipe(bottompipe_idx).in_range else
				unsigned(toppipes(toppipe_idx).colours(3 downto 0))			when toppipes(toppipe_idx).colours(15 downto 12) /= "1111" and toppipes(toppipe_idx).in_range else
				unsigned(tree0s(tree0_idx).colours(3 downto 0))				when tree0s(tree0_idx).colours(15 downto 12) /= "1111" and tree0s(tree0_idx).in_range else
				unsigned(tree2s(tree2_idx).colours(3 downto 0))				when tree2s(tree2_idx).colours(15 downto 12) /= "1111" and tree2s(tree2_idx).in_range else
				unsigned(cloud0s(cloud0_idx).colours(3 downto 0))				when cloud0s(cloud0_idx).colours(15 downto 12) /= "1111" and cloud0s(cloud0_idx).in_range else
				"1111";
				
	
	sprite_g <= unsigned(mousecursor(mousecursor_idx).colours(7 downto 4))	when mousecursor(mousecursor_idx).colours(15 downto 12) /= "1111" and mousecursor(mousecursor_idx).in_range else 
				unsigned(bird(bird_idx).colours(7 downto 4))				when bird(bird_idx).colours(15 downto 12) /= "1111" and bird(bird_idx).in_range else
				unsigned(hearts(heart_idx).colours(7 downto 4))				when hearts(heart_idx).colours(15 downto 12) /= "1111" and hearts(heart_idx).in_range else
				unsigned(coins(coin_idx).colours(7 downto 4))				when coins(coin_idx).colours(15 downto 12) /= "1111" and coins(coin_idx).in_range else
				unsigned(grassplane(grass_idx).colours(7 downto 4))			when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range else				
				unsigned(bottompipe(bottompipe_idx).colours(7 downto 4))	when bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" and bottompipe(bottompipe_idx).in_range else
				unsigned(toppipes(toppipe_idx).colours(7 downto 4))			when toppipes(toppipe_idx).colours(15 downto 12) /= "1111" and toppipes(toppipe_idx).in_range else
				unsigned(tree0s(tree0_idx).colours(7 downto 4))				when tree0s(tree0_idx).colours(15 downto 12) /= "1111" and tree0s(tree0_idx).in_range else
				unsigned(tree2s(tree2_idx).colours(7 downto 4))				when tree2s(tree2_idx).colours(15 downto 12) /= "1111" and tree2s(tree2_idx).in_range else
				unsigned(cloud0s(cloud0_idx).colours(7 downto 4))				when cloud0s(cloud0_idx).colours(15 downto 12) /= "1111" and cloud0s(cloud0_idx).in_range else
				"1111";
				
				
	
	sprite_b <= unsigned(mousecursor(mousecursor_idx).colours(11 downto 8)) when mousecursor(mousecursor_idx).colours(15 downto 12) /= "1111" and mousecursor(mousecursor_idx).in_range else
				unsigned(bird(bird_idx).colours(11 downto 8)) 				when bird(bird_idx).colours(15 downto 12) /= "1111" and bird(bird_idx).in_range else
				unsigned(hearts(heart_idx).colours(11 downto 8))			when hearts(heart_idx).colours(15 downto 12) /= "1111" and hearts(heart_idx).in_range else
				unsigned(coins(coin_idx).colours(11 downto 8))				when coins(coin_idx).colours(15 downto 12) /= "1111" and coins(coin_idx).in_range else
				unsigned(grassplane(grass_idx).colours(11 downto 8))		when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range else
				unsigned(bottompipe(bottompipe_idx).colours(11 downto 8))	when bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" and bottompipe(bottompipe_idx).in_range else
				unsigned(toppipes(toppipe_idx).colours(11 downto 8))		when toppipes(toppipe_idx).colours(15 downto 12) /= "1111" and toppipes(toppipe_idx).in_range else
				unsigned(tree0s(tree0_idx).colours(11 downto 8))			when tree0s(tree0_idx).colours(15 downto 12) /= "1111" and tree0s(tree0_idx).in_range else
				unsigned(tree2s(tree2_idx).colours(11 downto 8))			when tree2s(tree2_idx).colours(15 downto 12) /= "1111" and tree2s(tree2_idx).in_range else
				unsigned(cloud0s(cloud0_idx).colours(11 downto 8))				when cloud0s(cloud0_idx).colours(15 downto 12) /= "1111" and cloud0s(cloud0_idx).in_range else
				"1111";
				

	sprite_z <= "0000" when mousecursor_idx /= -1 and mousecursor(mousecursor_idx).in_range and mousecursor(mousecursor_idx).colours(15 downto 12) /= "1111" else
				"0000" when bird_idx /= -1 and bird(bird_idx).in_range and bird(bird_idx).colours(15 downto 12) /= "1111" else
				"0000" when heart_idx /= -1 and hearts(heart_idx).in_range and hearts(heart_idx).colours(15 downto 12) /= "1111" else
				"0000" when coin_idx /= -1 and coins(coin_idx).in_range and coins(coin_idx).colours(15 downto 12) /= "1111" else
				"0000" when grass_idx /= -1 and grassplane(grass_idx).in_range and grassplane(grass_idx).colours(15 downto 12) /= "1111" else
				"0000" when bottompipe_idx /= -1 and bottompipe(bottompipe_idx).in_range and bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" else
				"0000" when toppipe_idx /= -1 and toppipes(toppipe_idx).in_range and toppipes(toppipe_idx).colours(15 downto 12) /= "1111" else
				"0000" when tree0_idx /= -1 and tree0s(tree0_idx).in_range and tree0s(tree0_idx).colours(15 downto 12) /= "1111" else
				"0000" when cloud0_idx /= -1 and cloud0s(cloud0_idx).in_range and cloud0s(cloud0_idx).colours(15 downto 12) /= "1111" else
				"1111";
				
	
	red_out		<=	txt_r when txt_not_a = "1111" else sprite_r when sprite_z = "0000" else "0111"; -- 0111
	green_out	<=	txt_g when txt_not_a = "1111" else sprite_g when sprite_z = "0000" else "1100"; -- 1100
	blue_out	<= 	txt_b when txt_not_a = "1111" else sprite_b when sprite_z = "0000" else "1100"; -- 1100
	

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
	variable difficulty : natural range 0 to 2;
	variable p_speed : natural range 2 to 4;
	variable d_state : natural range 0 to 3 := 0; -- dynamic state of RnG of sprites
	
	begin
		if (rising_edge(v_sync)) then
			if(d_state = 0) then
				storedRandNum <= randNum;
			else
				storedRandNum <= storedRandNum;
			end if;
			
			if (game_mode = MODE_TITLE) then
				text_vector <= tvec_mode_title;
			elsif (game_mode = MODE_GAME) then
				text_vector <= tvec_mode_game;
			elsif (game_mode = MODE_OVER) then
				text_vector <= tvec_mode_over;
			else
				text_vector <= tvec_mode_train;
			end if;
			
			if (mouse_lbtn = '1') then
				if (game_mode = MODE_GAME or game_mode = MODE_TRAIN) then
					initial_lclick <= '1';
				end if;
			end if;
	
			if (game_mode = MODE_TITLE) then
				if (pb_0 = '1') then
						game_mode <= MODE_GAME;
						hearts(0).visible <= TRUE;
						hearts(1).visible <= TRUE;
						hearts(2).visible <= TRUE;
				elsif (pb_1 = '1') then
						game_mode <= MODE_TRAIN;
						hearts(0).visible <= FALSE;
						hearts(1).visible <= FALSE;
						hearts(2).visible <= FALSE;
				else
					game_mode <= MODE_TITLE;
				end if;				
			end if;
			
			-- hide the 'click mouse to start' text
			if ((game_mode = MODE_TRAIN or game_mode = MODE_GAME) and initial_lclick = '1') then
				hide_click2start_text <= true;
			end if;

			if (health_flag = '1') then
				ticks := ticks + 1;
				if (ticks = 5) then
					if (game_mode = MODE_GAME) then
						health <= health - 1;
						hearts(health - 1).visible <= FALSE;
						bird(0).visible <= FALSE;
					end if;
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
			
			--Random Number States
			
		if((bottompipe(d_state).x0 < (1023 - bottompipe(d_state).size * bottompipe(d_state).scaling_factor_x)) and bottompipe(d_state).underflow = true) then
			if ((game_mode = MODE_GAME and difficulty = 0) or game_mode = MODE_TRAIN) then 
				p_speed := 2;
					if (storedRandNum = "0000" or storedRandNum = "0001" or storedRandNum = "0010" or storedRandNum = "0011") then
						-- four unique pipe height setups for easy 
						if(d_state = 0) then 
						  bottompipe(d_state).x0 <= to_unsigned(640,10);
						  bottompipe(d_state).scaling_factor_y <= 2;
						  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
						  bottompipe(d_state).underflow <= false;
						  
						  toppipes(d_state).x0 <= to_unsigned(640,10);
						  toppipes(d_state).scaling_factor_y <= 2;
						  toppipes(d_state).underflow <= false;
						  
						  d_state := 1;
						else
						  bottompipe(d_state).x0 <= to_unsigned(640,10);
						  bottompipe(d_state).scaling_factor_y <= 3;
						  bottompipe(d_state).y0 <= to_unsigned(480 - (3 * bottompipe(d_state).size), 10);
						  bottompipe(d_state).underflow <= false;
						  
						  toppipes(d_state).x0 <= to_unsigned(640,10);
						  toppipes(d_state).scaling_factor_y <= 2;
						  toppipes(d_state).underflow <= false;
						  
						  d_state := 0;
						end if;
					elsif (storedRandNum = "0100" or storedRandNum = "0101" or storedRandNum = "0110" or storedRandNum = "0111") then
						if(d_state = 0) then 
						  bottompipe(d_state).x0 <= to_unsigned(640,10);
						  bottompipe(d_state).scaling_factor_y <= 1;
						  bottompipe(d_state).y0 <= to_unsigned(480 - (1 * bottompipe(d_state).size), 10);
						  bottompipe(d_state).underflow <= false;
						  
						  toppipes(d_state).x0 <= to_unsigned(640,10);
						  toppipes(d_state).scaling_factor_y <= 3;
						  toppipes(d_state).underflow <= false;
						  
						  d_state := 1;
						else
						  bottompipe(d_state).x0 <= to_unsigned(640,10);
						  bottompipe(d_state).scaling_factor_y <= 3;
						  bottompipe(d_state).y0 <= to_unsigned(480 - (3 * bottompipe(d_state).size), 10);
						  bottompipe(d_state).underflow <= false;
						  
						  toppipes(d_state).x0 <= to_unsigned(640,10);
						  toppipes(d_state).scaling_factor_y <= 1;
						  toppipes(d_state).underflow <= false;
						  
						  d_state := 0;
						 end if;
					elsif (storedRandNum = "1000" or storedRandNum = "1001" or storedRandNum = "1010" or storedRandNum = "1011") then 	
						if(d_state = 0) then 
						  bottompipe(d_state).x0 <= to_unsigned(640,10);
						  bottompipe(d_state).scaling_factor_y <= 2;
						  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
						  bottompipe(d_state).underflow <= false;
						  
						  toppipes(d_state).x0 <= to_unsigned(640,10);
						  toppipes(d_state).scaling_factor_y <= 1;
						  toppipes(d_state).underflow <= false;
						  
						  d_state := 1;
						else
						  bottompipe(d_state).x0 <= to_unsigned(640,10);
						  bottompipe(d_state).scaling_factor_y <= 2;
						  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
						  bottompipe(d_state).underflow <= false;
						  
						  toppipes(d_state).x0 <= to_unsigned(640,10);
						  toppipes(d_state).scaling_factor_y <= 2;
						  toppipes(d_state).underflow <= false;
						  
						  d_state := 0;					
						 end if;						
					else
						if(d_state = 0) then 
						  bottompipe(d_state).x0 <= to_unsigned(640,10);
						  bottompipe(d_state).scaling_factor_y <= 2;
						  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
						  bottompipe(d_state).underflow <= false;
						  
						  toppipes(d_state).x0 <= to_unsigned(640,10);
						  toppipes(d_state).scaling_factor_y <= 3;
						  toppipes(d_state).underflow <= false;
						  
						  d_state := 1;
						else
						  bottompipe(d_state).x0 <= to_unsigned(640,10);
						  bottompipe(d_state).scaling_factor_y <= 4;
						  bottompipe(d_state).y0 <= to_unsigned(480 - (4 * bottompipe(d_state).size), 10);
						  bottompipe(d_state).underflow <= false;
						  
						  toppipes(d_state).x0 <= to_unsigned(640,10);
						  toppipes(d_state).scaling_factor_y <= 1;
						  toppipes(d_state).underflow <= false;
						  
						  d_state := 0;								
						end if;
					end if;
			elsif (game_mode = MODE_GAME and difficulty = 1) then
				--p_speed := 3;
				-- four new pipe setups for medium, plus previous setups from easy (8 total)
				-- easy setups 
				if (storedRandNum = "0000" or storedRandNum = "0001") then
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 2;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 2;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 4;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (4 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 2;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;
					end if;						  
				elsif (storedRandNum = "0010" or storedRandNum = "0011") then
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 1;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (1 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 3;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 3;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (3 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 1;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;
					end if;				
				elsif (storedRandNum = "0100" or storedRandNum = "0101") then
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 2;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 3;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 2;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 2;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;					
					end if;				
				elsif (storedRandNum = "0110" or storedRandNum = "0111") then 
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 2;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 3;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 4;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (4 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 1;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;	
					end if;				
				-- new setups 
				
				elsif (storedRandNum = "1000" or storedRandNum = "1001") then 
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 3;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (3 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 3;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 4;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (4 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 2;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;
					end if; 				
				elsif (storedRandNum = "1010" or storedRandNum = "1011") then
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 4;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (4 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 2;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 2;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 3;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;
					end if; 				
				elsif (storedRandNum = "1100" or storedRandNum = "1101") then 
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 2;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 2;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 1;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (1 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 4;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;
					end if;				
				else
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 4;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (4 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 1;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 2;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 4;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;
					end if; 				
				end if;
			
			elsif (game_mode = MODE_GAME and difficulty = 2) then
				--p_speed := 4;
				-- eight new pipe setups for hard, plus previous setups from easy and medium (16 total)
				-- easy 
				if (storedRandNum = "0000" or storedRandNum = "0001") then
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 3;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (3 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 3;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 3;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (3 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 2;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;
					 end if;
				elsif (storedRandNum = "0011" or storedRandNum = "0010") then
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 3;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (3 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 2;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 3;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (3 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 1;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;
					 end if;					
				elsif (storedRandNum = "0100" or storedRandNum = "0101") then
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 4;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (4 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 2;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 2;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 4;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;
					 end if;									
				elsif (storedRandNum = "0110" or storedRandNum = "0111") then 
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 3;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (3 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 2;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 3;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (3 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 3;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;
					 end if;						

				elsif (storedRandNum = "1000" or storedRandNum = "1001") then
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 4;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (4 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 1;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 2;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 3;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;
					end if; 					
				elsif (storedRandNum = "1010" or storedRandNum = "1011") then 
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 2;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 4;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 1;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (1 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 5;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;
					end if; 					
				elsif (storedRandNum = "1100" or storedRandNum = "1101") then 
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 4;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (4 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 2;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 2;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (2 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 4;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;
					end if; 							
				elsif (storedRandNum = "1110") then
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 3;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (3 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 3;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 1;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (1 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 4;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;
					end if; 							
				else
					if(d_state = 0) then 
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 3;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (3 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 3;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 1;
					else
					  bottompipe(d_state).x0 <= to_unsigned(640,10);
					  bottompipe(d_state).scaling_factor_y <= 5;
					  bottompipe(d_state).y0 <= to_unsigned(480 - (5 * bottompipe(d_state).size), 10);
					  bottompipe(d_state).underflow <= false;
					  
					  toppipes(d_state).x0 <= to_unsigned(640,10);
					  toppipes(d_state).scaling_factor_y <= 1;
					  toppipes(d_state).underflow <= false;
					  
					  d_state := 0;				
					end if;
				end if;
			else 
				d_state := d_state;
			end if;
		else
			d_state := d_state;
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
					if(pipe_points < 15) then 
						difficulty := 0;
					elsif(pipe_points > 25 and pipe_points < 35) then
						difficulty := 1;
					else
						difficulty := 2;
					end if;
					pipe_points <= pipe_points + 1; 
				end if;		

				if (initial_lclick = '1') then
					if (collision_flag = '0' and (game_mode = MODE_GAME or game_mode = MODE_TRAIN)) then
						if (bottompipe(i).underflow = false) then
							bottompipe(i).x0 <= bottompipe(i).x0 - p_speed;
							if (bottompipe(i).x0 < 1) then
								bottompipe(i).underflow <= true;
							end if;
						elsif (bottompipe(i).x0 >= 1023 - bottompipe(i).size * bottompipe(i).scaling_factor_x) then
							bottompipe(i).x0 <= bottompipe(i).x0 - p_speed;
						elsif (bottompipe(i).x0 < 1023 - bottompipe(i).size * bottompipe(i).scaling_factor_x) then
							bottompipe(i).passed_pipe <= false;
						end if;
						
						if (toppipes(i).underflow = false) then
							toppipes(i).x0 <= toppipes(i).x0 - p_speed;
							if (toppipes(i).x0 < 1) then
								toppipes(i).underflow <= true;
							end if;
						elsif (toppipes(i).x0 >= 1023 - toppipes(i).size * toppipes(i).scaling_factor_x) then
							toppipes(i).x0 <= toppipes(i).x0 - p_speed;
						end if;

						if (bottompipe(i).visible = true and toppipes(i).visible = true and bird(0).visible = true and enable_collision = '1') then
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
		
		
		
		
			if (game_mode = MODE_OVER) then
				if (bird(0).y0 + 5 <= 512) then
					bird(0).y0 <= bird(0).y0 + 5;
				end if;
				collision_flag := '0';
				
				if (pb_0 = '1') then 
					game_mode <= MODE_TITLE;
					initial_lclick <= '0';
					pipe_points <= 0;
				else
					game_mode <= MODE_OVER;
				end if;
			end if;
		
		
			-- Mouse input (make the bird flap)
			-- Don't let the bird flap if we have detected a collision (remember we are drawing the next frame here)
			if (collision_flag = '0' and initial_lclick = '1' and game_mode /= MODE_TITLE) then
				if (mouse_lbtn = '1' and mouse_flag = '0') then
					mouse_flag := '1';
					apply_h_boost := 8;
				end if;
			end if;
		
			-- Boost the bird up on mouse click, otherwise make it fall 
			-- Don't let the bird flap if we have detected a collision (remember we are drawing the next frame here)
			if (collision_flag = '0' and initial_lclick = '1') then
				if (apply_h_boost > 0) then
						if (bird(0).y0 - h_boost_per_frame >= 0 and bird(0).y0 - h_boost_per_frame < 480) then
							bird(0).y0 <= bird(0).y0 - h_boost_per_frame;
							apply_h_boost := apply_h_boost - 1;
						else
							apply_h_boost := 0;
						end if;
				else
					-- lower bird by 3 pixels (make it 'fall' 3 pixels)
					if (bird(0).y0 + 3 >= 480) then
						collision_flag := '1';
						game_mode <= MODE_OVER;
					else
						bird(0).y0 <= bird(0).y0 + 3;
					end if;
				end if;
			end if;
			
			if (mouse_lbtn = '0' and mouse_flag = '1') then
				mouse_flag := '0';
			end if;
			for i in 0 to (tree0s'length - 1) loop
				if (tree0s(i).x0 <= 640) then
						tree0s(i).underflow <= false;
						tree0s(i).x0 <= tree0s(i).x0 - p_speed;
						if (tree0s(i).x0 < 1) then
							tree0s(i).underflow <= true;
						end if;
					elsif (tree0s(i).x0 >= 1023 - tree0s(i).size * tree0s(i).scaling_factor_x) then
						tree0s(i).x0 <= tree0s(i).x0 - p_speed;
					elsif (tree0s(i).x0 < 1023 - tree0s(i).size * tree0s(i).scaling_factor_x) then
						tree0s(i).underflow <= false;
						tree0s(i).x0 <= to_unsigned(640, 10); 
					end if;
			end loop;
			
			for i in 0 to (tree2s'length - 1) loop
				if (tree2s(i).x0 <= 640) then
						tree2s(i).underflow <= false;
						tree2s(i).x0 <= tree2s(i).x0 - p_speed;
						if (tree2s(i).x0 < 1) then
							tree2s(i).underflow <= true;
						end if;
					elsif (tree2s(i).x0 >= 1023 - tree2s(i).size * tree2s(i).scaling_factor_x) then
						tree2s(i).x0 <= tree0s(i).x0 - p_speed;
					elsif (tree2s(i).x0 < 1023 - tree2s(i).size * tree2s(i).scaling_factor_x) then
						tree2s(i).underflow <= false;
						tree2s(i).x0 <= to_unsigned(640, 10); 
					end if;
			end loop;
			
			for i in 0 to (cloud0s'length - 1) loop
				if (cloud0s(i).x0 <= 640) then
						cloud0s(i).underflow <= false;
						cloud0s(i).x0 <= cloud0s(i).x0 - p_speed;
						if (cloud0s(i).x0 < 1) then
							cloud0s(i).underflow <= true;
						end if;
					elsif (cloud0s(i).x0 >= 1023 - cloud0s(i).size * cloud0s(i).scaling_factor_x) then
						cloud0s(i).x0 <= cloud0s(i).x0 - p_speed;
					elsif (cloud0s(i).x0 < 1023 - cloud0s(i).size * cloud0s(i).scaling_factor_x) then
						cloud0s(i).underflow <= false;
						cloud0s(i).x0 <= to_unsigned(640, 10); 
					end if;
			end loop;
			
			for i in 0 to (grassplane'length - 1) loop
				if (grassplane(i).x0 <= 640) then
						grassplane(i).underflow <= false;
						grassplane(i).x0 <= grassplane(i).x0 - p_speed;
						if (grassplane(i).x0 < 1) then
							grassplane(i).underflow <= true;
						end if;
					elsif (grassplane(i).x0 >= 1023 - grassplane(i).size * grassplane(i).scaling_factor_x) then
						grassplane(i).x0 <= grassplane(i).x0 - p_speed;
					elsif (grassplane(i).x0 < 1023 - grassplane(i).size * grassplane(i).scaling_factor_x) then
						grassplane(i).underflow <= false;
						grassplane(i).x0 <= to_unsigned(640, 10);
					end if;
			end loop;
		end if; 
	end process;
end architecture;

