library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package spriteengine_package is 

	constant resolution_w : natural := 640; -- vga is 640 pixels width
	constant resolution_h : natural := 480; -- vga is 480 pixels height
	constant tile_size : natural := 32;
	constant max_tiles_x: natural := resolution_w / tile_size; -- max number of tiles in the horizontal direction
	constant max_tiles_y: natural := resolution_h / tile_size; -- max number of tiles in the vertical direction
	-- a pixel is two bytes. It has the following structure:
	--	0000 0000    0000 0000
	--    R    G       B    Z
	-- Where R, G, B are the values of the 4 bit colour channels
	-- Z is the z-index/transparancy of the tile. 0 means the tile's colour
	-- is not drawn, "1111" means the tile is at the forefront of all content.
	type pixel is array (1 downto 0) of unsigned(7 downto 0);
	type pixelarray is array (tile_size - 1 downto 0, tile_size - 1 downto 0) of pixel;
	
	type spriteengine_tile is record
		pixels: pixelarray;
	end record spriteengine_tile;
	
	type tilearray is array (max_tiles_x - 1 to 0, max_tiles_y - 11 to 0) of spriteengine_tile;
	type spriteengine_sprite is record
		tiles: tilearray;
		-- the top left tile, and bottom right tile; respectively
		x0: natural range 0 to max_tiles_x;
		y0: natural range 0 to max_tiles_y;
		x1: natural range 0 to max_tiles_x;
		y1: natural range 0 to max_tiles_y;
	end record spriteengine_sprite;

end package;


package body spriteengine_package is

end package body;