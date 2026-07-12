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

    // Default outputs
    msg_type      = message[103:96];
    order_id      = 32'd0;
    price         = 32'd0;
    quantity      = 32'd0;
    decoded_valid = 1'b0;

    if (message_valid) begin

        decoded_valid = 1'b1;

        case (message[103:96])

            8'h41: begin // 'A' = Add Order
                order_id = message[95:64];
                price    = message[63:32];
                quantity = message[31:0];
            end

            8'h50: begin // 'P' = Trade
                order_id = message[95:64];
                price    = message[63:32];
                quantity = message[31:0];
            end

            default: begin
                decoded_valid = 1'b0;
            end

        endcase

    end

end

endmodule
