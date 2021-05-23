library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib;
use lib.textengine_package.all;

entity textengine is
	port (
		clk : in std_ulogic;
		txtvec : in textengine_vector;
		row: in unsigned(9 downto 0);
		col: in unsigned(9 downto 0);
		
		r: out unsigned(3 downto 0);
		g: out unsigned(3 downto 0);
		b: out unsigned(3 downto 0);
		not_a: out unsigned(3 downto 0)
	);
end entity;

architecture x of textengine is
	
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
	
	-- signals
	signal char_row: unsigned(5 downto 0);
	signal char_col : unsigned(6 downto 0);
	
	signal txtrow : textengine_row;
	signal rom_addr: unsigned(5 downto 0);
	signal char_addr : unsigned(5 downto 0);
	
	signal scaled_row:  unsigned(2 downto 0);
	signal scaled_col:  unsigned(2 downto 0);
	
	signal pixel : std_logic;
begin
	char_rom0: char_rom port map (std_logic_vector(char_addr), std_logic_vector(scaled_row), std_logic_vector(scaled_col), clk, pixel);
	
	char_col <= resize(col / 8, 7);
	char_row <= resize(row / 8, 6);
		
	txtrow <= txtvec(txtvec(to_integer(char_row)).scale_index);

--	scaled_row <=	row(2 downto 0) when txtrow.scale = 1 else
--					row(3 downto 1) when txtrow.scale = 2;
--	
--	scaled_col <=	col(2 downto 0) when txtrow.scale = 1 else
--					col(3 downto 1) when txtrow.scale = 2;
--	
	
	scaled_row <=	row(3 downto 1);
	
	scaled_col <=	col(3 downto 1);
	
	char_addr <= char2rom(txtrow.txt(to_integer(char_col) + 1));

	
	r <= txtrow.r;
	g <= txtrow.g;
	b <= txtrow.b;
	--not_a <= (others => pixel) when (char_col + 1 > txtrow.char_col and char_col < txtrow.char_col + txtrow.txt_len) else "0000";
	not_a <= "0000" when txtvec(to_integer(char_row)).scale_index = -1
					else (others => pixel) when txtrow.txt((to_integer(char_col) + 1)) /= nul
					else "0000";
end architecture;
