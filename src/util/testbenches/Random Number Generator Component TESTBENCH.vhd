library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TEST is
end entity TEST;

architecture a of TEST is
  signal t_Clk                     :  std_logic := '0';
  signal t_randNumX0               : 	std_logic_vector(8 downto 0) := "000000000";
	signal	t_randNumYScaleMultiplier	:		std_logic_vector(3 downto 0) := "0000";
	
	component randomNumGen is
	 generic (seed: NATURAL range 1 to 13);
	 port(
		  clk							            : 	in std_logic;
		  randNumX0  					        : 	out std_logic_vector(8 downto 0);
		  randNumYScaleMultiplier	:		out std_logic_vector(3 downto 0)
	 );
	 end component randomNumGen;
begin
  
  DUT: randomNumGen generic map (seed => 7) port map (t_Clk, t_randNumX0, t_randNumYScaleMultiplier);
  t_Clk <= not t_Clk after 5 ns;
  
end architecture a;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TEST is
end entity TEST;

architecture a of TEST is
  signal t_Clk                     :  std_logic := '0';
  signal t_randNumX0               : 	std_logic_vector(8 downto 0) := "000000000";
	signal	t_randNumYScaleMultiplier	:		std_logic_vector(3 downto 0) := "0000";
	
	component randomNumGen is
	 generic (seed: NATURAL range 1 to 13);
	 port(
		  clk							            : 	in std_logic;
		  randNumX0  					        : 	out std_logic_vector(8 downto 0);
		  randNumYScaleMultiplier	:		out std_logic_vector(3 downto 0)
	 );
	 end component randomNumGen;
begin
  
  DUT: randomNumGen generic map (seed => 7) port map (t_Clk, t_randNumX0, t_randNumYScaleMultiplier);
  t_Clk <= not t_Clk after 5 ns;
  
end architecture a;

