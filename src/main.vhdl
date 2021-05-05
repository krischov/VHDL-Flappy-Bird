library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
	port (clk : in std_ulogic;
		 vga_row, vga_col : in unsigned(9 downto 0);
		 mouse_lbtn, mouse_rbtn : in std_logic;
		 mouse_row 			: in unsigned(9 DOWNTO 0); 
		 mouse_col 		: in unsigned(9 DOWNTO 0);       	
		 red_out, green_out, blue_out : OUT unsigned(3 downto 0));
end entity;

architecture x of main is 
	signal y0, x0: unsigned(9 downto 0) := to_unsigned(200, 10);
	signal w, h: unsigned(9 downto 0) := to_unsigned(100, 10);
	signal colour: unsigned(3 downto 0) := "0000";
	
	signal x : std_logic := '0';

	
	-- components go here 
	COMPONENT char_rom IS
	PORT
	(
		character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock				: 	IN STD_LOGIC ;
		rom_mux_output		:	OUT STD_LOGIC
	);
	END COMPONENT char_rom;
	
begin
	-- Try get some text on the screen
	cr1: char_rom port map ("000001", std_logic_vector(vga_row(2 downto 0)), std_logic_vector(vga_col(2 downto 0)), clk, x);
	
	
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
		if (vga_row < y0 + h and vga_row > y0 and 
				vga_col < x0 + w and vga_col > x0) then
			red_out <= colour;
			green_out <= "0000";
			blue_out <= "0000";
		elsif (vga_row > 7 and vga_row < 16 and vga_col > 7 and vga_col < 16) then
			red_out <= x & x & x & x;
			green_out <= x & x & x & x;
			blue_out <= x & x & x & x;
		else
			red_out <= "0000";
			green_out <= "0000";
			blue_out <= "0000";
		end if;
	end process;
end architecture;
