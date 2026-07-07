module parser (

    input  logic       clk,
    input  logic       rst_n,

    input  logic       byte_valid,
    input  logic [7:0] byte_in,

    output logic [31:0] message,
    output logic        message_valid

);

always_ff @(posedge clk) begin

    if (!rst_n) begin
        message       <= 32'd0;
        message_valid <= 1'b0;
    end
    else begin

        message_valid <= 1'b0;

        if (byte_valid) begin

            message <= {message[23:0], byte_in};

            if (message[31:24] != 8'h00)
                message_valid <= 1'b1;

        end
    end

end

endmodule
