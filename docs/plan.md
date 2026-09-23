## 0 Overview
- This document provides a preliminary plan for the protocol emulator.
- Namely, it outlines the goals for the ISA and the corresponding microarchitectural requirements for the eventual SystemVerilog implementation.

## 1 Define ISA (Part 1)
- Determine and list every primitive based on the protocols that wish to be implemented
    - Include loop/branch support to minimize size of instruction cache
    - Write out programs for protocols using primitives to ensure comprehensiveness
    - Limit current scope to UART, SPI, I2C, and low-speed USB
- Decide on word length (ie. 16 vs 8-bit instructions)
    - Probably go with 16 bit with instruction memory capacity for 256 bytes (ie. 128 instructions)
    - Consider in conjunction with "2" to see SRAM are consumption for the instruction cache/memory
- Decide single-program vs multi-program residency
    - Probably more feasible/easier to do single-program

## 2 Area Evaluation and I/O
- Instantiate and synthesize various amounts of SRAM to validate word length and memory capacity
- Assign top-level I/O pins to protocols and control
    - Decide if pin direction is per-instruction or set globally per program (hard to say, but easier probably to implment the latter)
- Consider host-facing status/handshake signaling
    - Perhaps have status register, done/busy pin, etc
    
## 3 Define ISA with Microarchitecture (Part 2)
- Define number of registers required to implement ISA
    - PC, zero register(?), N x general purpose registers where N is dependent on the max required by any protocol
    - Estimate clock speed based on protocols
    - Decided against pipelining due to area and timing constraints
        - Given the limited area, the additional inter-stage registers would require considerable area
        - We are not concerned with instruction throughput but precise, cycle-accurate execution

## 4 Microarchitecture Topology
- Determine all other microarchitectural components/modules besdies registers
    - Consider modules specific to protocols eg. CRC for low-speed USB (check if larger instruction cache required)
    - ALU, shift registers, etc

## 5 Create Assembler
- Build a level 1 assembler in Python with support for labels and named constants
- Use two-pass approach to "compile" assembly file
    - First pass records label addresses
    - Second pass emits instructions
- Output either as a binary or $readmeh compatible hex file.

## 6 RTL Design
- Begin creating RTL modules and testing frequently
- Look into UVM to test modules rigorously