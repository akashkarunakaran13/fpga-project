# Block-level timing constraints for `top`.
# Clock constraint is a starting point for STA; adjust to your target.
create_clock -name clk -period 4.000 [get_ports clk]     ;# 250 MHz constraint

# Assume registered I/O either side (~40% of period) for a representative STA.
set_input_delay  -clock clk 1.600 [get_ports {rst_n s_axis_tvalid s_axis_tdata[*] m_axis_tready}]
set_output_delay -clock clk 1.600 [get_ports {s_axis_tready m_axis_tvalid m_axis_tdata[*] m_axis_tlast}]
