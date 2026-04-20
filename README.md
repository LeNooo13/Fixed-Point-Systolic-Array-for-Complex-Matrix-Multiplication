# Fixed-Point Systolic Array for Complex Matrix Multiplication

## Overview
This project implements a 4×4 complex-valued systolic array for matrix multiplication, focusing on fixed-point design and hardware-efficient architecture.

The work covers the complete digital IC design flow, including:
- Algorithm modeling (MATLAB)
- Fixed-point conversion and SQNR analysis
- RTL design in Verilog
- Functional verification
- Synthesis and APR

## Architecture
- 4×4 systolic array structure
- Each Processing Element (PE) performs:
  - Complex multiplication
  - Accumulation
- Pipelined dataflow across diagonal computation stages
- ![image](https://github.com/LeNooo13/Fixed-Point-Systolic-Array-for-Complex-Matrix-Multiplication/blob/main/080cce7e-f019-4143-9aca-42ca1d683907.jpg)

## RTL Implementation
- Implemented systolic array architecture in Verilog
- Modular design with PE as basic computation unit
- Verified functionality using testbench simulations

Files:
- `systolic_rtl.v` : top module
- `PE.v` : processing element
- `systolic_rtb.v` : testbench
