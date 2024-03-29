library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pushbutton is
	port( Clk, pb0, pb1 : in std_logic;
			up, down : out std_logic);
end entity pushbutton;

architecture behaviour of pushbutton is
begin
	process (Clk)
		begin
		if (pb0 = '1') then
			up <= '0';
		else
			up <= '1';
		end if;
		if (pb1 = '1') then
			down <= '0';
		else
			down <= '1';
		end if;
	end process;
end architecture behaviour;