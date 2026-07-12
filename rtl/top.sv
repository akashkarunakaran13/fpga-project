// Streaming market-data message decoder (top level).
//
// Interface: minimal AXI4-Stream-compatible ready/valid on both ends
//   ingress  s_axis : byte stream                (tdata[7:0], tvalid, tready)
//   egress   m_axis : decoded fixed-layout record (tdata[103:0], tvalid, tready, tlast)
//
// Backpressure: the egress skid buffer registers m_axis and, when full, drives
// s_axis_tready low so ingress stalls and no decoded record can be lost. The
// datapath (byte_receiver -> parser -> message_decoder) advances only on an
// accepted ingress beat, so it stalls cleanly.
//
// Egress record layout (big-endian fields): {msg_type[7:0], order_id[31:0],
// price[31:0], quantity[31:0]}.
module top (

    input  logic         clk,
    input  logic         rst_n,

    // Ingress byte stream
    input  logic         s_axis_tvalid,
    output logic         s_axis_tready,
    input  logic [7:0]   s_axis_tdata,

    // Egress decoded-record stream
    output logic         m_axis_tvalid,
    input  logic         m_axis_tready,
    output logic [103:0] m_axis_tdata,
    output logic         m_axis_tlast

);

    // An ingress beat is consumed only when both sides agree.
    logic accept;
    assign accept = s_axis_tvalid & s_axis_tready;

    // Aligned byte stream out of the ingress stage.
    logic       byte_valid;
    logic [7:0] rx_byte;

    byte_receiver u_byte_receiver (
        .clk(clk),
        .rst_n(rst_n),
        .rx_valid(accept),
        .data_in(s_axis_tdata),
        .byte_valid(byte_valid),
        .data_out(rx_byte)
    );

    // Message assembler.
    logic [103:0] message;
    logic         message_valid;

    parser u_parser (
        .clk(clk),
        .rst_n(rst_n),
        .valid(byte_valid),
        .byte_in(rx_byte),
        .message(message),
        .message_valid(message_valid)
    );

    // Combinational field extraction; qualified by decoded_valid for one cycle.
    logic [7:0]  msg_type;
    logic [31:0] order_id;
    logic [31:0] price;
    logic [31:0] quantity;
    logic        decoded_valid;

    message_decoder u_message_decoder (
        .message(message),
        .message_valid(message_valid),
        .msg_type(msg_type),
        .order_id(order_id),
        .price(price),
        .quantity(quantity),
        .decoded_valid(decoded_valid)
    );

    // Packed egress record.
    logic [103:0] record;
    assign record = {msg_type, order_id, price, quantity};

    // Egress skid buffer: registers/holds the record until accepted, and its
    // s_ready doubles as the whole pipeline's backpressure signal.
    logic egress_s_ready;

    axis_skid_buffer #(.DATA_W(104)) u_egress (
        .clk(clk),
        .rst_n(rst_n),
        .s_valid(decoded_valid),
        .s_ready(egress_s_ready),
        .s_data(record),
        .s_last(1'b1),               // each decoded record is one complete beat
        .m_valid(m_axis_tvalid),
        .m_ready(m_axis_tready),
        .m_data(m_axis_tdata),
        .m_last(m_axis_tlast)
    );

    // Stall ingress whenever the egress cannot accept a (possible) record.
    assign s_axis_tready = egress_s_ready;

endmodule
