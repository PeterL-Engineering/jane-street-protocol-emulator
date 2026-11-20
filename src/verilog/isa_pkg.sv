package isa_pkg;

        // ------------------------------------------------------------
        // Instruction Fields
        // ------------------------------------------------------------

        localparam int DELAY_HI = 15;
        localparam int DELAY_LO = 13;
        localparam int SIDE_BIT = 12;
        localparam int OP_HI    = 11;
        localparam int OP_LO    = 8;

        // ------------------------------------------------------------
        // Primary Opcodes
        // ------------------------------------------------------------

        typedef enum logic [3:0] {
                OP_MISC  = 4'd0,
                OP_JMP   = 4'd1,
                OP_DJNZ  = 4'd2,
                OP_CALL  = 4'd3,
                OP_LDI   = 4'd4,
                OP_MOV   = 4'd5,
                OP_ALU   = 4'd6,
                OP_PINS  = 4'd7,
                OP_IN    = 4'd8,
                OP_WAITP = 4'd9,
                OP_ALUI  = 4'd10
        } opcode_e;

        // ------------------------------------------------------------
        // MISC Sub-opcodes: instr[7:5]
        // ------------------------------------------------------------

        typedef enum logic [2:0] {
                MISC_NOP  = 3'd0,
                MISC_RET  = 3'd1,
                MISC_SHR  = 3'd2,
                MISC_SHL  = 3'd3,
                MISC_DIR  = 3'd4,
                MISC_NRZI = 3'd5,
                MISC_CRC  = 3'd6,
                MISC_FIFO = 3'd7
        } misc_e;

        // ------------------------------------------------------------
        // JMP Conditions: instr[7:5]
        // ------------------------------------------------------------

        typedef enum logic [2:0] {
                COND_ALWAYS   = 3'd0,
                COND_Z        = 3'd1,
                COND_NZ       = 3'd2,
                COND_PIN1     = 3'd3,
                COND_PIN0     = 3'd4,
                COND_TX_EMPTY = 3'd5,
                COND_RX_FULL  = 3'd6,
                COND_ISR_FULL = 3'd7
        } cond_e;

        // ------------------------------------------------------------
        // ALU Function (reg-reg): instr[3:0]
        // ------------------------------------------------------------

        typedef enum logic [3:0] {
                ALU_ADD = 4'd0,
                ALU_SUB = 4'd1,
                ALU_AND = 4'd2,
                ALU_OR  = 4'd3,
                ALU_XOR = 4'd4,
                ALU_CMP = 4'd5,
                ALU_NOT = 4'd6
        } alu_fn_e;

        // ------------------------------------------------------------
        // ALUI Function (immediate): instr[5:4]
        // ------------------------------------------------------------

        typedef enum logic [1:0] {
                ALUI_ADDI = 2'd0,       // imm4 sign-extended
                ALUI_CMPI = 2'd1,       // imm4 zero-extended
                ALUI_ANDI = 2'd2,
                ALUI_ORI  = 2'd3
        } alui_fn_e;

        // ------------------------------------------------------------
        // MOV Endpoints: dst instr[7:4], src instr[3:0]
        // ------------------------------------------------------------

        typedef enum logic [3:0] {
                MV_R0   = 4'd0,
                MV_R1   = 4'd1,
                MV_R2   = 4'd2,
                MV_R3   = 4'd3,
                MV_ISR  = 4'd4,
                MV_OSR  = 4'd5,
                MV_PINS = 4'd6          // src only; dst acts as NOP
        } mov_ep_e;

        // ------------------------------------------------------------
        // PINS Source: instr[7:6]
        // ------------------------------------------------------------

        typedef enum logic [1:0] {
                PSRC_IMM  = 2'd0,
                PSRC_REG  = 2'd1,
                PSRC_OSR0 = 2'd2
        } pins_src_e;

        // ------------------------------------------------------------
        // WAITP Mode: instr[4:3]
        // ------------------------------------------------------------

        typedef enum logic [1:0] {
                WAIT_LOW  = 2'd0,
                WAIT_HIGH = 2'd1,
                WAIT_RISE = 2'd2,
                WAIT_FALL = 2'd3
        } waitp_mode_e;

        // ------------------------------------------------------------
        // CRC Mode: instr[2:0]
        // ------------------------------------------------------------
        
        typedef enum logic [2:0] {
                CRC_UPDATE   = 3'd0,
                CRC_READ     = 3'd1,
                CRC_RESET    = 3'd2,
                CRC_LOADINIT = 3'd3
        } crc_mode_e;

endpackage