module message_decoder (

    input  logic [31:0] message,
    input  logic        message_valid,

    output logic [7:0] msg_type,
    output logic [7:0] symbol,
    output logic [7:0] price,
    output logic [7:0] quantity,
    output logic        decoded_valid

);

always_comb begin

    msg_type      = message[31:24];
    symbol        = message[23:16];
    price         = message[15:8];
    quantity      = message[7:0];

    decoded_valid = message_valid;

end

endmodule
