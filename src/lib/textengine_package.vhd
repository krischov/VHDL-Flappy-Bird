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
		txt			: string(1 to 80);		-- note string should be NUL terminated!
		txt_len		: unsigned(6 downto 0); -- number of characters in string (minus NUL byte)
		scale		: unsigned(3 downto 0); -- scale character with 1 being 8x8, 2 being 16x16, 3 being 32x32; 4 being 64x64 etc.
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
			scale => to_unsigned(0, textengine_row.scale'length),
			r => "1111",
			g => "1111",
			b => "1111"
		);		
	type textengine_vector is array (59 downto 0) of textengine_row;
	
	
	-- add the string s to the text vector txt_vector
	procedure str2text(
		signal txt_vector	: inout textengine_vector; 
		in_char_row			: in unsigned(5 downto 0);
		in_char_col			: in unsigned(6 downto 0);
		in_scale			: in unsigned(3 downto 0);
		in_r				: in unsigned(3 downto 0);
		in_g				: in unsigned(3 downto 0);
		in_b				: in unsigned(3 downto 0);
		s 					: in string
	);
		
	-- wrapper for str2text that converts integer paramaters to unsigned 
	procedure str2text(
		signal txt_vector	: inout textengine_vector; 
		in_char_row			: in integer;
		in_char_col			: in integer;
		in_scale			: in integer;
		in_r				: in unsigned(3 downto 0);
		in_g				: in unsigned(3 downto 0);
		in_b				: in unsigned(3 downto 0);
		s 					: in string
	);
	
	
	-- function to return a string of variable length with only the 
	-- data you want filled (remaining bytes are nulled out)
	function var_len_str(s : in string; total_len : positive range 1 to 80) return string;
	
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

	-- function to return a string of variable length with only the 
	-- data you want filled (remaining bytes are nulled out)
	function var_len_str(s : in string; total_len : positive range 1 to 80) return string is
		variable result : string(1 to total_len) := (others => nul);
	begin
		result(1 to s'length) := s;
		return result;
	end function;

	-- add the string s to the text vector txt_vector
	procedure str2text(
		signal txt_vector	: inout textengine_vector; 
		in_char_row			: in unsigned(5 downto 0);
		in_char_col			: in unsigned(6 downto 0);
		in_scale			: in unsigned(3 downto 0);
		in_r				: in unsigned(3 downto 0);
		in_g				: in unsigned(3 downto 0);
		in_b				: in unsigned(3 downto 0);
		s 					: in string
	) is
		variable len : positive range 1 to 127;
		-- string index must start @ 1 (doens't start at 0)
		variable start_idx : positive range 1 to 127;
		variable end_idx : positive range 1 to 127;
	begin
		
		if (s(s'length) = nul) then
		-- find the actual length of the string (strign ends at last printable character before null)
			for i in s'length - 1 downto 1 loop
				if (s(i) /= nul and s(i + 1) = nul) then
					len := i;
					exit;
				end if;
			end loop;
		else
			-- the last character is not null, thus the string does not contain the null character
			-- so the actual length of the string is the length of the string
			len := s'length;
		end if;
		
		start_idx := to_integer(in_char_col) + 1;
		end_idx := start_idx + s'length - 1;
		
		txt_vector(to_integer(in_char_row)) <=
			(
				row => "0000000000",
				col => "0000000000",
				char_row => in_char_row, 
				char_col => in_char_col, 
				txt_len => to_unsigned(len, 7),
				txt => (others => nul), -- initalise everything to null
				scale => in_scale,
				r => in_r,
				g => in_g,
				b => in_b
			);
			
			txt_vector(to_integer(in_char_row)).txt(start_idx to end_idx) <= s;
	
	end procedure;

	-- wrapper for str2text that converts integer paramaters to unsigned 
	procedure str2text(
		signal txt_vector	: inout textengine_vector; 
		in_char_row			: in integer;
		in_char_col			: in integer;
		in_scale			: in integer;
		in_r				: in unsigned(3 downto 0);
		in_g				: in unsigned(3 downto 0);
		in_b				: in unsigned(3 downto 0);
		s 					: in string
	) is
	begin
		str2text(txt_vector, 
			to_unsigned(in_char_row, textengine_row.char_row'length),
			to_unsigned(in_char_col, textengine_row.char_col'length),
			to_unsigned(in_scale, textengine_row.scale'length),
			in_r, in_g, in_b, s);
	end procedure;

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