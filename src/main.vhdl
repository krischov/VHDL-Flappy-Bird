library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
	port (signal clk : in std_ulogic;
		signal vga_row, vga_col : in std_logic_vector(9 downto 0);
		signal red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(3 downto 0));
		
end entity;

architecture x of main is 
	signal y0, x0: integer := 50;
	signal w, h: integer := 15;
begin

	process(clk)
	begin
		-- draw red square
		if (vga_row < std_logic_vector(to_unsigned(y0 + w, 10))) then
			red_out <= "1111";
			green_out <= "0000";
			blue_out <= "0000";
		else
			red_out <= "0000";
			green_out <= "0000";
			blue_out <= "0000";
		end if;
	end process;
end architecture;
