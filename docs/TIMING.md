# Timing, Latency & Throughput

## Latency (simulation-measured)
**3 clock cycles** from the input beat that completes a 13-byte message to the
decoded record appearing on `m_axis`. Reported by `tb_top`:
```
TB_TOP: latency=3 cycles
```

## Throughput (simulation-measured)
Peak rate is **1 byte/cycle (II = 1)**: the datapath accepts one byte every cycle
when not stalled, with no bubbles. The self-checking run reports the aggregate
over the full randomized test, which injects random input stalls and egress
backpressure:
```
TB_TOP: throughput=2730 bytes in 4332 cycles
```
(2730 bytes = 130 burst + 2600 randomized; the sub-unity aggregate reflects the
deliberately injected stalls/backpressure, not a datapath limit.)

## Fmax / Utilization (from Vivado)
Run:
```bash
vivado -mode batch -source syn/synth.tcl
```
Reports land in `syn/timing_summary.rpt` and `syn/utilization.rpt`.
Target part and clock constraint are set in `syn/synth.tcl` / `syn/constraints.xdc`.

| Metric | Source | Value |
|--------|--------|-------|
| Clock constraint | syn/constraints.xdc | 4.000 ns (250 MHz) |
| WNS  | timing_summary.rpt | _fill from report_ |
| Fmax | 1 / (T − WNS)      | _fill from report_ |
| LUT  | utilization.rpt    | _fill from report_ |
| FF   | utilization.rpt    | _fill from report_ |
| BRAM | utilization.rpt    | _fill from report_ |

Latency and throughput above are from simulation. Fmax/utilization are populated
from your Vivado run — no timing numbers are invented in this repository.
