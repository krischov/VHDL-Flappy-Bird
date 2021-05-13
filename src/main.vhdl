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
	COMPONENT rom_ctrl IS
	GENERIC (mif_file : STRING);
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
	END COMPONENT rom_ctrl;
	
	-- signals -- 
	
	signal y0_0: unsigned(9 downto 0) := to_unsigned(100, 10);
	signal x0_0: unsigned(9 downto 0) := to_unsigned(50, 10);
	signal y0_1: unsigned(9 downto 0) := to_unsigned(100, 10);
	signal x0_1: unsigned(9 downto 0) := to_unsigned(50, 10);
	signal y0_2: unsigned(9 downto 0) := to_unsigned(200, 10);
	signal x0_2: unsigned(9 downto 0) := to_unsigned(80, 10);
	signal y0_3: unsigned(9 downto 0) := to_unsigned(300, 10);
	signal x0_3: unsigned(9 downto 0) := to_unsigned(80, 10);
	signal w, h: unsigned(9 downto 0) := to_unsigned(32, 10);
	
	signal text_vector: textengine_vector := (others => init_textengine_row);
	signal txt_r : unsigned(3 downto 0) := "0000";
	signal txt_g : unsigned(3 downto 0) := "0000";
	signal txt_b : unsigned(3 downto 0) := "0000";
	signal txt_not_a : unsigned(3 downto 0) := "0000";
	
	signal mouse_btn : string(1 to 50) := var_len_str("No Mouse Button Pressed", 50);
	
	signal sec : natural range 0 to 59 := 0;
	
	signal rom_addr0: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(0, 10));
	signal rom_data0: std_logic_vector(15 downto 0) := x"0000";
	signal rom_addr1: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(0, 10));
	signal rom_data1: std_logic_vector(15 downto 0) := x"0000";
	signal rom_addr2: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(0, 10));
	signal rom_data2: std_logic_vector(15 downto 0) := x"0000";
	signal rom_addr3: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(0, 10));
	signal rom_data3: std_logic_vector(15 downto 0) := x"0000";
	
begin
	
	sprite0: rom_ctrl generic map ("../src/transparancy0.mif") port map (rom_addr0, clk, rom_data0);
	sprite1: rom_ctrl generic map ("../src/transparancy1.mif") port map (rom_addr1, clk, rom_data1);
	sprite2: rom_ctrl generic map ("../src/test.mif") port map (rom_addr2, clk, rom_data2);
	sprite3: rom_ctrl generic map ("../src/htest.mif") port map (rom_addr3, clk, rom_data3);
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
	
	rom_addr0 <= std_logic_vector(resize(shift_left((vga_row - y0_0), 5) + (vga_col + 1 - x0_0), 10));
	rom_addr1 <= std_logic_vector(resize(shift_left((vga_row - y0_1), 5) + (vga_col + 1 - x0_1), 10));
	rom_addr2 <= std_logic_vector(resize(shift_left((vga_row - y0_2), 5) + (vga_col + 1 - x0_2), 10));
	rom_addr3 <= std_logic_vector(resize(shift_left((vga_row - y0_3), 5) + (vga_col + 1 - x0_3), 10));
	
	red_out <=		txt_r when txt_not_a = "1111" else
					unsigned(rom_data0(3 downto 0)) when (vga_row < y0_0 + h and vga_row >= y0_0 and vga_col < x0_0 + w and vga_col >= x0_0 and rom_data0(15 downto 12) /= "1111") else
					unsigned(rom_data1(3 downto 0)) when (vga_row < y0_1 + h and vga_row >= y0_1 and vga_col < x0_1 + w and vga_col >= x0_1 and rom_data1(15 downto 12) /= "1111") else
					unsigned(rom_data2(3 downto 0)) when (vga_row < y0_2 + h and vga_row >= y0_2 and vga_col < x0_2 + w and vga_col >= x0_2 and rom_data2(15 downto 12) /= "1111") else
					unsigned(rom_data3(3 downto 0)) when (vga_row < y0_3 + h and vga_row >= y0_3 and vga_col < x0_3 + w and vga_col >= x0_3 and rom_data3(15 downto 12) /= "1111") else
					"0101";
	green_out <=	txt_g when txt_not_a = "1111" else
					unsigned(rom_data0(7 downto 4)) when (vga_row < y0_0 + h and vga_row >= y0_0 and vga_col < x0_0 + w and vga_col >= x0_0 and rom_data0(15 downto 12) /= "1111") else
					unsigned(rom_data1(7 downto 4)) when (vga_row < y0_1 + h and vga_row >= y0_1 and vga_col < x0_1 + w and vga_col >= x0_1 and rom_data1(15 downto 12) /= "1111") else
					unsigned(rom_data2(7 downto 4)) when (vga_row < y0_2 + h and vga_row >= y0_2 and vga_col < x0_2 + w and vga_col >= x0_2 and rom_data2(15 downto 12) /= "1111") else
					unsigned(rom_data3(7 downto 4)) when (vga_row < y0_3 + h and vga_row >= y0_3 and vga_col < x0_3 + w and vga_col >= x0_3 and rom_data3(15 downto 12) /= "1111") else
					"0101";
	blue_out <=		txt_b when txt_not_a = "1111" else
					unsigned(rom_data0(11 downto 8)) when (vga_row < y0_0 + h and vga_row >= y0_0 and vga_col < x0_0 + w and vga_col >= x0_0 and rom_data0(15 downto 12) /= "1111") else
					unsigned(rom_data1(11 downto 8)) when (vga_row < y0_1 + h and vga_row >= y0_1 and vga_col < x0_1 + w and vga_col >= x0_1 and rom_data1(15 downto 12) /= "1111") else
					unsigned(rom_data2(11 downto 8)) when (vga_row < y0_2 + h and vga_row >= y0_2 and vga_col < x0_2 + w and vga_col >= x0_2 and rom_data2(15 downto 12) /= "1111") else
					unsigned(rom_data3(11 downto 8)) when (vga_row < y0_3 + h and vga_row >= y0_3 and vga_col < x0_3 + w and vga_col >= x0_3 and rom_data3(15 downto 12) /= "1111") else
					"0101";
					
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
