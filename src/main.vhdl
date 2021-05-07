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
	
	signal mouse_btn : string(1 to 50) := var_len_str("No Mouse Button Pressed", 50);
	
	signal num_test : natural range 0 to 2**14-1 := 16375;
	signal bcd_test : natural range 0 to 2**13-1 := 8180;
begin
	textengine0: textengine port map(clk, text_vector, vga_row, vga_col, txt_r, txt_g, txt_b, txt_not_a);
	
	str2text(text_vector, 0, 0, 1, "1111", "1111", "1111", "ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789 []!@#$%""()&*+-,./");
	str2text(text_vector, 1, 0, 1, "1111", "0000", "0000", ".........1.........2.........3.........4.........5.........6.........7.........8");
	str2text(text_vector, 59, 0, 1, "1111", "0000", "0000", ".........1.........2.........3.........4.........5.........6.........7.........8");
	str2text(text_vector, 5, 30, 1, "1111", "1111", "1111", "The Modelsim Mobsters Present");
	str2text(text_vector, 6, 30, 1, "1010", "0101", "1100", "text (in colour!)");
	str2text(text_vector, 10, 30, 1, "0011", "1100", "1001", mouse_btn);
	str2text(text_vector, 13, 20, 1, "0011", "1100", "1001", "second counter [ " & int2str(num_test) & " ]");
	
	-- connect this to seven segment display for testing
	int2bcd(bcd_test);
	
	process(clk)
		variable ticks : integer := 0;
		variable square_at_bottom : boolean := false;
	begin
		if (rising_edge(clk)) then
			ticks := ticks + 1;
			if (ticks >= 25000000) then
				-- things to happen every second
				num_test <= num_test + 1;
				
				-- make the red square move in a square
				if (square_at_bottom) then
					y0 <= y0 - 10;
					if (y0 <= 50) then
						square_at_bottom := false;
					end if;
				else
					y0 <= y0 + 10;
					if (y0 >= 250) then
						square_at_bottom := true;
					end if;
				end if;
				
				bcd_test <= bcd_test + 1;
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
			
			-- draw text
			if (txt_not_a = "1111") then
				red_out <= txt_r;
				green_out <= txt_g;
				blue_out <= txt_b;
			-- draw red square
			elsif (vga_row < y0 + h and vga_row > y0 and 
					vga_col < x0 + w and vga_col > x0) then
				red_out <= colour;
				green_out <= "0000";
				blue_out <= "0000";
			else
				red_out <= "0000";
				green_out <= "0000";
				blue_out <= "0000";
			end if;
		end if;
	end process;
end architecture;
