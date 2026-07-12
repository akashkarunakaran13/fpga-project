module tb_register;

    logic clk;
    logic rst_n;
    logic en;
    logic [7:0] data_in;
    logic [7:0] data_out;
    register dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .data_in(data_in),
        .data_out(data_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("register.vcd");
        $dumpvars(0, tb_register);

        clk = 0;
        rst_n = 0;
        en = 0;
        data_in = 8'h00;

        #10;
        rst_n = 1;

        #10;
        en = 1;
        data_in = 8'h41;

        #10;
        data_in = 8'h55;

        #10;
        en = 0;
        data_in = 8'hAA;

        #20;
        $finish;
    end

endmodule
