# FPGA Streaming Packet Parser

A modular FPGA project written in SystemVerilog that demonstrates the design, integration, simulation, and verification of a simple streaming packet parser.

This project was built as part of a structured FPGA engineering roadmap with emphasis on RTL design, simulation, debugging, and clean engineering practices.

---

## Features

- Modular RTL architecture
- Register design
- 4-bit counter with enable
- Finite State Machine (FSM)
- Byte receiver
- Packet parser
- Message decoder
- Top-level integration
- Individual testbenches
- System-level testbench
- GTKWave waveform verification
- Git version control

---

## Project Structure

```text
fpga-project/
├── rtl/
│   ├── register.sv
│   ├── counter.sv
│   ├── fsm.sv
│   ├── byte_receiver.sv
│   ├── parser.sv
│   ├── message_decoder.sv
│   └── top.sv
│
├── tb/
│   ├── tb_register.sv
│   ├── tb_counter.sv
│   ├── tb_fsm.sv
│   └── tb_top.sv
│
├── sim/
├── .gitignore
└── README.md
```

---

## Build

Compile the complete project:

```bash
iverilog -g2012 \
-o sim/top_sim \
rtl/register.sv \
rtl/counter.sv \
rtl/fsm.sv \
rtl/byte_receiver.sv \
rtl/parser.sv \
rtl/message_decoder.sv \
rtl/top.sv \
tb/tb_top.sv
```

---

## Run Simulation

```bash
vvp sim/top_sim
```

---

## View Waveform

```bash
gtkwave top.vcd
```

---

## Current Functionality

The design demonstrates a simple streaming packet flow:

```
Incoming Bytes
      │
      ▼
Byte Receiver
      │
      ▼
FSM
      │
      ├────────► Register
      │
      └────────► Counter
                     │
                     ▼
               Packet Complete
```

---

## Future Improvements

- Complete parser integration
- Improved packet format
- Deterministic parser completion
- Assertions for verification
- Enhanced self-checking testbench
- Performance optimisation
- FPGA board implementation

---

## Tools Used

- Ubuntu Linux
- SystemVerilog
- Icarus Verilog
- GTKWave
- Git

---

## Author

Akash

Electronic and Computer Engineering

Newcastle University
