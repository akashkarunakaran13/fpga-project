module byte_receiver (
    input  logic clk,
    input  logic rst_n,
    input  logic rx_valid,

    output logic byte_valid
);

always_ff @(posedge clk) begin
    if (!rst_n)
        byte_valid <= 1'b0;
    else
        byte_valid <= rx_valid;
end

endmodule
