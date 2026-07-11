# RISC-V Single-Cycle Processor — RV32I

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Language](https://img.shields.io/badge/language-SystemVerilog-orange.svg)
![Simulator](https://img.shields.io/badge/simulator-Vivado%20XSIM%202025.2-green.svg)
![Synthesis](https://img.shields.io/badge/synthesis-Yosys%20%2B%20ASAP7%207nm-purple.svg)
![Tests](https://img.shields.io/badge/tests-34%2F34%20PASS-brightgreen.svg)

A fully functional, single-cycle **RISC-V RV32I** processor implemented in **SystemVerilog**. Verified with a task-based testbench achieving **34/34 tests passing** under Vivado XSIM, and taken through a complete open-source ASIC flow — RTL linting, logic synthesis on a **7nm ASAP7 PDK**, and static timing analysis with OpenSTA.

---

## Architecture Overview

```
          ┌────────────────────────────────────────────────────────────────────┐
          │                      RISCTop (Top Level)                           │
          │                                                                    │
 clk ────►│  ┌──────────┐   ┌──────────────┐    ┌────────────────────────┐     │
 rst_n ──►│  │ Program  │──►│ Instruction  │───►│     Control Unit       │     │
          │  │ Counter  │   │   Memory     │    │  (opcode/funct3/funct7)│     │
          │  └────┬─────┘   └──────┬───────┘    └────────────┬───────────┘     │
          │       │                │ instruction             │ ctrl signals    │
          │       │          ┌─────▼───────┐                 │                 │
          │       │          │  Immediate  │                 │                 │
          │       │          │  Generator  │                 │                 │
          │       │          └─────┬───────┘                 │                 │
          │       │                │ imm[31:0]               │                 │
          │  ┌────▼──────┐   ┌─────▼───────┐   ┌─────────────▼─────────────┐   │
          │  │ Register  │──►│    ALU      │◄──│      Mux: reg / imm       │   │
          │  │   File    │   └─────┬───────┘   └───────────────────────────┘   │
          │  └────▲──────┘         │ alu_result                                │
          │       │          ┌─────▼───────┐                                   │
          │       └──────────│    Data     │                                   │
          │    writeback     │   Memory    │                                   |
          │                  └─────────────┘                                   |
          └────────────────────────────────────────────────────────────────────┘
```

### Supported Instructions (RV32I Subset)

| Category | Instructions |
|:---|:---|
| **R-Type** | `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, `SRA`, `SLT`, `SLTU` |
| **I-Type Arithmetic** | `ADDI`, `ANDI`, `ORI`, `XORI`, `SLLI`, `SRLI`, `SRAI`, `SLTI`, `SLTIU` |
| **Upper Immediate** | `LUI`, `AUIPC` |
| **Load / Store** | `LW`, `SW` |
| **Branch** | `BEQ` |
| **Jump** | `JAL`, `JALR` |

---

## Repository Structure

```
RISC_V/
├── rtl/                          # Synthesisable RTL sources
│   ├── RISCTop.sv                #   Top-level processor (datapath wiring)
│   ├── ALU.sv                    #   Arithmetic Logic Unit (10 operations)
│   ├── ControlUnit.sv            #   Opcode decoder & control signal generator
│   ├── DataMem.sv                #   Data memory — synchronous write, async read
│   ├── ImmediateGenerator.sv     #   Sign-extended immediate generator
│   ├── InstructionMem.sv         #   Instruction ROM ($readmemh from program.hex)
│   ├── ProgramCounter.sv         #   32-bit PC with synchronous active-low reset
│   └── RegFile.sv                #   32×32-bit register file (x0 hardwired to 0)
│
├── tb/                           # Testbenches
│   ├── RISCTop_tb.sv             #   Full system testbench (34 test cases)
│   ├── ALU_tb.sv
│   ├── ControlUnit_tb.sv
│   ├── DataMem_tb.sv
│   ├── ImmediateGenerator_tb.sv
│   ├── InstructionMem_tb.sv
│   ├── ProgramCounter_tb.sv
│   └── RegFile_tb.sv
│
├── sim/                          # Simulation artifacts
│   ├── program.hex               #   Pre-assembled test program (RV32I machine code)
│   ├── sim_results.txt           #   Full simulation output log (34/34 PASS)
│   └── xsim.log                  #   Vivado XSIM session log
│
├── docs/
│   └── schematics/               # Synthesised schematics (Vivado)
│       ├── RISCTop_schematic.pdf
│       └── RISCTop_schematic.svg
│
├── lib/                          # Standard cell libraries
│   ├── asap7_merged_RVT_TT.lib   #   ASAP7 7nm RVT TT-corner standard cells
│   └── asap7_fakeram.lib         #   Behavioural SRAM timing model for ASAP7
│                                 #   (see lib/asap7_fakeram.lib for attribution)
│
├── reports/                      # ASIC flow output reports
│   ├── report_area_riscv_yosys.txt
│   ├── report_timing_riscv_opensta.txt
│   └── report_power_riscv_opensta.txt
│
├── Makefile                      # Unified build — sim / lint / synth / STA
├── README.md                     # This file
├── LICENSE                       # MIT License
└── .gitignore                    # Ignores build artifacts
```

---

## Getting Started

### Prerequisites

| Tool | Purpose | Notes |
|:---|:---|:---|
| **Xilinx Vivado 2025.2** | Simulation (XSIM) | Free WebPACK edition works |
| **Yosys 0.47+** | Logic synthesis | Part of [oss-cad-suite](https://github.com/YosysHQ/oss-cad-suite-build) |
| **OpenSTA 3.1.0** | Static timing analysis | Also part of oss-cad-suite |
| **make** | Build orchestration | Native on Linux; use WSL on Windows |

> **Note:** All tools are orchestrated by the single `Makefile` at the project root. No external scripts are needed.

### Quick Start

```bash
# Full flow — clean → compile → simulate → lint → synthesise → STA
make run_all

# Run simulation only (batch mode)
make batch

# Run linting (Verilator)
make lint

# Run Yosys synthesis (ASAP7 7nm)
make synth_yosys

# Run OpenSTA timing analysis
make sta

# Clean all build artifacts (schematic preserved)
make clean_all
```

---

## Test Results

All **34 tests pass** on the reference `program.hex`:

```
============================================================
 RISCTop Task-Based Testbench
 Instructions loaded from: program.hex
============================================================

=== Init Register Tests ===        [PASS] ADDI x1=10, x2=20, x3=3
=== R-Type Instruction Tests ===   [PASS] ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
=== I-Type Arithmetic Tests ===    [PASS] ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU
=== Upper-Immediate Tests ===      [PASS] LUI, AUIPC
=== Load/Store Tests ===           [PASS] SW Mem[5]=x1, LW x25=Mem[5]
=== Branch Tests ===               [PASS] BEQ not-taken, BEQ taken, landing
=== Jump Tests ===                 [PASS] JAL link, JAL landing, JALR link, JALR landing
=== x0 Hardwire Test ===          [PASS] x0 stays 0 after write

============================================================
 TEST SUMMARY:  Total: 34  |  PASS: 34  |  FAIL: 0
 >>> ALL TESTS PASSED <<<
============================================================
```

---

## ASIC Flow Results (ASAP7 7nm)

The processor was taken through a full open-source ASIC synthesis and static timing analysis flow using **Yosys** and **OpenSTA** against the **ASAP7 predictive 7nm PDK**.

### Area (`report_area_riscv_yosys.txt`)

| Module | Cells | Total Area | Sequential % |
|:---|---:|---:|---:|
| `RegFile` | 4382 | 632.12 | 59.49% |
| `ALU` | 1025 | 79.53 | 0.00% |
| `ProgramCounter` | 64 | 13.53 | 89.66% |
| `ImmediateGenerator` | 65 | 4.67 | 0.00% |
| `ControlUnit` | 40 | 2.95 | 0.00% |
| `InstructionMem` *(blackbox)* | — | 1500.00 | — |
| `DataMem` *(blackbox)* | — | 3000.00 | — |
| **RISCTop (total)** | **6167** | **5279.37** | **7.35%** |

### Timing (`report_timing_riscv_opensta.txt`)

| Metric | Value |
|:---|:---|
| Clock Period | 20,000 ps (50 MHz) |
| Critical Path | PC → InstructionMem → RegFile → ALU → DataMem |
| Worst Negative Slack (WNS) | −11,542 ps |
| Critical Path Bottleneck | `RegFile` (synthesised as std-cell array, not SRAM macro) |

> **Note:** The timing violation is caused by the `RegFile` being synthesised into ~4,382 standard-cell flip-flops and large multiplexer trees rather than a dedicated SRAM macro. In a real ASIC tapeout this module would be replaced with a compiled 2R1W SRAM, and the design would comfortably meet 50 MHz.

### Power (`report_power_riscv_opensta.txt`)

| Group | Internal | Leakage | Total |
|:---|---:|---:|---:|
| Sequential | 1.97 mW | 7.14 mW | 9.10 mW |
| Combinational | 6.05 mW | 5.30 mW | 11.35 mW |
| **Total** | **8.01 mW** | **12.44 mW** | **20.40 mW** |

> Switching power is not included as no VCD/SAIF activity file was provided to the tool.

---

## Module Descriptions

| Module | File | Description |
|:---|:---|:---|
| `RISCTop` | `rtl/RISCTop.sv` | Top-level: wires all sub-modules, exposes observable outputs |
| `ALU` | `rtl/ALU.sv` | 10-operation ALU with zero flag |
| `ControlUnit` | `rtl/ControlUnit.sv` | Decodes opcode + funct3 + funct7 into all control signals |
| `RegFile` | `rtl/RegFile.sv` | 32×32-bit register file; x0 permanently reads as 0 |
| `ImmediateGenerator` | `rtl/ImmediateGenerator.sv` | Sign-extends immediates for R/I/S/B/U/J formats |
| `InstructionMem` | `rtl/InstructionMem.sv` | ROM loaded from `sim/program.hex` via `$readmemh` |
| `DataMem` | `rtl/DataMem.sv` | Synchronous write, asynchronous read, word-addressed |
| `ProgramCounter` | `rtl/ProgramCounter.sv` | 32-bit PC register with synchronous active-low reset |

---

## License

This project is licensed under the [MIT License](LICENSE).

The `lib/asap7_fakeram.lib` file is separately licensed — see the header comment inside that file for details.
