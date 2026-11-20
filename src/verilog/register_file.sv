`default_nettype none

module register_file #(
        parameter int unsigned NUM_REGS         = 16,
        parameter int unsigned DATA_WIDTH       = 16,
        localparam int unsigned ADDR_WIDTH      = $clog2(NUM_REGS)
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

        logic [NUM_REGS-1:0]      reg_we;
        logic [DATA_WIDTH-1:0]    reg_data [NUM_REGS];

// ------------------------------------------------------------------
// Write Enable
// ------------------------------------------------------------------

        always_comb begin : write_enable
                reg_we = '0;
                if (write_addr_i < NUM_REGS)
                        reg_we[write_addr_i] = we;
        end

// ------------------------------------------------------------------
// Registers
// ------------------------------------------------------------------

        for (genvar i = 0; i < NUM_REGS; i++) begin : gen_regs
                register #(
                        .DATA_WIDTH     (DATA_WIDTH)
                ) u_reg (
                        .clk            (clk),
                        .rst_n          (rst_n),
                        .we             (reg_we[i]),
                        .data_i         (write_data_i),
                        .data_o         (reg_data[i])
                );
        end 

// ------------------------------------------------------------------
// Output Read Select
// ------------------------------------------------------------------

        assign read_data1_o = reg_data[read_addr1_i];
        assign read_data2_o = reg_data[read_addr2_i];

endmodule : register_file

`default_nettype wire