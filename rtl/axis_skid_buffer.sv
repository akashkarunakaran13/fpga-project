// Reusable AXI4-Stream-compatible skid buffer (registered outputs, 2-entry).
//
// Purpose: provide a streaming stage where the upstream ready (s_ready) is
// driven ONLY from an internal register, so there is no combinational path
// from downstream m_ready back to upstream s_ready / s_valid. That keeps the
// handshake out of the critical path and lets modules be composed without
// building long ready chains. It also holds data stable until accepted,
// which is exactly what a decoded record needs on the egress side.
//
// Full-throughput: sustains one transfer per cycle with no bubbles.
module axis_skid_buffer #(
    parameter int DATA_W = 8
) (
    input  logic              clk,
    input  logic              rst_n,

    // upstream (sink side)
    input  logic              s_valid,
    output logic              s_ready,
    input  logic [DATA_W-1:0] s_data,
    input  logic              s_last,

    // downstream (source side)
    output logic              m_valid,
    input  logic              m_ready,
    output logic [DATA_W-1:0] m_data,
    output logic              m_last
);

    // Primary ("pipe") register drives the outputs.
    logic              p_valid;
    logic [DATA_W-1:0] p_data;
    logic              p_last;

    // Skid register holds one overflow beat.
    logic              k_valid;
    logic [DATA_W-1:0] k_data;
    logic              k_last;

    assign m_valid = p_valid;
    assign m_data  = p_data;
    assign m_last  = p_last;

    // Can accept whenever the skid register is empty (registered -> no comb path).
    assign s_ready = ~k_valid;

    wire acc_in  = s_valid & s_ready;   // input accepted this cycle
    wire acc_out = m_valid & m_ready;   // output accepted this cycle

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            p_valid <= 1'b0;
            k_valid <= 1'b0;
            p_data  <= '0; p_last <= 1'b0;
            k_data  <= '0; k_last <= 1'b0;
        end
        else begin
            if (acc_out) begin
                // Pipe drains this cycle.
                if (k_valid) begin
                    // Promote skid -> pipe.
                    p_data  <= k_data;
                    p_last  <= k_last;
                    p_valid <= 1'b1;
                    k_valid <= 1'b0;
                end
                else if (acc_in) begin
                    // Bypass new input straight into the pipe (no bubble).
                    p_data  <= s_data;
                    p_last  <= s_last;
                    p_valid <= 1'b1;
                end
                else begin
                    p_valid <= 1'b0;
                end
            end
            else begin
                // Pipe not draining.
                if (acc_in) begin
                    if (p_valid) begin
                        // Pipe occupied -> stash in skid.
                        k_data  <= s_data;
                        k_last  <= s_last;
                        k_valid <= 1'b1;
                    end
                    else begin
                        // Pipe empty -> fill it.
                        p_data  <= s_data;
                        p_last  <= s_last;
                        p_valid <= 1'b1;
                    end
                end
            end
        end
    end

endmodule
