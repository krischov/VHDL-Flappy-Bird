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
	signal collision_flag : std_logic := '0';
	signal sec : natural range 0 to 59 := 0;

	
	-- (sprite size, y0, x0, addr, sprite, colour, in_range, scale_x, scale_y, visible, underflow, passed_pipe)  

	signal bird : all_sprites(0 to 1)  := (
		(32, to_unsigned(50, 10), to_unsigned(50,10), "000000000000", bird0, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE),
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
		(64, to_unsigned(60, 10), to_unsigned(50, 10), "000000000000", tree0, "0000000000000000", false, 1, 1, TRUE, FALSE, FALSE),
		(64, to_unsigned(60, 10), to_unsigned(200, 10), "000000000000", tree0, "0000000000000000", false, 2, 2, TRUE, FALSE, FALSE),
		(64, to_unsigned(200, 10), to_unsigned(10, 10), "000000000000", tree0, "0000000000000000", false, 2, 2, TRUE, FALSE, FALSE)
	);
	
	signal sprites_addrs : sprite_addr_array;
	signal sprites_out : sprite_output_array;
	signal grass_idx, bottompipe_idx, bird_idx, tree0_idx, toppipe_idx : integer;
	
	
	signal pipe_points: natural range 0 to 8000 := 0;
	
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
	str2text(text_vector, 7, 65, 2, "1010", "0101", "1100", "Points " & int2str(pipe_points));
	
	--Sprites

	grass_idx <= get_active_idx(grassplane, vga_row, vga_col);	
	grassplane(grass_idx).address <= calc_addr_f(grassplane(grass_idx), vga_row, vga_col);
	
	bottompipe_idx <= get_active_idx(bottompipe, vga_row, vga_col);
	bottompipe(bottompipe_idx).address <= calc_addr_f(bottompipe(bottompipe_idx), vga_row, vga_col);
	
	toppipe_idx <= get_active_idx(toppipes, vga_row, vga_col);
	toppipes(toppipe_idx).address <= calc_addr_f(toppipes(toppipe_idx), vga_row, vga_col);
	
	tree0_idx <= get_active_idx(tree0s, vga_row, vga_col);
	tree0s(tree0_idx).address <= calc_addr_f(tree0s(tree0_idx), vga_row, vga_col);
	
	bird_idx <= get_active_idx(bird, vga_row, vga_col);	
	bird(bird_idx).address <= calc_addr_f(bird(bird_idx), vga_row, vga_col);
	
	
	bird(bird_idx).in_range <= return_in_range(bird(bird_idx), vga_row, vga_col) when bird_idx /= -1 else false;
	grassplane(grass_idx).in_range <= return_in_range(grassplane(grass_idx), vga_row, vga_col) when grass_idx /= -1 else false;
	bottompipe(bottompipe_idx).in_range <= return_in_range(bottompipe(bottompipe_idx), vga_row, vga_col) when bottompipe_idx /= -1 else false;
	toppipes(toppipe_idx).in_range <= return_in_range(toppipes(toppipe_idx), vga_row, vga_col) when toppipe_idx /= -1 else false;
	tree0s(tree0_idx).in_range <= return_in_range(tree0s(tree0_idx), vga_row, vga_col) when tree0_idx /= -1 else false;
	

	sprites_addrs(grass) <= grassplane(grass_idx).address;	
	sprites_addrs(crackpipe) <= bottompipe(bottompipe_idx).address;
	sprites_addrs(toppipe) <= toppipes(toppipe_idx).address;
	sprites_addrs(tree0) <= tree0s(tree0_idx).address;
	sprites_addrs(bird0) <= bird(bird_idx).address;
	
	bird(bird_idx).colours <= sprites_out(bird0);
	grassplane(grass_idx).colours <= sprites_out(grass);
	tree0s(tree0_idx).colours <= sprites_out(tree0);
	bottompipe(bottompipe_idx).colours <= sprites_out(crackpipe);
	toppipes(toppipe_idx).colours <= sprites_out(toppipe);

	
	sprite_r <= unsigned(bird(bird_idx).colours(3 downto 0))				when bird(bird_idx).colours(15 downto 12) /= "1111" and bird(bird_idx).in_range else
				unsigned(grassplane(grass_idx).colours(3 downto 0))			when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range else
				unsigned(bottompipe(bottompipe_idx).colours(3 downto 0))	when bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" and bottompipe(bottompipe_idx).in_range else
				unsigned(toppipes(toppipe_idx).colours(3 downto 0))	when toppipes(toppipe_idx).colours(15 downto 12) /= "1111" and toppipes(toppipe_idx).in_range else
				unsigned(tree0s(tree0_idx).colours(3 downto 0))				when tree0s(tree0_idx).colours(15 downto 12) /= "1111" and tree0s(tree0_idx).in_range;
	
	sprite_g <= unsigned(bird(bird_idx).colours(7 downto 4))				when bird(bird_idx).colours(15 downto 12) /= "1111" and bird(bird_idx).in_range else
				unsigned(grassplane(grass_idx).colours(7 downto 4))			when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range else
				unsigned(bottompipe(bottompipe_idx).colours(7 downto 4))	when bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" and bottompipe(bottompipe_idx).in_range else
				unsigned(toppipes(toppipe_idx).colours(7 downto 4))	when toppipes(toppipe_idx).colours(15 downto 12) /= "1111" and toppipes(toppipe_idx).in_range else
				unsigned(tree0s(tree0_idx).colours(7 downto 4))				when tree0s(tree0_idx).colours(15 downto 12) /= "1111" and tree0s(tree0_idx).in_range;
	
	sprite_b <=  
				unsigned(bird(bird_idx).colours(11 downto 8)) 				when bird(bird_idx).colours(15 downto 12) /= "1111" and bird(bird_idx).in_range else
				unsigned(grassplane(grass_idx).colours(11 downto 8))		when grassplane(grass_idx).colours(15 downto 12) /= "1111" and grassplane(grass_idx).in_range else
				unsigned(bottompipe(bottompipe_idx).colours(11 downto 8))	when bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" and bottompipe(bottompipe_idx).in_range else
				unsigned(toppipes(toppipe_idx).colours(11 downto 8))	when toppipes(toppipe_idx).colours(15 downto 12) /= "1111" and toppipes(toppipe_idx).in_range else
				unsigned(tree0s(tree0_idx).colours(11 downto 8))				when tree0s(tree0_idx).colours(15 downto 12) /= "1111" and tree0s(tree0_idx).in_range;

	sprite_z <= 
				"0000" when bird_idx /= -1 and bird(bird_idx).in_range and bird(bird_idx).colours(15 downto 12) /= "1111" else
				"0000" when grass_idx /= -1 and grassplane(grass_idx).in_range and grassplane(grass_idx).colours(15 downto 12) /= "1111" else
				"0000" when bottompipe_idx /= -1 and bottompipe(bottompipe_idx).in_range and bottompipe(bottompipe_idx).colours(15 downto 12) /= "1111" else
				"0000" when toppipe_idx /= -1 and toppipes(toppipe_idx).in_range and toppipes(toppipe_idx).colours(15 downto 12) /= "1111" else
				"0000" when tree0_idx /= -1 and tree0s(tree0_idx).in_range and tree0s(tree0_idx).colours(15 downto 12) /= "1111" else
				"1111";
	
	red_out		<=	"1111" when vga_col < 5 and bird_idx = -1 else txt_r when txt_not_a = "1111" else sprite_r when sprite_z = "0000" else "0111";
	green_out	<=	"1111" when vga_col < 5 and bottompipe_idx = -1 else txt_g when txt_not_a = "1111" else sprite_g when sprite_z = "0000" else "1100";
	blue_out	<=	"1111" when vga_col < 5 and bird_idx = -1 and bottompipe_idx = -1 else txt_b when txt_not_a = "1111" else sprite_b when sprite_z = "0000" else "1100";
	
	
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
			end if;
			
			if (mouse_lbtn = '1') then
				mouse_btn <= var_len_str("Left Mouse button Pressed", mouse_btn'length);
			elsif (mouse_rbtn = '1') then
				mouse_btn <= var_len_str("Right Mouse button Pressed", mouse_btn'length);
			else
				mouse_btn <= var_len_str("No Mouse button Pressed", mouse_btn'length);
			end if;
	end process;
	
	VSYNC: process(v_sync)
	variable mouse_flag : std_logic := '0';
	
	begin
		if (v_sync = '1') then
		
			--if (collision_flag = '0') then
			-- Moby's Movement
	
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
				end if;	
					
					-- Do collision and point detection here
					if ((((bird(0).x0 + 2 >= bottompipe(i).x0) and (bird(0).x0 + 2 <= bottompipe(i).x0 + bird(0).size - 1)) or
						((bird(0).x0 + bird(0).size - 1 >= bottompipe(i).x0) and (bird(0).x0 + bird(0).size - 1 <= bottompipe(i).x0 + 31))) and
						(((bird(0).y0 + 4 >= bottompipe(i).y0) and (bird(0).y0 + 4 <= bottompipe(i).y0 + bottompipe(i).size*bottompipe(i).scaling_factor_y - 1)) or
						((bird(0).y0 + bird(0).size - 8 >= bottompipe(i).y0) and (bird(0).y0 + bird(0).size - 8 <= bottompipe(i).y0 + bottompipe(i).size*bottompipe(i).scaling_factor_y - 1)))) then
						collision_flag <= '1';
					end if;
					if ((((bird(0).x0 + 2 >= toppipes(i).x0) and (bird(0).x0 + 2 <= toppipes(i).x0 + bird(0).size - 1)) or
						  ((bird(0).x0 + bird(0).size - 1 >= toppipes(i).x0) and (bird(0).x0 + bird(0).size - 1 <= toppipes(i).x0 + bird(0).size - 1))) and
						  (((bird(0).y0 + 4 >= toppipes(i).y0) and (bird(0).y0 + 4 <= toppipes(i).y0 + toppipes(i).size*toppipes(i).scaling_factor_y + 1)) or
						  ((bird(0).y0 + bird(0).size - 8 >= toppipes(i).y0) and (bird(0).y0 + bird(0).size - 8 <= toppipes(i).y0 + toppipes(i).size*toppipes(i).scaling_factor_y - 1)))) then
						  collision_flag <= '1';
					end if;
					
--					if (bird_idx /= -1 and bottompipe_idx /= -1) then
--						collision_flag <= '1';
--					end if;

					if (bottompipe(i).passed_pipe = false and bird(0).x0 > bottompipe(i).x0 + bottompipe(i).size * bottompipe(i).scaling_factor_x) then
						-- if the user has just passed through this pipe, give them a point
						bottompipe(i).passed_pipe <= true;
						pipe_points <= pipe_points + 1; 
					end if;
					
				end loop;
			
				-- Mouse input (make the bird flap)
				if (collision_flag = '0') then
					if (mouse_lbtn = '1' and mouse_flag = '0') then
						mouse_flag := '1';
						if (bird(0).y0 >= 0) then
							bird(0).y0 <= bird(0).y0 - 60;
						end if;	
					elsif (bird(0).y0 <= 448) then
						bird(0).y0 <= bird(0).y0 + 3;
					end if;
				end if;
				if (mouse_lbtn = '0' and mouse_flag = '1') then
					mouse_flag := '0';
				end if;
			--end if;
		end if; 
	end process;
end architecture;
