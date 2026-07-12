# Verification

## Strategy
`tb/tb_top.sv` is self-checking. It drives the ready/valid ingress and compares
every decoded record, in order, against a scoreboard of expected records.

## Stimulus
- **Directed:** Trade (`'P'`), Add Order (`'A'`), and an unknown type (must
  produce **no** egress beat).
- **Throughput burst:** 10 back-to-back messages, no stalls/backpressure, to
  exercise the full-rate path.
- **Randomized:** 200 messages of random type (A / P / unknown) and random 32-bit
  fields, driven with **random input stalls** and **random egress backpressure**.

## Checks / assertions
- Every egress beat must match the scoreboard head (record correctness).
- No egress beat may occur while the scoreboard is empty (no spurious output).
- Final: all expected records consumed, zero errors.
- Concurrent SVA (`+define+SVA`): `m_axis` holds valid data stable until accepted;
  `s_axis_tready` low implies the egress is occupied.

## Result (actual)
```
TB_TOP: latency=3 cycles
TB_TOP: throughput=2730 bytes in 4332 cycles
TB_TOP: scoreboard expected=142 matched=142 errors=0
TB_TOP: PASS
```
142 decoded records checked (10 burst + 132 randomized A/P), all matched, zero
errors, zero drops — lossless and in-order under random stalls and backpressure.

## Run
```bash
mkdir -p sim
iverilog -g2012 -o sim/top_sim rtl/axis_skid_buffer.sv rtl/byte_receiver.sv \
  rtl/parser.sv rtl/message_decoder.sv rtl/top.sv tb/tb_top.sv
vvp sim/top_sim
```
