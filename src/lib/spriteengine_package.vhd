library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package spriteengine_package is 
	--Sprite is 32 x 32
	
	constant bird0 	: natural range 0 to 31 := 0;
	constant crackpipe: natural range 0 to 31 := 1;
	constant tree0 	: natural range 0 to 31 := 2;
	constant tree1 	: natural range 0 to 31 := 3;
	constant grass 	: natural range 0 to 31 := 4;
	
	
	type sprite_output_array is array(0 to 4) of std_logic_vector(15 downto 0);
	type sprite_addr_array is array (0 to 4) of std_logic_vector(11 downto 0);
	
	type sprite is record
		size 				: natural range 0 to 64;
		y0					: unsigned(9 downto 0);
		x0					: unsigned(9 downto 0);
		address				: std_logic_vector(11 downto 0);
		index 				: natural range 0 to 31;
		colours				: std_logic_vector(15 downto 0);
		in_range			: boolean;
		scaling_factor_x 	: natural range 0 to 16;
		scaling_factor_y 	: natural range 0 to 16;
		visible 				: boolean;
	end record sprite;
	
	type all_sprites is array(natural range <>) of sprite;

	function get_active_idx (signal sprites: in all_sprites; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0)) return natural;
	function return_in_range (signal s: in sprite; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0)) return boolean;
	function calc_addr_f (signal s: in sprite; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0)) return std_logic_vector;
end package spriteengine_package;

package body spriteengine_package is
	
	function return_in_range (signal s: in sprite; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0)) return boolean is
	begin
		return s.visible and vga_row < s.y0 + (s.size * s.scaling_factor_y) and vga_row >= s.y0 and vga_col < s.x0 + (s.size * s.scaling_factor_x) and vga_col >= s.x0;
	end function;

	function calc_addr_f (signal s: in sprite; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0)) return std_logic_vector is
	begin
		if (s.size = 32) then
			return STD_LOGIC_VECTOR(resize(
							(shift_left ((vga_row - s.y0) / s.scaling_factor_y, 5)) + -- Find linear offset of row (pixels per row * row number)
							((vga_col + 1 - s.x0) / (s.scaling_factor_x)), -- Pixel to draw in the current row (row found in above line)
						12));
		else -- size is 64
			return STD_LOGIC_VECTOR(resize(
							(shift_left ((vga_row - s.y0) / s.scaling_factor_y, 6)) +
							((vga_col + 1 - s.x0) / (s.scaling_factor_x)),
						12));
		end if;
	end function;
	
	
	function get_active_idx (signal sprites: in all_sprites; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0)) return natural is
	begin
		for i in 0 to sprites'length - 1 loop
			if (unsigned(vga_row) < sprites(i).y0 + (sprites(i).size * sprites(i).scaling_factor_y) and unsigned(vga_row) >= sprites(i).y0 and unsigned(vga_col) < sprites(i).x0 + (sprites(i).size * sprites(i).scaling_factor_x) and unsigned(vga_col) >= sprites(i).x0) then
				return i;
			end if;
		end loop;
		
		return 0;
	end function;
	
end package body;	