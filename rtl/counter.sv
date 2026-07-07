module counter (
    input  logic clk,        // the clock - the heartbeat
    input  logic rst_n,      // reset (active-low: 0 = reset)
    output logic [3:0] count // 4-bit output: counts 0 to 15
);

    always_ff @(posedge clk) begin
        if (!rst_n)
            count <= 4'd0;       // on reset, go to 0
        else
            count <= count + 1;  // otherwise, add 1 each clock tick
    end

endmodule
