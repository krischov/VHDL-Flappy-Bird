library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity randomNumGen is
	generic (seed: NATURAL range 1 to 13);
	port(
		clk							: 		in std_logic;
		randNumX0  					: 		out std_logic_vector(8 downto 0);
		randNumYScaleMultiplier	:		out std_logic_vector(3 downto 0)
	);
end entity randomNumGen;

architecture a of randomNumGen is
	signal temp : std_logic_vector(8 downto 0) := std_logic_vector(to_unsigned(seed, 9));
begin
	process (clk)
	variable t_randNumYScale : std_logic_vector(3 downto 0);
	begin
	if(rising_edge(clk)) then 
	--Galois LFSR 9 bit
	--ten bit needs(taps at 2, 9) for max range
		temp(0) <= temp(8); --tap (8)
		temp(1) <= temp(0);
		temp(2) <= temp(1);
		temp(3) <= temp(2);
		temp(4) <= temp(3) xor temp(8); --tap (3)
		temp(5) <= temp(4);
		temp(6) <= temp(5);
		temp(7) <= temp(6);
		temp(8) <= temp(7);
		
		t_RandNumYScale := temp(3 downto 0);
		
		if (t_RandNumYScale > "1000") then
			t_RandNumYScale := std_logic_vector(shift_right(unsigned(t_RandNumYScale), 1));
		elsif (t_RandNumYScale) = "0000" then
			t_RandNumYScale := "0001";
		end if;
	end if;
	
	randNumX0 <= temp;
	randNumYScaleMultiplier <= t_RandNumYScale;
	end process;	
end architecture;
		

