module top (

    input  logic       clk,
    input  logic       rst_n,
    input  logic       rx_valid,
    input  logic [7:0] data_in,

    output logic [7:0] stored_byte,
    output logic [3:0] byte_count,
    output logic       packet_done

);

    logic byte_valid;
    logic reg_en;
    logic count_en;

assign packet_done = (byte_count == 4);

    byte_receiver u_byte_receiver (
        .clk(clk),
        .rst_n(rst_n),
        .rx_valid(rx_valid),
        .byte_valid(byte_valid)
    );

    fsm u_fsm (
        .clk(clk),
        .rst_n(rst_n),
        .byte_valid(byte_valid),
        .reg_en(reg_en),
        .count_en(count_en),
        .done()
    );

    register u_register (
        .clk(clk),
        .rst_n(rst_n),
        .en(reg_en),
        .data_in(data_in),
        .data_out(stored_byte)
    );

    counter u_counter (
        .clk(clk),
        .rst_n(rst_n),
        .en(count_en),
        .count(byte_count)
    );

endmodule
