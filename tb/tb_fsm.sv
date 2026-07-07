module tb_fsm;

    logic clk;
    logic rst_n;
    logic byte_valid;

    logic reg_en;
    logic count_en;
    logic done;

    fsm dut (
        .clk(clk),
        .rst_n(rst_n),
        .byte_valid(byte_valid),
        .reg_en(reg_en),
        .count_en(count_en),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("fsm.vcd");
        $dumpvars(0, tb_fsm);

        clk = 0;
        rst_n = 0;
        byte_valid = 0;

        #10;
        rst_n = 1;

        #10;
        byte_valid = 1;

        #10;
        byte_valid = 0;

        #40;

        $finish;
    end

endmodule
