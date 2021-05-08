library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

library lib;
use lib.textengine_package.all;

entity ColumnRowProcessor is
  port(dpSwitch, Clk: in std_logic;
    x_row, y_column: in std_logic_vector(7 downto 0);
    d3, d2, d1, d0: out std_logic_vector(7 downto 0));
end entity ColumnRowProcessor;

architecture a1 of ColumnRowProcessor is
begin
  process(Clk)
    begin
      if(rising_edge(Clk)) then
         if(dpSwitch = '0') then
				int2bcd(x_row);
			else 
				int2bcd(y_column);
			end if;
    end process;
end architecture a1;