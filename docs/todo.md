## List of Modules

## Tier 0: definitions
- isa_pkg.sv: opcodes, MISC sub-ops, JMP conds, ALU fn, field positions

## Tier 1: leaf modules
- alu.sv: ADD/SUB/AND/OR/XOR/CMP/NOT, Z out (shared by ALU and ALUI)
- cond_eval.sv: JMP condition select (Z, jmp_pin, FIFO/ISR flags)
- shift_reg.sv: ISR/OSR, shift dir, load, threshold flag (instantiate twice)
- fifo.sv: parameterized depth/width, wr/rd ptr, full/empty
- crc_lfsr.sv: width, tap mask, init, xor-out, update/read/reset
- nrzi_enc.sv: NRZI encode + bit-stuff counter
- input_sync.sv: 2-FF synchronizer
- clk_div.sv: programmable counter -> one-cycle tick enable
- delay_counter.sv: loads delay field, counts ticks, stall flag
- call_stack.sv: depth-2 return address stack

## Tier 2: composed blocks
- pc.sv: PC, relative-jump adder, call/ret mux, stall hold
- pin_io.sv: out reg, dir reg, side-set, pin mapping, synced inputs, edge detect
- imem.sv: instruction SRAM/flop wrapper (host write port, core read port)

## Tier 3: control
- instr_decode.sv: opcode/sub-op -> control signals, immediates
- sequencer.sv: fixed N-cycle FSM, write gating, stall handling

## Tier 4: integration
- config_regs.sv: clkdiv, pin maps, CRC cfg, thresholds, enable
- host_if.sv: SPI/UART slave -> imem, config, FIFO access
- datapath.sv: regfile, alu, shift regs, crc, pin_io, fifo muxing
- core.sv: pc + imem + decode + sequencer + datapath
- tt_um_<name>.sv: top level, core + host_if + config + TT pin mapping

## Build order
isa_pkg -> alu -> shift_reg -> fifo -> crc_lfsr -> nrzi_enc ->
input_sync / clk_div / delay_counter -> pc / call_stack ->
instr_decode / sequencer -> datapath -> core -> host_if (last)