module tb_counter;

    logic clk;
    logic rst_n;
    logic [3:0] count;

    // Connect our counter (the "device under test")
    counter dut (
        .clk   (clk),
        .rst_n (rst_n),
        .count (count)
    );

    // Clock generator: flip clk every 5 time units -> a full tick every 10
    always #5 clk = ~clk;

    // The test sequence
    initial begin
        $dumpfile("counter.vcd");   // waveform output file
        $dumpvars(0, tb_counter);   // record all signals

        clk   = 0;
        rst_n = 0;                  // start in reset
        #12;                        // hold reset a moment
        rst_n = 1;                  // release reset - counting begins

        #200;                       // let it run for a while
        $finish;                    // end the simulation
    end

endmodule

