#********1*********2*********3*********4*********5*********6*********7*********8
# File : top_meteo_de0cv.sdc
#_______________________________________________________________________________
#
# Revision history
#
# Name          Date        Observations
# ------------------------------------------------------------------------------
# -            01/02/2022   First version.
# ------------------------------------------------------------------------------
#_______________________________________________________________________________
#
# Description
# Synopsys Design Constraints for the Meteostation based on BME280 and DE0-CV
#_______________________________________________________________________________
#
# (c) Copyright Universitat de Barcelona, 2022
#
#********1*********2*********3*********4*********5*********6*********7*********/i_PLL|altpll_component|auto_generated|pll1|clk[0]

#
#create_clock -name clk50MHz -period 20.0 [get_ports i_clk]
#create_clock -name clk10MHz -period 100.0 [get_ports i_SCLK]
#derive_pll_clocks -create_base_clocks
#set_clock_groups -asynchronous -group [get_clocks {clk50MHz}] -group [get_clocks {i_PLL|pll_cv_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
#set_clock_groups -asynchronous -group [get_clocks {clk50MHz}] -group [i_PLL|altpll_component|auto_generated|pll1|clk[0].gpll~PLL_OUTPUT_COUNTER|divclk}]

#set_input_delay -clock clk50MHz 5.0 [get_ports {SW*}]
#set_output_delay -clock clk50MHz 5.0 [get_ports {seg* ErrorFlag}]

#set_input_delay -clock {i_PLL|pll_cv_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} 1.0 [get_ports {o_MISO}]
#set_output_delay -clock {i_PLL|pll_cv_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} 1.0 [get_ports {i_CS}]
#set_output_delay -clock {i_PLL|pll_cv_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} 1.0 [get_ports {i_SCLK}]
#set_output_delay -clock {i_PLL|pll_cv_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} 1.0 [get_ports {i_MOSI}]

#clk of 80MHz
create_clock -name clk -period 12.5 [get_ports clk]
create_clock -name clk10MHz -period 100.0 [get_ports i_SCLK]
create_clock -name clk50MHz -period 20.0 [get_ports i_clk]
derive_pll_clocks
derive_clock_uncertainty
set_input_delay 0 -clock clk [all_inputs]
set_output_delay 0 -clock clk [all_outputs]

#set_false_path -fall_from [get_ports {}] -to [all_registers]
set_false_path -from {rstregs[2]} -to {SPI_MODULE:spi|SPI_SLAVE:slave*}