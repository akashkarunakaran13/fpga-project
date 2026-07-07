module register (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    input  logic [7:0] data_in,
    output logic [7:0] data_out
);

always_ff @(posedge clk) begin
    if (!rst_n)
        data_out <= 8'h00;
    else if (en)
        data_out <= data_in;
end

endmodule
