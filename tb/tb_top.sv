module tb_top;

    logic clk;
    logic rst_n;
    logic rx_valid;
    logic [7:0] data_in;

    logic [7:0] stored_byte;
    logic [3:0] byte_count;
    logic packet_done;

    top dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx_valid(rx_valid),
        .data_in(data_in),
        .stored_byte(stored_byte),
        .byte_count(byte_count),
        .packet_done(packet_done)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("top.vcd");
        $dumpvars(0, tb_top);

        clk      = 0;
        rst_n    = 0;
        rx_valid = 0;
        data_in  = 8'h00;

        #10;
        rst_n = 1;

        // Byte 1
        #10;
        rx_valid = 1;
        data_in  = 8'h41;

        // Byte 2
        #10;
        data_in = 8'h10;

        // Byte 3
        #10;
        data_in = 8'h64;

        // Byte 4
        #10;
        data_in = 8'h05;

        #10;
        rx_valid = 0;

        #50;

        $finish;

    end

endmodule
