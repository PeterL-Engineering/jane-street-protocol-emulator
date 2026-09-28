# Protocol Emulator ISA

## Conventions
- Word: 16-bit, each instruction = 1 cycle + `delay` extra cycles (0-15)
- Registers: r0-r3 (8-bit), ISR, OSR (8-bit shift regs), PC, flag Z
- Pins: P0-P7, DIR register (1 = drive, 0 = release)
- Every instruction carries: `delay[3:0]` (4b) and `side` (1b, drives P0 = SCK; 0 = leave, 1 = toggle/drive per config)
- Pure delay = `NOP [n]`. Pin-only write = `NOP side=x`. No WAIT/SET instructions.
- Runtime baud control = clock divider config register (not an instruction)
- Jumps are PC-relative: target = PC + sign_extend(offset), offset is 6-bit signed (-32..+31)

## 1. Control Flow (5 ops)
| Mnemonic | Operands | Description |
|---|---|---|
| NOP | - | Carrier for delay / side-set |
| JMP | cond[2:0], off[5:0] | PC-relative. cond = always / Z / !Z / pin==1 / pin==0. `JMP always, -1` = halt-in-place |
| DJNZ | rN[1:0], off[3:0] | Decrement rN, PC-relative jump if nonzero; 4-bit signed offset (-8..+7), enough for tight bit loops |
| CALL/RET | addr[4:0] / - | Absolute 5-bit target (32-word page), mode bit selects CALL vs RET, hw stack depth 2 |
| HALT | - | Removed; use `JMP always, -1` |

## 2. Data Movement and ALU (4 ops)
| Mnemonic | Operands | Description |
|---|---|---|
| LDI | rD, imm | Load immediate |
| MOV | dst, src | rN / OSR / ISR / PINS (absorbs RDP, register side of PULL/PUSH) |
| XOR/AND | rD, rS/imm | One op with mode bit, sets Z (NRZI, CRC, masking, parity) |
| SHR | rD | Shift right by 1, LSB into Z (bit tests); shift-by-n via repeat |

## 3. Pin I/O (4 ops)
| Mnemonic | Operands | Description |
|---|---|---|
| PINS | src, mask | Write pins from imm / reg / OSR bit0 with mask (replaces SET, SETM, OUT, OUTS) |
| DIR | mask, value | Pin direction control (I2C release vs drive low) |
| IN | pin/src | Sample into ISR, shift right (replaces IN, INS, RDP; repeat for n bits) |
| WAITP | pin, level/edge | Stall until pin level or edge (replaces WPIN, WEDGE) |

## 4. Timing (0 ops)
| Mechanism | Description |
|---|---|
| `delay[3:0]` field | 0-15 extra cycles on any instruction (replaces WAIT) |
| Clock divider config | Runtime-programmable bit period (replaces WAITR) |
| Watchdog config | Timeout on WAITP via config register (replaces TIMEOUT) |
| Dropped | TMR, WTMR |

## 5. Protocol Assist (3 ops)
| Mnemonic | Operands | Description |
|---|---|---|
| NRZI | bit_src | Toggle output if bit==0 (USB); bit stuffing enabled by config bit |
| CRC | mode | Sub-modes: update(bit) / read / reset / poly select (CRC5, CRC16) |
| FIFO | push/pull | ISR -> RX FIFO / TX FIFO -> OSR; autopush/pull threshold via config |

## 6. Encoding Budget (16 bits)
| Field | Bits |
|---|---|
| delay | 4 |
| side-set | 1 |
| opcode | 4 (15 ops after removing HALT) |
| operands | 7 |

Operand layouts:
| Op | Layout (7 bits) |
|---|---|
| JMP | cond[2:0] + off[3:0]? Too small: use cond[0:0] variants (see below) |
| DJNZ | rN[1:0] + off[4:0] (5-bit signed, -16..+15) |
| CALL/RET | mode[0] + addr[5:0] (64-word absolute) |
| LDI | rD[1:0] + imm[4:0] |

## 8. Instruction to Protocol Coverage
| Protocol | Key instructions used |
|---|---|
| UART TX | PINS, NOP [n], DJNZ, SHR, MOV OSR, FIFO |
| UART RX | WAITP, NOP [n], IN, DJNZ, FIFO |
| SPI | PINS + side-set (SCK), IN, DJNZ, FIFO |
| I2C | DIR, PINS, WAITP (clock stretch), JMP pin (ACK), watchdog config |
| USB LS TX | PINS (D+/D- mask), NRZI, CRC, FIFO, stuffing config |
| USB LS RX | WAITP (edge), IN, CRC, FIFO, destuff config |