
#  Create Input reference clocks

create_clock -name {clk} -period 20 [get_ports {clk}]

#  Now that we have created the base clocks,
#  derive_pll_clock is used to calculate all remaining clocks for PLLs
derive_pll_clocks -create_base_clocks
derive_clock_uncertainty