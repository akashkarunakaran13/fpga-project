module byte_receiver (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       rx_valid,
    input  logic [7:0] data_in,

    output logic       byte_valid,
    output logic [7:0] data_out
);

    // Register the incoming byte TOGETHER with its valid strobe so that the
    // downstream parser always receives a byte and a strobe that belong to the
    // same clock cycle. Previously only rx_valid was registered while the data
    // was passed live, creating a one-cycle skew between the strobe and the byte.
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            byte_valid <= 1'b0;
            data_out   <= 8'h00;
        end
        else begin
            byte_valid <= rx_valid;
            data_out   <= data_in;
        end
    end

endmodule
