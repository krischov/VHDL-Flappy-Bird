library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity randomNumGen is
	port(
		clk							: 		in std_logic;
		seed          :   in natural range 1 to 1023;
		randNum  					: 		out std_logic_vector(3 downto 0)
	);
end entity randomNumGen;

architecture a of randomNumGen is
	signal temp : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(seed, 10));
begin
	process (clk)
	variable t_upper      : integer range 0 to 9;
	variable finalRandNum : std_logic_vector(3 downto 0);
	
	begin
	if(rising_edge(clk)) then
		temp(0) <= temp(9); 
		temp(1) <= temp(0);
		temp(2) <= temp(1);
		temp(3) <= temp(2) xor temp(9);
		temp(4) <= temp(3);
		temp(5) <= temp(4);
		temp(6) <= temp(5);
		temp(7) <= temp(6);
		temp(8) <= temp(7);
		temp(9) <= temp(8);
		 
		t_upper := to_integer(unsigned(temp(2 downto 0)));
		if(t_upper <= 2) then
      finalRandNum := temp(t_upper) & temp(t_upper + 3) & temp(t_upper + 4) & temp(t_upper + 2);
    else
      finalRandNum := temp(t_upper downto t_upper - 3);
	  end if;
	  
	 randNum <= finalRandNum;
	end if;

	end process;	
end architecture;
		

