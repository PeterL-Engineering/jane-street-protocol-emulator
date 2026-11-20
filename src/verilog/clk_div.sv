`default_nettype none

module clk_div #(
        parameter int unsigned DIV_WIDTH = 16
) (
        input   logic                   clk,
        input   logic                   rst_n,
        input   logic                   enable_i,
        input   logic [DIV_WIDTH-1:0]   clk_config_i,

        output  logic                   ce_o
);

        logic [DIV_WIDTH-1:0]   count_q;

        always_ff @(posedge clk or negedge rst_n) begin : count_clk
                if (!rst_n) begin
                        count_q <= '0;
                        ce_o    <= 1'b0;
                end else begin
                        ce_o <= 1'b0;
                        if (!enable_i) begin
                                count_q <= '0;
                        end else if (count_q == clk_config_i) begin
                                count_q <= '0;
                                ce_o    <= 1'b1;
                        end else begin
                                count_q <= count_q + 1'b1;
                        end
                end
        end

endmodule : clk_div

`default_nettype wire