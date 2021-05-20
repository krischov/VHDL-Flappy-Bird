library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package spriteengine_package is 
	--Sprite is 32 x 32

	type sprite is record
		size 		: natural range 0 to 64;
		y0						: unsigned(9 downto 0);
		x0						: unsigned(9 downto 0);		
	end record sprite;
	
end package spriteengine_package;