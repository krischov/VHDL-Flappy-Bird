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
		R				: out unsigned(3 downto 0);
		G				: out unsigned(3 downto 0);
		B				: out unsigned(3 downto 0);
		Z				: out unsigned(3 downto 0)
		);
		
end entity spriteengine;

architecture a of spriteengine is
	signal q0 : std_logic_vector(15 downto 0);
	signal address0: std_logic_vector(9 downto 0);
	signal in_range0: boolean := false;
	
	signal	size 					: natural range 0 to 64 := 32;
	signal	y0						: unsigned(9 downto 0) := to_unsigned(100, 10);
	signal 	x0						: unsigned(9 downto 0) := to_unsigned(100, 10);	
	
	component rom_ctrl is
		generic (mif_file : STRING; address_size: NATURAL range 0 to 13; words : NATURAL range 0 to 1024);
		port
		(
			address	: in STD_LOGIC_VECTOR((address_size-1) downto 0);
			clock		: in STD_LOGIC  := '1';
			q			: out STD_LOGIC_VECTOR (15 downto 0)
		);
	end component rom_ctrl;
begin
	rom0: rom_ctrl generic map("../src/bird0.MIF", 10, 1024) port map (address0, clk, q0);
	address0 <= STD_LOGIC_VECTOR(resize(shift_left ((vga_row - y0), 5) + (vga_col + 1 - x0), 10));
	
	in_range0 <= unsigned(vga_row) < y0 + size and unsigned(vga_row) >= y0 and unsigned(vga_col) < x0 + size and unsigned(vga_col) >= x0 and q0(15 downto 12) /= "1111";
	
	R <= unsigned(q0(3 downto 0)) when (unsigned(vga_row) < y0 + size and unsigned(vga_row) >= y0 and unsigned(vga_col) < x0 + size and unsigned(vga_col) >= x0 and q0(15 downto 12) /= "1111");
	G <= unsigned(q0(7 downto 4)) when (unsigned(vga_row) < y0 + size and unsigned(vga_row) >= y0 and unsigned(vga_col) < x0 + size and unsigned(vga_col) >= x0 and q0(15 downto 12) /= "1111");
	B <= unsigned(q0(11 downto 8)) when (unsigned(vga_row) < y0 + size and unsigned(vga_row) >= y0 and unsigned(vga_col) < x0 + size and unsigned(vga_col) >= x0 and q0(15 downto 12) /= "1111");
	Z <= "0000" when q0(15 downto 12)  = "0000" and in_range0 else "1111";
	
end architecture a;