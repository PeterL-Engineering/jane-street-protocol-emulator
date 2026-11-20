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



endmodule : alu

`default_nettype wire