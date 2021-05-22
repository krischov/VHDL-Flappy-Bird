library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity randomNumGen is
	generic (seed: NATURAL range 1 to 13);
	port(
		clk		: 		in std_logic;
		randNum  : 		out std_logic_vector(7 downto 0)
	);
end entity randomNumGen;

architecture a of randomNumGen is
	signal temp : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(seed, 8));
begin
	process (clk)
	begin
	if(rising_edge(clk)) then 
		temp(0) <= temp(7); 
		temp(1) <= temp(0);
		temp(2) <= temp(1) xor temp(7); -- tap 1
		temp(3) <= temp(2) xor temp(7); -- tap 2
		temp(4) <= temp(3) xor temp(7); -- tap 3
		temp(5) <= temp(4);
		temp(6) <= temp(5);
		temp(7) <= temp(6);
	end if;
	end process;
	randNum <= temp;
end architecture;
		