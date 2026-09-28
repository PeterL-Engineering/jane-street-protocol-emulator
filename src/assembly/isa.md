# Protocol Emulator ISA

## Conventions
- Word: 16-bit instruction, 8 (or 12) MHz+ core clock, all instrs 1 cycle unless noted
- Registers: r0-r3 (8-bit GP), ISR (8-bit in shift), OSR (8-bit out shift), PC, STATUS flags (Z, C)
- Pins: P0-P7 (output data), direction register DIR (1 = drive, 0 = release/high-Z)
- Every instruction has a 3-bit `delay` field (0-7 extra cycles, PIO-style)
- Every instruction has a `side-set` field (writes pins in parallel)

## 1. Control Flow
| Mnemonic | Operands | Cycles | Description |
|---|---|---|---|
| NOP | - | 1 | No operation (delay slot filler) |
| JMP | addr | 1 | Unconditional jump |
| JZ / JNZ | addr | 1 | Jump if Z flag set / clear |
| DJNZ | rN, addr | 1 | Decrement rN, jump if not zero (bit counters) |
| JPIN | pin, level, addr | 1 | Jump if pin == level (ACK check, bus idle check) |
| CALL / RET | addr / - | 1 | Subroutine call/return (small hw stack, depth 2-4) |
| HALT | - | - | Stop core until external restart |

## 2. Data Movement and ALU
| Mnemonic | Operands | Cycles | Description |
|---|---|---|---|
| MOV | rD, rS | 1 | Register copy |
| LDI | rD, imm8 | 1 | Load immediate |
| MOV | OSR, rS / rD, ISR | 1 | Move to/from shift registers |
| ADD / SUB | rD, rS/imm | 1 | Arithmetic, sets Z/C |
| AND / OR / XOR | rD, rS/imm | 1 | Logic, sets Z (XOR used for CRC, NRZI) |
| SHL / SHR | rD, n | 1 | Shift, carry out to C |
| CMP | rA, rB/imm | 1 | Set flags, no writeback |

## 3. Pin I/O (the core of the chip)
| Mnemonic | Operands | Cycles | Description |
|---|---|---|---|
| SET | pin, 0/1 | 1 | Drive single pin |
| SETM | mask, value | 1 | Atomic multi-pin write (USB D+/D- same cycle) |
| DIR | mask, value | 1 | Set pin direction (I2C release vs drive low) |
| OUT | pin, rS[bit] | 1 | Drive pin with a bit of a register |
| OUTS | pin, n | 1 | Shift n bits from OSR onto pin (LSB first), OSR >>= n |
| IN | pin | 1 | Sample pin into ISR MSB, ISR >>= 1 |
| INS | pin, n | n | Sample n bits into ISR |
| RDP | rD, mask | 1 | Read pin bus (masked) into register |

## 4. Timing
| Mnemonic | Operands | Cycles | Description |
|---|---|---|---|
| WAIT | n | n+1 | Idle n cycles (baud/bit timing) |
| WAITR | rN | rN+1 | Idle for register-specified cycles (runtime baud) |
| WPIN | pin, level | var | Stall until pin == level (start bit, clock stretch) |
| WEDGE | pin, rise/fall | var | Stall until edge detected (USB resync) |
| TMR | n | 1 | Start hw timer for n cycles (non-blocking) |
| WTMR | - | var | Stall until timer expires (fixed-rate loops with work inside) |
| TIMEOUT | n | 1 | Set watchdog: jump to timeout vector if WPIN/WEDGE exceeds n cycles |

## 5. Protocol Assist (hardware accelerators)
| Mnemonic | Operands | Cycles | Description |
|---|---|---|---|
| NRZI | pin, rS[bit] | 1 | NRZI encode: toggle line if bit==0, hold if 1 (USB) |
| STUFF | - | 1 | Track consecutive 1s; if count==6, insert 0 and stall shifter (USB) |
| DESTUFF | - | 1 | RX inverse: drop stuffed 0 after six 1s |
| CRC | poly_sel, rS[bit] | 1 | Update CRC reg with one bit (CRC5 for USB tokens, CRC16 for data) |
| CRCRD | rD | 1 | Read CRC register, optionally inverted |
| CRCRST | init | 1 | Reset CRC to init value (USB: all 1s) |
| PAR | rD, rS | 1 | Compute parity of rS into rD (UART parity, optional) |

## 6. Autopush / Autopull (optional, PIO-style)
| Mnemonic | Operands | Cycles | Description |
|---|---|---|---|
| PULL | - | 1 | Load OSR from TX FIFO, block if empty |
| PUSH | - | 1 | Push ISR to RX FIFO, block if full |
| (config) | threshold n | - | Auto PULL when OSR empty after n bits; auto PUSH when ISR reaches n bits |

## 7. Instruction to protocol coverage
| Protocol | Key instructions used |
|---|---|
| UART TX | SET, OUTS, WAIT, DJNZ, PAR |
| UART RX | WPIN, WAIT, IN, DJNZ, PUSH |
| SPI | SET, OUT, IN, DJNZ, side-set (SCK + MOSI in one instr) |
| I2C | DIR, SET, WPIN (clock stretch), JPIN (ACK), TIMEOUT |
| USB LS TX | SETM, NRZI, STUFF, CRC, OUTS, PULL |
| USB LS RX | WEDGE, IN, DESTUFF, CRC, PUSH |