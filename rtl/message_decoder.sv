module message_decoder (

    input  logic [103:0] message,
    input  logic         message_valid,

    output logic [7:0]   msg_type,
    output logic [31:0]  order_id,
    output logic [31:0]  price,
    output logic [31:0]  quantity,
    output logic         decoded_valid

);

    // Pre-slice the message fields with continuous assignments. This keeps the
    // combinational decode below free of constant part-selects of a vector
    // inside an always_* block, which Icarus reports as "sorry: constant selects
    // in always_* processes". Behaviour is identical.
    wire [7:0]  f_type  = message[103:96];
    wire [31:0] f_oid   = message[95:64];
    wire [31:0] f_price = message[63:32];
    wire [31:0] f_qty   = message[31:0];

    always_comb begin

        // Default outputs
        msg_type      = f_type;
        order_id      = 32'd0;
        price         = 32'd0;
        quantity      = 32'd0;
        decoded_valid = 1'b0;

        if (message_valid) begin

            decoded_valid = 1'b1;

            case (f_type)

                8'h41: begin // 'A' = Add Order
                    order_id = f_oid;
                    price    = f_price;
                    quantity = f_qty;
                end

                8'h50: begin // 'P' = Trade
                    order_id = f_oid;
                    price    = f_price;
                    quantity = f_qty;
                end

                default: begin
                    decoded_valid = 1'b0;
                end

            endcase

        end

    end

endmodule
