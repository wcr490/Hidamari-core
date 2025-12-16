`include "./core/core_defines.v"

module instr_fetch_delay (
    input   wire                          clk,
    input   wire                          rst,

    input   wire             ifd_jump_flag_in,

    input   wire[31: 0]     ifd_instr_addr_in,
    input   wire[31: 0]          ifd_instr_in,
    input   wire             ifd_instr_valid_in,
    output  wire[31: 0]    ifd_instr_addr_out,
    output  wire[31: 0]         ifd_instr_out,
    output  wire             ifd_instr_valid_out
);
    dff_delay_keep#(.DATA_WIDTH(32)) dff_delay_keep_addr(
        .clk(clk), 
        .rst(rst), 
        .dff_delay_set_hold_flag_in(ifd_jump_flag_in),
        .dff_delay_set_data_in(ifd_instr_addr_in), 
        .dff_delay_set_data_rst_value(32'b0),
        .dff_delay_set_data_out(ifd_instr_addr_out)
        );

    dff_delay_set#(.DATA_WIDTH(32)) dff_delay_set_instr(
        .clk(clk), 
        .rst(rst), 
        .dff_delay_set_hold_flag_in(ifd_jump_flag_in),
        .dff_delay_set_data_in(ifd_instr_in), 
        .dff_delay_set_data_rst_value(`INSTR_NOP),
        .dff_delay_set_data_out(ifd_instr_out)
        );
        
    dff_delay_set#(.DATA_WIDTH(1)) dff_delay_set_valid(
        .clk(clk), 
        .rst(rst), 
        .dff_delay_set_hold_flag_in(ifd_jump_flag_in),
        .dff_delay_set_data_in(ifd_instr_valid_in), 
        .dff_delay_set_data_rst_value(1'b0),
        .dff_delay_set_data_out(ifd_instr_valid_out)
        );
endmodule