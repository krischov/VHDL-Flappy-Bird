library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

library lib;
use lib.textengine_package.all;

entity ColumnRowProcessor is
  port(ToggleButtonXY, TestModeSwitch, Clk: in std_logic;
	 TestValueSetSwitch: in std_logic_vector(1 downto 0);
    x_row, y_column: in unsigned(9 downto 0);
    Thousands, Hundreds, Tens, Ones: out unsigned(7 downto 0));
end entity ColumnRowProcessor;

architecture a1 of ColumnRowProcessor is
begin
  process(Clk)
    variable thou, hund, ten, one: unsigned(7 downto 0);
	 variable current_Value: unsigned(9 downto 0);
    begin
      if(rising_edge(Clk)) then
			if(TestModeSwitch = '0') then
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
			else
				case TestValueSetSwitch is
					when "00" => current_Value := "0000000001";
					when "01" => current_Value := "0000000010";
					when "10" => current_Value := "0000000011";
					when "11" => current_Value := "0000000100";
				end case;
				int2bcd(resize(current_Value, 13), thou, hund, ten, one);
				Thousands <= thou;
				Hundreds <= hund;
				Tens <= ten;
				Ones <= one;
			end if;
		end if;
    end process;
end architecture a1;