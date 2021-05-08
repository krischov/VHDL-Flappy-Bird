library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity dipswitch is
	port(	Clk : in std_logic;
			switches : in unsigned (9 downto 0);
			mouse_pos : out std_logic;
			red_control : out unsigned (2 downto 0);
			green_control : out unsigned (2 downto 0);
			blue_control : out unsigned (2 downto 0));
end entity dipswitch;

architecture behaviour of dipswitch is
	begin
		MOUSE: process (Clk)
			begin
			if(rising_edge(Clk)) then
				mouse_pos <=  switches(9);
			end if;
		end process MOUSE;
		
		RED: process (Clk)
			begin
			if (rising_edge(Clk)) then
				red_control <= switches(8 downto 6);
			end if;
		end process RED;
				
		GREEN: process (Clk)
			begin
			if (rising_edge(Clk)) then
				green_control <= switches(5 downto 3);
			end if;
		end process GREEN;
		
		BLUE: process (Clk)
			begin
			if (rising_edge(Clk)) then
				blue_control <= switches(2 downto 0);
			end if;
		end process BLUE;
end architecture behaviour;
		
		
		
		
					
		
			