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
	
	-- components --
	component spriteengine is
		port(
			clk			: in std_ulogic;
			vga_row		: in unsigned(9 downto 0);
			vga_col		: in unsigned(9 downto 0);
			R				: out unsigned(3 downto 0);
			G				: out unsigned(3 downto 0);
			B				: out unsigned(3 downto 0);
			Z				: out unsigned(3 downto 0)
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
	
	
begin
	spriteengine0 : spriteengine port map (clk, vga_row, vga_col, sprite_r, sprite_g, sprite_b, sprite_z);
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
	
	
	red_out <=		txt_r when txt_not_a = "1111" else sprite_r when sprite_z = "0000" else "0000";
	green_out <=	txt_g when txt_not_a = "1111" else sprite_g when sprite_z = "0000" else "0000";
	blue_out <=		txt_b when txt_not_a = "1111" else sprite_b when sprite_z = "0000" else "0000";

					
	process(clk)
		variable ticks : integer := 0;
	begin
		if (rising_edge(clk)) then
			ticks := ticks + 1;
			if (ticks >= 25000000) then
				-- things to happen every second
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
