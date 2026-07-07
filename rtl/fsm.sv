module fsm (
    input  logic clk,
    input  logic rst_n,
    input  logic byte_valid,

    output logic reg_en,
    output logic count_en,
    output logic done
);

always_comb begin

    reg_en   = 0;
    count_en = 0;
    done     = 0;

    if (byte_valid) begin
        reg_en   = 1;
        count_en = 1;
    end

end

endmodule
