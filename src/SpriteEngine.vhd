library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib;
use lib.spriteengine_package.all;

entity spriteengine is
	port(
		clk			: in std_ulogic;
		vga_row		: in unsigned(9 downto 0);
		vga_col		: in unsigned(9 downto 0);
		sprite_addrs	: in sprite_addr_array;
		sprites_out : out sprite_output_array
		);
		
end entity spriteengine;

architecture a of spriteengine is
	signal q0, q1 : std_logic_vector(15 downto 0);
	signal address0: std_logic_vector(9 downto 0);
	signal address1: std_logic_vector(11 downto 0);
	signal in_range0: boolean := false;
	signal in_range1: boolean := false;
	
	component rom_ctrl is
		generic (mif_file : STRING; address_size: NATURAL range 0 to 13; words : NATURAL range 0 to 4096);
		port
		(
			address	: in STD_LOGIC_VECTOR((address_size-1) downto 0);
			clock		: in STD_LOGIC  := '1';
			q			: out STD_LOGIC_VECTOR (15 downto 0)
		);
	end component rom_ctrl;
	
	
	--signal bird: sprite := (32, to_unsigned(100,10), to_unsigned(100,10), bird);
	--signal pipe: sprite := (64, to_unsigned(200, 10), to_unsigned(200,10), crackpipe);
	
begin
	rom0: rom_ctrl generic map("../src/bird0.MIF", 10, 1024) port map (sprite_addrs(bird0)(9 downto 0), clk, sprites_out(bird0));
	rom1: rom_ctrl generic map("../src/crackpipe.MIF", 12, 4096) port map (sprite_addrs(crackpipe), clk, sprites_out(crackpipe));
	
	--address0 <= STD_LOGIC_VECTOR(resize(shift_left ((vga_row - bird.y0), 5) + (vga_col + 1 - bird.x0), 10));
	--address1 <= STD_LOGIC_VECTOR(resize(shift_left ((vga_row - pipe.y0), 6) + (vga_col + 1 - pipe.x0), 12));
	
	--in_range0 <= unsigned(vga_row) < bird.y0 + bird.size and unsigned(vga_row) >= bird.y0 and unsigned(vga_col) < bird.x0 + bird.size and unsigned(vga_col) >= bird.x0 and q0(15 downto 12) /= "1111";
	--in_range1 <= unsigned(vga_row) < pipe.y0 + pipe.size and unsigned(vga_row) >= pipe.y0 and unsigned(vga_col) < pipe.x0 + pipe.size and unsigned(vga_col) >= pipe.x0 and q1(15 downto 12) /= "1111";
	
end architecture a;