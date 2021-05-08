library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

library lib;
use lib.textengine_package.all;

entity ColumnRowProcessor is
  port(dpSwitch, Clk: in std_logic;
    x_row, y_column: in unsigned(7 downto 0);
    D3F, D2F, D1F, D0F: out unsigned(7 downto 0));
end entity ColumnRowProcessor;

architecture a1 of ColumnRowProcessor is
begin
  process(Clk)
    variable d3, d2, d1, d0: unsigned(7 downto 0);
    begin
      if(rising_edge(Clk)) then
         if(dpSwitch = '0') then
				int2bcd(x_row, d3, d2, d1, d0);
				D3F <= d3;
				D2F <= d2;
				D1F <= d1;
				D0F <= d0;
			else 
				int2bcd(y_column, d3, d2, d1, d0);
				D3F <= d3;
				D2F <= d2;
				D1F <= d1;
				D0F <= d0;
			end if;
		end if;
    end process;
end architecture a1;