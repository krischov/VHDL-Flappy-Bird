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
		size 					: natural range 0 to 64;
		y0						: unsigned(9 downto 0);
		x0						: unsigned(9 downto 0);
		address				: std_logic_vector(11 downto 0);
		index 				: natural range 0 to 31;
		colours				: std_logic_vector(15 downto 0);
		in_range				: boolean;
		scaling_factor_x 	: natural range 0 to 16;
		scaling_factor_y 	: natural range 0 to 16;
	end record sprite;
	
	type all_sprites is array(0 to 1) of sprite;
	
	procedure calc_in_range (signal s: inout sprite; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0));
	procedure calc_addr (signal s: inout sprite; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0));
	
end package spriteengine_package;

package body spriteengine_package is
	
	procedure calc_in_range (signal s: inout sprite; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0)) is
	begin
		s.in_range <= unsigned(vga_row) < s.y0 + (s.size * s.scaling_factor_y) and unsigned(vga_row) >= s.y0 and unsigned(vga_col) < s.x0 + (s.size * s.scaling_factor_x) and unsigned(vga_col) >= s.x0;
	end procedure;
	
	procedure calc_addr (signal s: inout sprite; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0)) is
	begin
		if (s.size = 32) then
			s.address <= STD_LOGIC_VECTOR(resize(
							(shift_left ((vga_row - s.y0), 5 - 1 + s.scaling_factor_x) / s.scaling_factor_y) +
							((vga_col + 1 - s.x0) / (s.scaling_factor_x)),
						12));
		elsif (s.size = 64) then
			s.address <= STD_LOGIC_VECTOR(resize(
					(shift_left ((vga_row - s.y0), 6 - 1 + s.scaling_factor_x) / s.scaling_factor_y) + 
					((vga_col + 1 - s.x0) / (s.scaling_factor_x)),
				12));
		end if;
	end procedure;
	
end package body;	