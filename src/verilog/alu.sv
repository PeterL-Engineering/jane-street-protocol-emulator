module alu
        import isa_pkg::*;
#(
        parameter int unsigned DATA_WIDTH = 8
) (
        input   alu_fn_e                  alu_fn_i,
        input   logic [DATA_WIDTH-1:0]    data1_i,
        input   logic [DATA_WIDTH-1:0]    data2_i,

        output  logic [DATA_WIDTH-1:0]    data_o,
        output  logic                     zero_o
);

// ------------------------------------------------------------------
// Signal Declaration
// ------------------------------------------------------------------

        logic [DATA_WIDTH-1:0] add_result;
        logic [DATA_WIDTH-1:0] sub_result;
        logic [DATA_WIDTH-1:0] and_result;
        logic [DATA_WIDTH-1:0] or_result;
        logic [DATA_WIDTH-1:0] xor_result;
        logic [DATA_WIDTH-1:0] cmp_result;
        logic [DATA_WIDTH-1:0] not_result;
        
// ------------------------------------------------------------------
// Arithmetic/Logical Assignment
// ------------------------------------------------------------------



// ------------------------------------------------------------------
// Output Select
// ------------------------------------------------------------------

        always_comb begin : output_select
                case(alu_fn_i)
                        ALU_ADD:        data_o = add_result;   
                        ALU_SUB:        data_o = sub_result;
                        ALU_AND:        data_o = and_result;
                        ALU_OR:         data_o = or_result;
                        ALU_XOR:        data_o = xor_result;
                        ALU_CMP:        data_o = cmp_result;
                        ALU_NOT:        data_o = not_result;
                        default:        data_o = 'b0;
                endcase
        end

endmodule : alu

`default_nettype wire