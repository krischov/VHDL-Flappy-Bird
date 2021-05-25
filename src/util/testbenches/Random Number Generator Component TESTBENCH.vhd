library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TEST is
end entity TEST;

architecture a of TEST is
  signal t_Clk                     :  std_logic := '0';
  signal t_Seed                    :  natural range 1 to 1023 := 700;
  signal t_randNum                 : 	std_logic_vector(3 downto 0);
	
	component randomNumGen is
	port(
		clk							: 		in std_logic;
		seed          :   in natural range 1 to 1023;
		randNum  					: 		out std_logic_vector(3 downto 0)
	);
	 end component randomNumGen;
begin
  
  DUT: randomNumGen port map (t_Clk, t_Seed, t_randNum);
  t_Clk <= not t_Clk after 5 ns;
  
end architecture a;