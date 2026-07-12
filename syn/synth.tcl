# AMD Vivado non-project synthesis for the streaming decoder.
#   vivado -mode batch -source syn/synth.tcl
# Default part is a free-WebPACK Artix-7; override with your target UltraScale+
# part for HFT-representative numbers.
set part xc7a35tcpg236-1

read_verilog -sv {
    rtl/axis_skid_buffer.sv
    rtl/byte_receiver.sv
    rtl/parser.sv
    rtl/message_decoder.sv
    rtl/top.sv
}
read_xdc syn/constraints.xdc

synth_design -top top -part $part
opt_design

report_timing_summary -file syn/timing_summary.rpt
report_utilization    -file syn/utilization.rpt
report_timing -max_paths 10 -file syn/timing_paths.rpt
puts "Synthesis complete. See syn/*.rpt"
