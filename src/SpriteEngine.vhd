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
	
	component rom_ctrl is
		generic (mif_file : STRING; address_size: NATURAL range 0 to 13; words : NATURAL range 0 to 4096);
		port
		(
			address	: in STD_LOGIC_VECTOR((address_size-1) downto 0);
			clock		: in STD_LOGIC  := '1';
			q			: out STD_LOGIC_VECTOR (15 downto 0)
		);
	end component rom_ctrl;
	
begin
	rom0: rom_ctrl generic map("../src/bird0.MIF", 10, 1024) port map (sprite_addrs(bird0)(9 downto 0), clk, sprites_out(bird0));
	rom1: rom_ctrl generic map("../src/crackpipe.MIF", 12, 4096) port map (sprite_addrs(crackpipe), clk, sprites_out(crackpipe));
	rom2: rom_ctrl generic map("tree0.MIF", 12, 4096) port map (sprite_addrs(tree0), clk, sprites_out(tree0));
	rom4: rom_ctrl generic map("grass.MIF", 10, 1024) port map (sprite_addrs(grass)(9 downto 0), clk, sprites_out(grass));
	
	
end architecture a;