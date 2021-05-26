library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package spriteengine_package is 
	constant bird0 	: natural range 0 to 31 := 0;
	constant crackpipe: natural range 0 to 31 := 1;
	constant tree0 	: natural range 0 to 31 := 2;
	constant tree1 	: natural range 0 to 31 := 3;
	constant grass 	: natural range 0 to 31 := 4;
	constant toppipe  : natural range 0 to 31 := 5;
	constant cursor   : natural range 0 to 31 := 6;
	constant bird0_tmap : natural range 0 to 31 := 7;
	constant crackpipe_tmap : natural range 0 to 31 := 8;
	constant toppipe_tmap : natural range 0 to 31 := 9;
	constant heart 	: natural range 0 to 31 := 10;
	constant coin : natural range 0 to 31 := 11;
	constant exitbtn : natural range 0 to 31 := 12;
	constant orangemenu : natural range 0 to 31 := 13;
	constant scrorescreen : natural range 0 to 31 := 14;
	
    
	-- Transparancy Maps
	constant bird_transparency : std_logic_vector(1023 downto 0) := (
	x"fefefefefefefefefefefefefefefefefee002fefe0000fefe0000fefc00007efc00007ef000001ef000001ec000001ec000001ec000001ec0000006c00000068000000080000000800000068000000680000006c000001ec000001efe803efefe803efefefefefefefefefefefefefefefefefefefefefefefefefefefefefe"
	);
	constant top_pipe_transparency : std_logic_vector(4095 downto 0) := (
    x"e00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
	);
	constant bottom_pipe_transparency : std_logic_vector(4095 downto 0) := (
    x"e00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001ee00000000000001e"
	);
	
	type sprite_output_array is array(0 to 14) of std_logic_vector(15 downto 0);
	type sprite_addr_array is array (0 to 14) of std_logic_vector(11 downto 0);
	
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
		visible 			: boolean;
		underflow			: boolean;
		passed_pipe			: boolean;
	end record sprite;
	
	type all_sprites is array(natural range <>) of sprite;

	function get_active_idx (signal sprites: in all_sprites; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0)) return integer;
	function return_in_range (signal s: in sprite; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0)) return boolean;
	function calc_addr_f (signal s: in sprite; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0)) return std_logic_vector;
end package spriteengine_package;

package body spriteengine_package is
	
	function return_in_range (signal s: in sprite; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0)) return boolean is
		variable x0: unsigned(11 downto 0) := resize(s.x0, 12);
		variable y0: unsigned(11 downto 0) := resize(s.y0, 12);
		
		variable w: unsigned(11 downto 0) := to_unsigned(s.size * s.scaling_factor_x, 12);
		variable h: unsigned(11 downto 0) := to_unsigned(s.size * s.scaling_factor_y, 12);
		
		variable x1: unsigned(11 downto 0) := x0 + w;
		variable y1: unsigned(11 downto 0) := y0 + h;
	
	begin
		if (s.underflow = false) then
			return s.visible and ((vga_row >= y0) and (vga_row < y1) and (vga_col >= x0) and (vga_col < x1));
		else
			-- NOTE: We rely on unsigned 10-bit overflow for x0 and x1 !!
			return s.visible and ((vga_row < y1) and (vga_row >= y0) and (2**10-1 - w <= x0(9 downto 0)) and (vga_col < x1(9 downto 0)));
		end if;
	end function;

	function calc_addr_f (signal s: in sprite; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0)) return std_logic_vector is
	variable row : unsigned(11 downto 0) := resize(vga_row, 12) - resize(s.y0, 12);
	variable col : unsigned(11 downto 0) := resize(vga_col, 12) - resize(s.x0, 12);
	variable scaleY: unsigned(11 downto 0) := to_unsigned(s.scaling_factor_y, 12);
	variable scaleX: unsigned(11 downto 0) := to_unsigned(s.scaling_factor_x, 12);
	
	-- The below vairbales are used for underflow address calculation
	
	variable x0: unsigned(11 downto 0) := resize(s.x0, 12);
	variable y0: unsigned(11 downto 0) := resize(s.y0, 12);
	
	variable w: unsigned(11 downto 0) := to_unsigned(s.size * s.scaling_factor_x, 12);
	variable h: unsigned(11 downto 0) := to_unsigned(s.size * s.scaling_factor_y, 12);
	
	variable x1: unsigned(11 downto 0) := x0 + w;
	variable y1: unsigned(11 downto 0) := y0 + h;	
		
	begin
			if (s.underflow = true) then
				col := vga_col + (1023 - x0);
				if(s.size = 16) then
					return STD_LOGIC_VECTOR(shift_left(row / scaleY, 4) + ((col + 1) / scaleX));
				elsif (s.size = 32) then
					return STD_LOGIC_VECTOR(shift_left(row / scaleY, 5) + ((col + 1) / scaleX));
				else -- size is 64
					return STD_LOGIC_VECTOR(shift_left(row / scaleY, 6) + ((col(9 downto 0) + 1) / scaleX));
				end if;	
			end if;
		
			if(s.size = 16) then
				return STD_LOGIC_VECTOR(shift_left(row / scaleY, 4) + ((col + 1) / scaleX));
			elsif (s.size = 32) then
				return STD_LOGIC_VECTOR(shift_left(row / scaleY, 5) + ((col + 1) / scaleX));
			else -- size is 64
				return STD_LOGIC_VECTOR(shift_left(row / scaleY, 6) + ((col(9 downto 0) + 1) / scaleX));
			end if;	
	end function;
	
	
	function get_active_idx (signal sprites: in all_sprites; signal vga_row : in unsigned(9 downto 0); signal vga_col : in unsigned(9 downto 0)) return integer is
		variable x0: unsigned(11 downto 0);
		variable y0: unsigned(11 downto 0);
		
		variable w: unsigned(11 downto 0);
		variable h: unsigned(11 downto 0);
		
		variable x1: unsigned(11 downto 0);
		variable y1: unsigned(11 downto 0);
	begin
		for i in 0 to sprites'length - 1 loop
			x0 := resize(sprites(i).x0, 12);
			y0 := resize(sprites(i).y0, 12);
			
			w := to_unsigned(sprites(i).size * sprites(i).scaling_factor_x, 12);
			h := to_unsigned(sprites(i).size * sprites(i).scaling_factor_y, 12);
			
			x1 := x0 + w;
			y1 := y0 + h;
		
			if (not sprites(i).underflow) then
				if (((vga_row >= y0) and (vga_row < y1) and (vga_col + 1 >= x0) and (vga_col < x1))) then
					return i;
				end if;
			else
				-- NOTE: We rely on unsigned 10-bit overflow for x0 and x1 !!
				if (((vga_row >= y0) and (vga_row < y1) and (2**10-1 - w <= x0(9 downto 0)) and (vga_col < x1(9 downto 0)))) then
					return i;
				end if;
			end if;
		end loop;
		
		return -1;
	end function;
	
end package body;	