module dff_delay_set #(
    parameter DATA_WIDTH = 32
) (
    input   wire                                                clk,
    input   wire                                                rst,

    input   wire                         dff_delay_set_jump_flag_in,
    input   wire[DATA_WIDTH - 1: 0]           dff_delay_set_data_in,
    input   wire[DATA_WIDTH - 1: 0]    dff_delay_set_data_rst_value,
    output  reg[DATA_WIDTH - 1: 0]          dff_delay_set_data_out
);
    always @(posedge clk) begin
        if (rst == 1'b0 || dff_delay_set_jump_flag_in)
            dff_delay_set_data_out <= dff_delay_set_data_rst_value;
        else
            dff_delay_set_data_out <= dff_delay_set_data_in;
    end
endmodule