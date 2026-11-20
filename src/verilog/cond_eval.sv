`default_nettype none

module logicval
        import isa_pkg::*;
(
        input   cond_e cond_i,
        input   logic  z_flag_i,
        input   logic  jmp_pin_i,
        input   logic  tx_empty_i,
        input   logic  rx_full_i,
        input   logic  isr_full_i

        output  logic   take_jmp_o   
);

always_comb begin : cond_select
        case (cond_i)
                COND_ALWAYS:    take_jmp_o = 1'b1;
                COND_Z:         take_jmp_o = z_flag_i;
                COND_NZ:        take_jmp_o = ~z_flag_i;
                COND_PIN1:      take_jmp_o = jmp_pin_i;
                COND_PIN0:      take_jmp_o = ~jmp_pin_i;
                COND_TX_EMPTY:  take_jmp_o = tx_empty_i;
                COND_RX_FULL:   take_jmp_o = rx_full_i;
                COND_ISR_FULL:  take_jmp_o = isr_full_i;
                default:        take_jmp_o = 1'b0;
        endcase
end

endmodule : cond_eval

`default_nettype wire