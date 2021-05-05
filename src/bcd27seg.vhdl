library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity bcd2seg is
	port(num: in unsigned(3 downto 0);
		Q: out unsigned(7 downto 0));
end entity;

architecture x of bcd2seg is
begin
		with num select
			Q <=	"11000000" when to_unsigned(0, 4), 
					"11111001" when to_unsigned(1, 4),
					"10100100" when to_unsigned(2, 4),
					"10110000" when to_unsigned(3, 4),
					"10011001" when to_unsigned(4, 4),
					"10010010" when to_unsigned(5, 4),
					"10000010" when to_unsigned(6, 4),
					"11111000" when to_unsigned(7, 4),
					"10000000" when to_unsigned(8, 4),
					"10011000" when to_unsigned(9, 4),
					"11111111" when others;
end architecture;
