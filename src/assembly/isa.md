## Protocol Emulator ISA (v2)

## Conventions
- 16-bit instruction, fixed N cycles per instruction (N = 4-5, short ops idle-padded)
- Registers: r0-r3 (8-bit), ISR, OSR (8-bit shift regs), PC, flag Z
- Harvard: instruction SRAM only. No load/store. Peripherals reached by instructions
- Jumps PC-relative. Hardware call stack depth 2
- Masks, pin bases, thresholds, baud, polarity live in config regs, not in instructions

## Encoding
| Bits | Field |
|---|---|
| [15:13] | delay: 0-7 extra instruction slots |
| [12] | side: drive P0 (SCK) per config |
| [11:8] | opcode |
| [7:0] | operands |

## Primary opcodes (10 used, 6 free)
| Op | Mnemonic | Operands [7:0] | Notes |
|---|---|---|---|
| 0 | MISC | sub[7:5] + arg[4:0] | see below |
| 1 | JMP | cond[7:5] + off[4:0] | cond: always, Z, !Z, jmp_pin==1, jmp_pin==0. off signed -16..+15 |
| 2 | DJNZ | rN[7:6] + off[5:0] | dec rN, jump if nonzero. off -32..+31 |
| 3 | CALL | addr[7:0] | absolute, 256 words |
| 4 | LDI | rD[7:6] + imm[5:0] | zero-extended, 0-63 |
| 5 | MOV | dst[7:4] + src[3:0] | r0-r3, ISR, OSR, PINS |
| 6 | ALU | rD[7:6] + fn[5:4] + src[3:0] | fn: XOR, AND, XORI, ANDI. src = reg or imm4. Sets Z |
| 7 | PINS | src[7:6] + data[5:0] | src: imm / reg / OSR bit0. Pins chosen by out_base/out_count config |
| 8 | IN | pin[7:5] | sample pin into ISR, shift right |
| 9 | WAITP | pin[7:5] + mode[4:3] | mode: low, high, rise, fall. Timeout via watchdog config |
| 10-15 | free | | growth |

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

## Config registers (host-written)
clkdiv, out_base, out_count, dir init, jmp_pin, side pin, in_base,
shift dir and autopush/pull thresholds, stuff/destuff enable,
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