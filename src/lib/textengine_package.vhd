library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package textengine_package is 

	-- The VGA screen has a resolution of 640x480 pixels
	-- if we assume the smallest possable character size, 8x8 pixels
	-- then we have a maximum of 60 character rows, and 80 character columns.
	-- Thus we will have an array of 60 textengine_row records
	-- that external modules can place text into.
	type textengine_row is record
		row			: unsigned(9 downto 0);
		col			: unsigned(9 downto 0);
		char_row	: unsigned(5 downto 0);
		char_col	: unsigned(6 downto 0);
		txt			: string(1 to 80);
		txt_len		: unsigned(6 downto 0); -- number of characters in string
		r			: unsigned(3 downto 0);
		g			: unsigned(3 downto 0);
		b			: unsigned(3 downto 0);
	end record textengine_row;
	constant init_textengine_row : textengine_row := 
		(
			row => to_unsigned(0, textengine_row.row'length), 
			col => to_unsigned(0, textengine_row.col'length), 
			char_row => to_unsigned(0, textengine_row.char_row'length), 
			char_col => to_unsigned(0, textengine_row.char_col'length), 
			txt => (others => '0'),
			txt_len => to_unsigned(0, textengine_row.txt_len'length),
			r => "1111",
			g => "1111",
			b => "1111"
		);		
	type textengine_vector is array (59 downto 0) of textengine_row;
	
		-- function to map character to char_rom address
	function char2rom(c : in character) return unsigned;

	
	component textengine is
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
	end component;	
	
end package;

package body textengine_package is
	-- function to map character to char_rom address
	function char2rom(c : in character := '!') return unsigned is
	begin
		case c is
			when '@' => return o"00";
			
			when 'A' | 'a' => return o"01";
			when 'B' | 'b' => return o"02";
			when 'C' | 'c' => return o"03";
			when 'D' | 'd' => return o"04";
			when 'E' | 'e' => return o"05";
			when 'F' | 'f' => return o"06";
			when 'G' | 'g' => return o"07";
			when 'H' | 'h' => return o"10";
			when 'I' | 'i' => return o"11";
			when 'J' | 'j' => return o"12";
			when 'K' | 'k' => return o"13";
			when 'L' | 'l' => return o"14";
			when 'M' | 'm' => return o"15";
			when 'N' | 'n' => return o"16";
			when 'O' | 'o' => return o"17";
			when 'P' | 'p' => return o"20";
			when 'Q' | 'q' => return o"21";
			when 'R' | 'r' => return o"22";
			when 'S' | 's' => return o"23";
			when 'T' | 't' => return o"24";
			when 'U' | 'u' => return o"25";
			when 'V' | 'v' => return o"26";
			when 'W' | 'w' => return o"27";
			when 'X' | 'x' => return o"30";
			when 'Y' | 'y' => return o"31";
			when 'Z' | 'z' => return o"32";
			
			when '[' => return o"33";
			when ']' => return o"35";
			
			when ' ' => return o"40";
			
			when '!' => return o"41";
			when '"' => return o"42";
			when '#' => return o"43";
			when '$' => return o"44";
			when '%' => return o"45";
			when '&' => return o"46";
			when ''' => return o"47";
			when '(' => return o"50";
			when ')' => return o"51";
			when '*' => return o"52";
			when '+' => return o"53";
			when ',' => return o"54";
			when '-' => return o"55";
			when '.' => return o"56";
			when '/' => return o"57";
			
			when '0' => return o"60";
			when '1' => return o"61";
			when '2' => return o"62";
			when '3' => return o"63";
			when '4' => return o"64";
			when '5' => return o"65";
			when '6' => return o"66";
			when '7' => return o"67";
			when '8' => return o"70";
			when '9' => return o"71";
			
			when others => return o"41"; -- unknown character is displays exclimation (!)
		end case;
	end function;
	
end package body;