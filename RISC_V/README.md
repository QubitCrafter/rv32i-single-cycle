# RISC-V Single-Cycle Processor — RV32IM

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Language](https://img.shields.io/badge/language-SystemVerilog-orange.svg)
![Simulator](https://img.shields.io/badge/simulator-Vivado%20XSIM%202025.2-green.svg)
![Synthesis](https://img.shields.io/badge/synthesis-Yosys%20%2B%20ASAP7%207nm-purple.svg)
![Tests](https://img.shields.io/badge/tests-42%2F42%20PASS-brightgreen.svg)

A fully functional, single-cycle **RISC-V RV32IM** processor implemented in **SystemVerilog**. Verified with a task-based testbench achieving **42/42 tests passing** under Vivado XSIM, and taken through a complete open-source ASIC flow — RTL linting, logic synthesis on a **7nm ASAP7 PDK**, and static timing analysis with OpenSTA.

---

## Key Specifications

| Feature | Details |
|:---|:---|
| **Language** | SystemVerilog |
| **Architecture** | Harvard |
| **ISA** | RV32IM |
| **RTL Modules** | 8 |
| **Testbenches** | 8 |
| **Instructions Supported** | 42 |
| **Verification** | Task-based self-checking |
| **ASIC Flow** | Yosys + OpenSTA + ASAP7 |
| **License** | MIT |

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

### Supported Instructions (RV32IM Subset)

| Category | Instructions |
|:---|:---|
| **R-Type** | `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, `SRA`, `SLT`, `SLTU` |
| **I-Type Arithmetic** | `ADDI`, `ANDI`, `ORI`, `XORI`, `SLLI`, `SRLI`, `SRAI`, `SLTI`, `SLTIU` |
| **Upper Immediate** | `LUI`, `AUIPC` |
| **Load / Store** | `LW`, `SW` |
| **Branch** | `BEQ` |
| **Jump** | `JAL`, `JALR` |
| **M-Extension (Multiply/Divide)** | `MUL`, `MULH`, `MULHSU`, `MULHU`, `DIV`, `DIVU`, `REM`, `REMU` |

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

All **42 tests pass** on the reference `program.hex`:

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
=== x0 Hardwire Test ===           [PASS] x0 stays 0 after write
=== M-Extension Tests ===          [PASS] MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU

============================================================
 TEST SUMMARY:  Total: 42  |  PASS: 42  |  FAIL: 0
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
| `ALU` | 14498 | 1287.75 | 0.00% |
| `ProgramCounter` | 64 | 13.53 | 89.66% |
| `ImmediateGenerator` | 65 | 4.67 | 0.00% |
| `ControlUnit` | 59 | 4.26 | 0.00% |
| `InstructionMem` *(blackbox)* | — | 1500.00 | — |
| `DataMem` *(blackbox)* | — | 3000.00 | — |
| **RISCTop (total)** | **19655** | **6488.67** | **5.98%** |

### Timing (`report_timing_riscv_opensta.txt`)

| Metric | Value |
|:---|:---|
| Clock Period | 20,000 ps (50 MHz) |
| Critical Path | PC → InstructionMem → RegFile → ALU → DataMem |
| Worst Negative Slack (WNS) | −28,325 ps |
| Critical Path Bottleneck | Single-cycle instruction fetch through RegFile and ALU. |

> **Note:** Timing violation is expected because this is a single-cycle processor where instruction fetch, register access, ALU execution, and memory access occur in one clock cycle.

### Power (`report_power_riscv_opensta.txt`)

| Group | Internal | Leakage | Total |
|:---|---:|---:|---:|
| Sequential | 33.0 µW | 146.0 µW | 179.0 µW |
| Combinational | 0.0 µW | 1.37 mW | 1.37 mW |
| **Total** | **33.0 µW** | **1.51 mW** | **1.55 mW** |

> Switching power is not included as no VCD/SAIF activity file was provided to the tool.

---

## Development Roadmap

```text
Overall Progress

██████████░░░░░░░░░░ 40%

Completed
─────────
✅ Phase 1
✅ Phase 2

Upcoming
────────
⬜ Phase 3
⬜ Phase 4
⬜ Phase 5
```

```text
Detailed Roadmap

Phase 1 — RV32I Single-Cycle Processor
──────────────────────────────────────
✅ RV32I Single-Cycle CPU
✅ RTL Implementation
✅ Module-Level Testbenches
✅ Full CPU Integration Testbench
✅ ASIC Synthesis (Yosys)
✅ Static Timing Analysis (OpenSTA)

Phase 2 — RV32M Extension
─────────────────────────
✅ Multiply/Divide Extension

Phase 3 — 5-Stage Pipeline
──────────────────────────
⬜ IF/ID Register
⬜ ID/EX Register
⬜ EX/MEM Register
⬜ MEM/WB Register
⬜ Hazard Detection Unit
⬜ Forwarding Unit
⬜ Branch Flush
⬜ Pipeline Verification

Phase 4 — UVM Verification
──────────────────────────
⬜ Interface
⬜ Sequence Item
⬜ Sequence
⬜ Sequencer
⬜ Driver
⬜ Monitor
⬜ Agent
⬜ Scoreboard
⬜ Functional Coverage
⬜ Environment
⬜ Tests

Phase 5 — Memory Hierarchy
──────────────────────────
⬜ I-Cache
⬜ D-Cache
⬜ Cache Controller
⬜ Memory Controller
⬜ Modified Harvard Architecture
```

---

## Module Descriptions

| Module | File | Description |
|:---|:---|:---|
| `RISCTop` | `rtl/RISCTop.sv` | Top-level: wires all sub-modules, exposes observable outputs |
| `ALU` | `rtl/ALU.sv` | 18-operation ALU (Base + M-Extension) with zero flag |
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
