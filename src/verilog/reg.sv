`default_nettype none

module register #(
        parameter int unsigned DATA_WIDTH = 16
) (
        input   logic                           clk,
        input   logic                           rst_n,
        input   logic                           we,
        input   logic   [DATA_WIDTH-1:0]        data_i,
        output  logic   [DATA_WIDTH-1:0]        data_o
);

        always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n)
                        data_o <= '0;
                else if (we)
                        data_o <= data_i;
        end

endmodule : register

`default_nettype wire