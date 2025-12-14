module dff_delay_keep #(
    parameter DATA_WIDTH = 32
) (
    input   wire                                                clk,
    input   wire                                                rst,

    input   wire                         dff_delay_set_hold_flag_in,
    input   wire[DATA_WIDTH - 1: 0]           dff_delay_set_data_in,
    input   wire[DATA_WIDTH - 1: 0]    dff_delay_set_data_rst_value,
    output  reg[DATA_WIDTH - 1: 0]          dff_delay_set_data_out
);
    reg[DATA_WIDTH - 1: 0] out_reg;
    always @(posedge clk) begin
        if (rst == 1'b0) begin
            out_reg <= dff_delay_set_data_rst_value;
        end
        else if (dff_delay_set_hold_flag_in) begin
        end
        else begin
            out_reg <= dff_delay_set_data_in;
        end
    end
    assign dff_delay_set_data_out = out_reg;
endmodule