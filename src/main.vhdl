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
	
	signal sec : natural range 0 to 59 := 0;
	
	signal sprites : all_sprites(0 to 1) := (
		(32, to_unsigned(50, 10), to_unsigned(50,10), "000000000000", bird0, "0000000000000000", false, 1, 1),
		(64, to_unsigned(80, 10), to_unsigned(50,10), "000000000000", crackpipe, "0000000000000000", false, 1, 1)
	);
	
	signal grassplane : all_sprites(0 to 9) := (
		(32, to_unsigned(416, 10), to_unsigned(0,10), "000000000000", grass, "0000000000000000", false, 1, 1),
		(32, to_unsigned(416, 10), to_unsigned(64,10), "000000000000", grass, "0000000000000000", false, 1, 1),
		(32, to_unsigned(416, 10), to_unsigned(128,10), "000000000000", grass, "0000000000000000", false, 1, 1),
		(32, to_unsigned(416, 10), to_unsigned(192,10), "000000000000", grass, "0000000000000000", false, 1, 1),
		(32, to_unsigned(416, 10), to_unsigned(256,10), "000000000000", grass, "0000000000000000", false, 2, 2),
		(32, to_unsigned(416, 10), to_unsigned(320,10), "000000000000", grass, "0000000000000000", false, 2, 2),
		(32, to_unsigned(416, 10), to_unsigned(384,10), "000000000000", grass, "0000000000000000", false, 2, 2),
		(32, to_unsigned(416, 10), to_unsigned(448,10), "000000000000", grass, "0000000000000000", false, 2, 2),
		(32, to_unsigned(416, 10), to_unsigned(512,10), "000000000000", grass, "0000000000000000", false, 2, 2),
		(32, to_unsigned(416, 10), to_unsigned(576,10), "000000000000", grass, "0000000000000000", false, 2, 2)
	);
	
	
	signal sprites_addrs : sprite_addr_array;
	signal sprites_out : sprite_output_array;
	
	signal grass_idx : natural range 0 to 15;
	
begin

	spriteengine0 : spriteengine port map (clk, vga_row, vga_col, sprites_addrs, sprites_out);
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
	
	--Sprites

	grass_idx <= get_active_idx(grassplane, vga_row, vga_col);	
	
	grassplane(grass_idx).address <= calc_addr_f(grassplane(grass_idx), vga_row, vga_col);
	
	calc_addr(sprites(bird0), vga_row, vga_col);
	calc_addr(sprites(crackpipe), vga_row, vga_col);
	
	grassplane(grass_idx).in_range <= return_in_range(grassplane(grass_idx), vga_row, vga_col);
	
	calc_in_range(sprites(bird0), vga_row, vga_col);
	calc_in_range(sprites(crackpipe), vga_row, vga_col);
	
	sprites_addrs(grass) <= grassplane(grass_idx).address;
	
	sprites_addrs(bird0) <= sprites(bird0).address;
	sprites_addrs(crackpipe) <= sprites(crackpipe).address;	
	
	grassplane(grass_idx).colours <= sprites_out(grass);
	
	sprites(bird0).colours <= sprites_out(bird0);
	sprites(crackpipe).colours <= sprites_out(crackpipe);
	
	
	sprite_r <= unsigned(sprites(crackpipe).colours(3 downto 0))		when sprites(crackpipe).colours(15 downto 12) /= "1111" and sprites(crackpipe).in_range else 
				unsigned(sprites(bird0).colours(3 downto 0))			when sprites(bird0).colours(15 downto 12) /= "1111" and sprites(bird0).in_range else
				unsigned(grassplane(grass_idx).colours(3 downto 0))		when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range;
	
	sprite_g <= unsigned(sprites(crackpipe).colours(7 downto 4))		when sprites(crackpipe).colours(15 downto 12) /= "1111" and sprites(crackpipe).in_range else
				unsigned(sprites(bird0).colours(7 downto 4))			when sprites(bird0).colours(15 downto 12) /= "1111" and sprites(bird0).in_range else
				unsigned(grassplane(grass_idx).colours(7 downto 4))		when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range;
	
	sprite_b <= unsigned(sprites(crackpipe).colours(11 downto 8))		when sprites(crackpipe).colours(15 downto 12) /= "1111" and sprites(crackpipe).in_range else
				unsigned(sprites(bird0).colours(11 downto 8)) 			when sprites(crackpipe).colours(15 downto 12) /= "1111" and sprites(bird0).in_range else
				unsigned(grassplane(grass_idx).colours(11 downto 8))	when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range;

	sprite_z <= "0000" when sprites(crackpipe).in_range and sprites(crackpipe).colours(15 downto 12) /= "1111" else
				"0000" when sprites(bird0).in_range and sprites(bird0).colours(15 downto 12) /= "1111" else
				"0000" when grassplane(grass_idx).in_range and grassplane(grass_idx).colours(15 downto 12) /= "1111" else
				"1111";
	
	red_out <=		txt_r when txt_not_a = "1111" else sprite_r when sprite_z = "0000" else "0111";
	green_out <=	txt_g when txt_not_a = "1111" else sprite_g when sprite_z = "0000" else "1100";
	blue_out <=		txt_b when txt_not_a = "1111" else sprite_b when sprite_z = "0000" else "1100";
	
	process(clk)
		variable ticks : integer := 0;
	begin
		if (rising_edge(clk)) then
			ticks := ticks + 1;
			if (ticks >= 25000000) then
				-- things to happen every second
				sprites(bird0).x0 <= sprites(bird0).x0 + 1;
				sprites(bird0).y0 <= sprites(bird0).y0 + 1;
				
				sec <= sec + 1;
				ticks := 0;
			end if;
			
			if (mouse_lbtn = '1') then
				mouse_btn <= var_len_str("Left Mouse button Pressed", mouse_btn'length);
			elsif (mouse_rbtn = '1') then
				mouse_btn <= var_len_str("Right Mouse button Pressed", mouse_btn'length);
			else
				mouse_btn <= var_len_str("No Mouse button Pressed", mouse_btn'length);
			end if;
		end if;
	end process;
end architecture;
