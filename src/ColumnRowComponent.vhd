library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

library lib;
use lib.textengine_package.all;

entity ColumnRowProcessor is
  port(ToggleButtonXY, Clk: in std_logic;
    x_row, y_column: in unsigned(9 downto 0);
    Thousands, Hundreds, Tens, Ones: out unsigned(7 downto 0));
end entity ColumnRowProcessor;

architecture a1 of ColumnRowProcessor is
begin
  process(Clk)
    variable thou, hund, ten, one: unsigned(7 downto 0);
    begin
      if(rising_edge(Clk)) then
         if(ToggleButtonXY= '0') then
				int2bcd(resize(x_row, 13), thou, hund, ten, one);
				Thousands <= thou;
				Hundreds <= hund;
				Tens <= ten;
				Ones <= one;
			else 
				int2bcd(resize(y_column, 13), thou, hund, ten, one);
				Thousands <= thou;
				Hundreds <= hund;
				Tens <= ten;
				Ones <= one;
			end if;
		end if;
    end process;
end architecture a1;