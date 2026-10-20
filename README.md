# SPI Master RTL — Verilog + Testbench

## Project Overview

This project demonstrates SPI (Serial Peripheral Interface) communication using Verilog RTL and functional simulation. It illustrates how an SPI master transmits and receives serial data using clock generation, shift registers, and control signals.

The simulation demonstrates the transmission of `0x3C` and the reception of `0xA5` from a simulated SPI slave. The RTL code, testbench, and waveform provide an example of the data-transfer process and its verification.

## Maven Silicon — VLSI Physical Design Project

As part of my VLSI Physical Design training at Maven Silicon, I worked on an SPI-related physical-design project using Qflow. The accompanying project report presents the physical-design workflow, including synthesis, placement, timing analysis, routing, DRC, LVS, and layout generation, as documented in the report.

Together, these materials showcase my understanding of SPI communication, Verilog RTL simulation, and VLSI physical-design concepts.


## Features
- 8-bit transmit and receive data
- Active-low slave select (`ss_n`)
- Mode 0: SCLK idle-low; sample MISO on rising SCLK edges
- Configurable system-clock divider using `CLK_DIV`
- `busy` and one-cycle `done` status signals
- Testbench with a simple SPI slave model that returns `8'hA5`

## Repository layout
```text
.
├── rtl/
│   └── spi_master.v
├── tb/
│   └── tb_spi_master.v
├── docs/
│   └── QFLOW_REPORT_CONTEXT.md
└── .gitignore
```

## Interface
| Signal | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst_n` | input | Active-low synchronous reset |
| `start` | input | Start a transfer when `busy=0` |
| `tx_data[7:0]` | input | Byte to transmit |
| `miso` | input | Data received from the selected SPI slave |
| `sclk` | output | SPI clock, idle low |
| `mosi` | output | Master-out data |
| `ss_n` | output | Active-low slave select |
| `rx_data[7:0]` | output | Received byte, updated when transfer completes |
| `busy` | output | High while a transfer is in progress |
| `done` | output | One-system-clock-cycle completion pulse |

## Run the simulation
If Icarus Verilog (`iverilog`) and `vvp` are installed, run these commands from the repository root:

```bash
iverilog -g2012 -o spi_sim rtl/spi_master.v tb/tb_spi_master.v
vvp spi_sim
```

Expected successful message:
```text
PASS: SPI transfer completed. TX=0x3C RX=0xA5
```

The testbench checks that the master completes a transfer and receives the expected byte from its simple slave model. This is a functional RTL simulation only; it does **not** prove that a physical-design flow has completed.

## Suggested next steps
1. Run the testbench and confirm the PASS message.
2. Inspect the waveforms for `sclk`, `mosi`, `miso`, `ss_n`, `busy`, and `done`.
3. Add tests for reset, another transmit byte, and boundary conditions.
4. If you later run this RTL through Qflow, add the actual logs, timing/area reports, layout screenshots and generated outputs. Do not claim physical-design results until you have run and checked them.

## Limitations
- One fixed 8-bit transfer per `start` pulse.
- SPI Mode 0 only; no configurable CPOL/CPHA, multi-byte transfers, FIFOs, interrupts, or multiple slave selection.
- The included testbench uses a simple behavioral slave model, not real hardware.
