# Protocol Emulator ISA (v3)

## Conventions
- 16-bit instruction, fixed N cycles per instruction (N = 4-5, short ops idle-padded)
- Registers: r0-r3 (8-bit), ISR, OSR (8-bit shift regs), PC, flag Z
- Harvard: instruction SRAM only, no load/store. Peripherals reached by instructions
- Jumps PC-relative. Hardware call stack depth 2
- Masks, pin bases, thresholds, baud, polarity live in config regs, not instructions
- Pins sampled and driven on the last cycle of the instruction
- If PINS and side-set both write P0 in one instruction, PINS wins
- Unused opcodes / sub-ops / fn codes execute as NOP

## Encoding
| Bits | Field |
|---|---|
| [15:13] | delay: 0-7 extra instruction slots |
| [12] | side: drive P0 (SCK) per config |
| [11:8] | opcode |
| [7:0] | operands |

## Primary opcodes (11 used, 5 free)
| Op | Mnemonic | Operands [7:0] | Notes |
|---|---|---|---|
| 0 | MISC | sub[7:5] + arg[4:0] | see below |
| 1 | JMP | cond[7:5] + off[4:0] | off signed -16..+15 |
| 2 | DJNZ | rN[7:6] + off[5:0] | dec rN, jump if nonzero. off -32..+31 |
| 3 | CALL | addr[7:0] | absolute, 256 words |
| 4 | LDI | rD[7:6] + imm[5:0] | zero-extended, 0-63 |
| 5 | MOV | dst[7:4] + src[3:0] | see MOV |
| 6 | ALU | rD[7:6] + rS[5:4] + fn[3:0] | reg-reg, see ALU |
| 7 | PINS | src[7:6] + data[5:0] | src: imm / reg / OSR bit0. Pins via out_base/out_count config |
| 8 | IN | pin[7:5] | sample pin into ISR, shift right |
| 9 | WAITP | pin[7:5] + mode[4:3] | mode: low, high, rise, fall. Timeout via watchdog config |
| 10 | ALUI | rD[7:6] + fn[5:4] + imm[3:0] | see ALUI |
| 11-15 | free | | growth |

## JMP conditions (cond[7:5])
| Code | Condition |
|---|---|
| 0 | always (`JMP always, -1` = halt) |
| 1 | Z |
| 2 | !Z |
| 3 | jmp_pin == 1 |
| 4 | jmp_pin == 0 |
| 5 | TX FIFO empty |
| 6 | RX FIFO full |
| 7 | ISR full (threshold reached) |

## ALU (rD = rD fn rS)
| fn | Op | Notes |
|---|---|---|
| 0 | ADD | |
| 1 | SUB | rD - rS |
| 2 | AND | |
| 3 | OR | |
| 4 | XOR | NRZI, CRC-style toggles |
| 5 | CMP | SUB, result discarded, sets Z only |
| 6 | NOT | rD = ~rS |
| 7-15 | reserved | NOP |

## ALUI (rD = rD fn imm4)
| fn | Op | imm |
|---|---|---|
| 0 | ADDI | sign-extended (-8..+7), so SUB imm = ADDI negative |
| 1 | CMPI | zero-extended, sets Z only |
| 2 | ANDI | zero-extended |
| 3 | ORI | zero-extended |

## MOV (dst[7:4], src[3:0])
| Code | Endpoint | As src | As dst |
|---|---|---|---|
| 0-3 | r0-r3 | yes | yes |
| 4 | ISR | yes | yes |
| 5 | OSR | yes | yes |
| 6 | PINS | yes (synchronized read of input pins, from in_base) | no, use PINS op |
| 7-15 | reserved | | |

## MISC sub-opcodes (sub[7:5], arg[4:0])
| Sub | Mnemonic | arg |
|---|---|---|
| 0 | NOP | - (carrier for delay / side) |
| 1 | RET | - |
| 2 | SHR | rD[1:0]; LSB into Z |
| 3 | SHL | rD[1:0]; MSB into Z |
| 4 | DIR | pin[2:0] + val[3]; 1 = drive, 0 = release |
| 5 | NRZI | src[1:0]; toggle output if bit == 0, stuffing per config |
| 6 | CRC | mode[2:0]: update / read / reset / load-init |
| 7 | FIFO | dir[0]: push ISR -> RX / pull TX -> OSR |

## Flag Z
Set by: ALU, ALUI (incl. CMP/CMPI), SHR, SHL (shifted-out bit). Not changed by MOV, LDI, PINS, IN.

## Config registers (host-written)
clkdiv, out_base, out_count, in_base, jmp_pin, side pin, initial dir,
shift direction, autopush/pull thresholds, stuff/destuff enable,
CRC width / poly / init / xor-out, watchdog timeout, enable

## Protocol coverage
| Protocol | Instructions |
|---|---|
| UART TX | PINS, NOP [n], DJNZ, SHR, FIFO |
| UART RX | WAITP, NOP [n], IN, DJNZ, FIFO |
| SPI | PINS + side (SCK), IN, DJNZ, FIFO |
| I2C | DIR, PINS, WAITP (clock stretch), JMP pin (ACK), watchdog |
| USB LS TX | PINS, NRZI, CRC, FIFO, stuffing config |
| USB LS RX | WAITP (edge), IN, CRC, FIFO, destuff config |