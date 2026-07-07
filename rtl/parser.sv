module parser (

    input  logic        clk,
    input  logic        rst_n,

    input  logic        valid,
    input  logic [7:0]  byte_in,

    output logic [103:0] message,
    output logic         message_valid

);

    logic [3:0] byte_count;

    always_ff @(posedge clk) begin

        if (!rst_n) begin
            message       <= '0;
            message_valid <= 1'b0;
            byte_count    <= 4'd0;
        end
        else begin

            message_valid <= 1'b0;

            if (valid) begin

                message <= {message[95:0], byte_in};

                if (byte_count == 4'd12) begin
                    message_valid <= 1'b1;
                    byte_count    <= 4'd0;
                end
                else begin
                    byte_count <= byte_count + 1'b1;
                end

            end

        end

    end

endmodule
