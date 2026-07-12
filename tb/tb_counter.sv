module tb_counter;

    logic clk;
    logic rst_n;
    logic [3:0] count;

    counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .count(count)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, tb_counter);

        clk = 0;
        rst_n = 0;

        #10;
        rst_n = 1;

        #200;

        $finish;
    end

endmodule
