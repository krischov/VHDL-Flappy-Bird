library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
	port (clk : in std_ulogic;
		vga_row, vga_col : in std_logic_vector(9 downto 0);
		red_out, green_out, blue_out : out std_ulogic
	);
		
end entity;

architecture x of main is 

begin

	red_out <= '1';
	green_out <= '0';
	blue_out <= '0';

end architecture;
