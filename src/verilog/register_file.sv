`default_nettype none

module register_file #(
        parameter int unsigned ADDR_WIDTH = 4,
        parameter int unsigned DATA_WIDTH = 16
) (
        input   logic                           clk,
        input   logic                           rst_n,
        input   logic                           we,
        input   logic   [ADDR_WIDTH-1:0]        read_addr1_i,
        input   logic   [ADDR_WIDTH-1:0]        read_addr2_i,
        input   logic   [ADDR_WIDTH-1:0]        write_addr_i,
        input   logic   [DATA_WIDTH-1:0]        write_data_i,

        output  logic   [DATA_WIDTH-1:0]        read_data1_o,
        output  logic   [DATA_WIDTH-1:0]        read_data2_o
);

// ------------------------------------------------------------------
// Signal Declaration
// ------------------------------------------------------------------

        // can I generate a variable number of signals based on addr width?

// ------------------------------------------------------------------
// Write Enable
// ------------------------------------------------------------------

        always_comb begin : write_enable
                case(write_addr_i)
                        // can I do this using generate so that it's variable to addr width?
                endcase
        end

// ------------------------------------------------------------------
// Registers
// ------------------------------------------------------------------

        // use generate block to generate enough registers for addr width?
        // connect via signals declared

// ------------------------------------------------------------------
// Output Read Select
// ------------------------------------------------------------------

        // possible to make module that takes in all regs current data
        // and assigns read_data1_o and read_data2_o accordingly
        // can I use generate to make this variable to addr_width? 


endmodule : register_file

`default_nettype wire