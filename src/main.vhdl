library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
	port (signal clk : in std_ulogic;
		signal vga_row, vga_col : in std_logic_vector(9 downto 0);
		 mouse_lbtn, mouse_rbtn : in std_logic;
		 mouse_row 			: in std_logic_vector(9 DOWNTO 0); 
		 mouse_col 		: in std_logic_vector(9 DOWNTO 0);       	
		signal red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(3 downto 0));
end entity;

architecture x of main is 
	signal y0, x0: integer := 200;
	signal w, h: integer := 100;
	signal colour: std_logic_vector(3 downto 0) := "0000";
begin

	process(clk)
	begin
		-- change background colour
		if (mouse_lbtn = '1') then
			colour <= "0101";
		elsif (mouse_rbtn = '1') then
			colour <= "1010";
		else
			colour <= "1111";
		end if;
		
		-- draw red square
		if (vga_row < std_logic_vector(to_unsigned(y0 + h, 10)) and vga_row > std_logic_vector(to_unsigned(y0, 10)) and 
				vga_col < std_logic_vector(to_unsigned(x0 + w, 10)) and vga_col > std_logic_vector(to_unsigned(x0, 10))) then
			red_out <= colour;
			green_out <= "0000";
			blue_out <= "0000";
		else
			red_out <= "0000";
			green_out <= "0000";
			blue_out <= "0000";
		end if;
	end process;
end architecture;
