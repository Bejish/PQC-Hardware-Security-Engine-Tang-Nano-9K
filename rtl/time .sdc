create_clock -name clk -period 37.037 -waveform {0 18.518} [get_ports {clk}]

# Timing constraints
set_clock_uncertainty -setup 0.5 [get_clocks clk]
set_clock_uncertainty -hold 0.1 [get_clocks clk]

# Input/Output delays
set_input_delay -clock clk -max 5.0 [get_ports {data_in[*] data_valid rst_n}]
set_input_delay -clock clk -min 1.0 [get_ports {data_in[*] data_valid rst_n}]

set_output_delay -clock clk -max 5.0 [get_ports {led[*] threat_detected system_ready}]
set_output_delay -clock clk -min 1.0 [get_ports {led[*] threat_detected system_ready}]

# Multi-cycle path constraints for LED controller
set_multicycle_path -setup 2 -to [get_ports {led[*]}]
set_multicycle_path -hold 1 -to [get_ports {led[*]}]

# False path constraints for reset
set_false_path -from [get_ports rst_n]

# Power optimization
set_operating_conditions -grade c -model slow -speed 6
set_wire_load_model -name Small