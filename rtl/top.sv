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

logic [103:0] message;
logic          message_valid;
logic [7:0]   msg_type;
logic [31:0]  order_id;
logic [31:0]  price;
logic [31:0]  quantity;
logic         decoded_valid;
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

parser u_parser (
    .clk(clk),
    .rst_n(rst_n),
    .valid(byte_valid),
    .byte_in(data_in),
    .message(message),
    .message_valid(message_valid)
);
message_decoder u_message_decoder (
    .message(message),
    .message_valid(message_valid),
    .msg_type(msg_type),
    .order_id(order_id),
    .price(price),
    .quantity(quantity),
    .decoded_valid(decoded_valid)
);
endmodule
