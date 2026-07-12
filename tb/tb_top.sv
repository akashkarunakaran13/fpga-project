`timescale 1ns/1ps
//============================================================================
// tb_top : self-checking testbench for the streaming market-data decoder.
//   - directed tests  : Trade('P'), Add('A'), unknown-type (must NOT emit)
//   - randomized test : random messages + random input stalls + random
//                       egress backpressure, checked against a scoreboard
//   - measures latency (input-complete -> output) and ingest throughput
//   - procedural assertions (spurious-beat, record-mismatch); concurrent
//     SVA available under `+define+SVA` for tools that support it.
//============================================================================
module tb_top;

    logic         clk, rst_n;
    logic         s_tvalid, s_tready;
    logic [7:0]   s_tdata;
    logic         m_tvalid, m_tready, m_tlast;
    logic [103:0] m_tdata;

    top dut (
        .clk(clk), .rst_n(rst_n),
        .s_axis_tvalid(s_tvalid), .s_axis_tready(s_tready),
        .s_axis_tdata(s_tdata),
        .m_axis_tvalid(m_tvalid), .m_axis_tready(m_tready),
        .m_axis_tdata(m_tdata),   .m_axis_tlast(m_tlast)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    integer cyc;      initial cyc = 0;      always @(posedge clk) cyc <= cyc + 1;
    integer in_bytes; initial in_bytes = 0; always @(posedge clk) if (s_tvalid && s_tready) in_bytes <= in_bytes + 1;

    // Scoreboard FIFO (expected decoded records, in order).
    localparam integer MAXQ = 512;
    logic [103:0] sb [0:MAXQ-1];
    integer sb_h, sb_t;
    integer errors, matched;

    // Latency capture.
    integer lat_in, lat_track, latency;

    // Egress backpressure driver (single owner of m_tready).
    integer bp_mode;
    always @(posedge clk) begin
        if (!rst_n)        m_tready <= 1'b1;
        else if (bp_mode)  m_tready <= (({$random} % 10) < 6);  // ~60% ready
        else               m_tready <= 1'b1;
    end

    // Egress monitor + checker.
    always @(posedge clk) begin
        if (m_tvalid && m_tready) begin
            if (lat_track == 1) begin latency = cyc - lat_in; lat_track = 0; end
            if (sb_h == sb_t) begin
                errors = errors + 1; $display("ERROR: spurious egress beat @cyc %0d", cyc);
            end
            else begin
                if (m_tdata !== sb[sb_h]) begin
                    errors = errors + 1;
                    $display("ERROR: record mismatch exp=%h got=%h", sb[sb_h], m_tdata);
                end
                else matched = matched + 1;
                sb_h = sb_h + 1;
            end
        end
    end

    // Drive one 13-byte message; optionally inject input stalls; push expected.
    integer stall_en;
    reg [7:0] b [0:12];
    integer k;
    task send_msg(input [7:0] t, input [31:0] o, input [31:0] p, input [31:0] q, input integer track);
        begin
            b[0]=t;
            b[1]=o[31:24]; b[2]=o[23:16]; b[3]=o[15:8]; b[4]=o[7:0];
            b[5]=p[31:24]; b[6]=p[23:16]; b[7]=p[15:8]; b[8]=p[7:0];
            b[9]=q[31:24]; b[10]=q[23:16]; b[11]=q[15:8]; b[12]=q[7:0];
            for (k = 0; k < 13; k = k + 1) begin
                if (stall_en) begin
                    while (({$random} % 3) == 0) begin @(negedge clk); s_tvalid = 1'b0; end
                end
                @(negedge clk);
                s_tvalid = 1'b1; s_tdata = b[k];
                @(posedge clk);
                while (!s_tready) @(posedge clk);      // hold until accepted
                if (track && k == 12) begin lat_in = cyc; lat_track = 1; end
            end
            @(negedge clk); s_tvalid = 1'b0; s_tdata = 8'h00;
            if (t == 8'h41 || t == 8'h50) begin sb[sb_t] = {t,o,p,q}; sb_t = sb_t + 1; end
        end
    endtask

    integer i, tsel;
    integer tp_b0, tp_c0;
    initial begin
        $dumpfile("top.vcd"); $dumpvars(0, tb_top);
        rst_n=0; s_tvalid=0; s_tdata=0;
        bp_mode=0; stall_en=0; sb_h=0; sb_t=0; errors=0; matched=0; lat_track=0; latency=0;
        repeat (3) @(negedge clk); rst_n = 1'b1;

        // ---- directed ----
        send_msg(8'h50, 32'd1, 32'd100, 32'd10, 1);   // Trade, track latency
        send_msg(8'h41, 32'd7, 32'd250, 32'd5,  0);   // Add Order
        send_msg(8'h58, 32'd9, 32'd9,   32'd9,  0);   // unknown -> no egress
        repeat (20) @(posedge clk);

        // ---- throughput burst (no stalls, no backpressure) ----
        tp_b0 = in_bytes; tp_c0 = cyc;
        for (i = 0; i < 10; i = i + 1) send_msg(8'h50, i, 100+i, 10+i, 0);
        repeat (20) @(posedge clk);

        // ---- randomized: random stalls + random backpressure ----
        bp_mode = 1; stall_en = 1;
        for (i = 0; i < 200; i = i + 1) begin
            tsel = {$random} % 3;                       // 0=A 1=P 2=unknown
            send_msg((tsel==0)?8'h41:(tsel==1)?8'h50:8'h58, $random, $random, $random, 0);
        end
        bp_mode = 0; stall_en = 0;
        repeat (80) @(posedge clk);                     // drain

        // ---- report ----
        $display("TB_TOP: latency=%0d cycles", latency);
        $display("TB_TOP: throughput=%0d bytes in %0d cycles", in_bytes - tp_b0, cyc - tp_c0);
        $display("TB_TOP: scoreboard expected=%0d matched=%0d errors=%0d", sb_t, matched, errors);
        if (errors == 0 && matched == sb_t)
            $display("TB_TOP: PASS");
        else
            $display("TB_TOP: FAIL");
        $finish;
    end

`ifdef SVA
    // Concurrent assertions (enabled with +define+SVA on SVA-capable tools).
    a_out_hold: assert property (@(posedge clk) disable iff (!rst_n)
        (m_tvalid && !m_tready) |=> (m_tvalid && $stable(m_tdata)));
    a_ready_low_is_full: assert property (@(posedge clk) disable iff (!rst_n)
        (!s_tready) |-> (m_tvalid));
`endif

endmodule
