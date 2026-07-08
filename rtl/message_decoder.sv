module message_decoder (

    input  logic [103:0] message,
    input  logic         message_valid,

    output logic [7:0]   msg_type,
    output logic [31:0]  order_id,
    output logic [31:0]  price,
    output logic [31:0]  quantity,
    output logic         decoded_valid

);

always_comb begin

    msg_type      = message[103:96];
    order_id      = message[95:64];
    price         = message[63:32];
    quantity      = message[31:0];

    decoded_valid = message_valid;

end

endmodule
