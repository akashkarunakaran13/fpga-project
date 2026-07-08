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
        // 13-byte market data message

        rx_valid = 1;

        #10; data_in = 8'h41; // Message Type ('A')
        #10; data_in = 8'h00;
        #10; data_in = 8'h00;
        #10; data_in = 8'h00;
        #10; data_in = 8'h01; // Order ID = 1

        #10; data_in = 8'h00;
        #10; data_in = 8'h00;
        #10; data_in = 8'h00;
        #10; data_in = 8'h64; // Price = 100

        #10; data_in = 8'h00;
        #10; data_in = 8'h00;
        #10; data_in = 8'h00;
        #10; data_in = 8'h0A; // Quantity = 10

        #10;
        rx_valid = 0;

        #50;

        $finish;

    end

endmodule
