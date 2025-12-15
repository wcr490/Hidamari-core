module instr_decode_delay (
    input wire clk,
    input wire rst,

    input wire idd_jump_flag_in,

    input wire[31: 0] idd_instr_addr_in,
    input wire[31: 0] idd_instr_in,
    input wire[4: 0] idd_write_addr_in,
    input wire[4: 0] idd_reg1_addr_in,
    input wire[4: 0] idd_reg2_addr_in,
    input wire[31: 0] idd_op1_in,
    input wire[31: 0] idd_op2_in,
    input wire[31: 0] idd_jump_op1_in,
    input wire[31: 0] idd_jump_op2_in,
    input wire[31: 0] idd_mem_write_addr_offset_in,
    input wire idd_wen_in,

    output wire[31: 0] idd_instr_addr_out,
    output wire[31: 0] idd_instr_out,
    output wire[4: 0] idd_write_addr_out,
    output wire[4: 0] idd_reg1_addr_out,
    output wire[4: 0] idd_reg2_addr_out,
    output wire[31: 0] idd_op1_out,
    output wire[31: 0] idd_op2_out,
    output wire[31: 0] idd_jump_op1_out,
    output wire[31: 0] idd_jump_op2_out,
    output wire[31: 0] idd_mem_write_addr_offset_out,
    output wire idd_wen_out
);
    dff_delay_keep#(.DATA_WIDTH(32)) dff_delay_set_instr_addr(
        .clk(clk), 
        .rst(rst), 
        .dff_delay_set_hold_flag_in(idd_jump_flag_in),
        .dff_delay_set_data_in(idd_instr_addr_in),
        .dff_delay_set_data_rst_value(32'b0),
        .dff_delay_set_data_out(idd_instr_addr_out)
        );
    dff_delay_keep#(.DATA_WIDTH(32)) dff_delay_set_instr(
        .clk(clk), 
        .rst(rst), 
        .dff_delay_set_hold_flag_in(idd_jump_flag_in),
        .dff_delay_set_data_in(idd_instr_in),
        .dff_delay_set_data_rst_value(32'b0),
        .dff_delay_set_data_out(idd_instr_out)
        );
    dff_delay_keep#(.DATA_WIDTH(5)) dff_delay_set_write_addr(
        .clk(clk), 
        .rst(rst), 
        .dff_delay_set_hold_flag_in(idd_jump_flag_in),
        .dff_delay_set_data_in(idd_write_addr_in),
        .dff_delay_set_data_rst_value(5'b0),
        .dff_delay_set_data_out(idd_write_addr_out)
        );
    dff_delay_keep#(.DATA_WIDTH(5)) dff_delay_set_reg1_addr(
        .clk(clk), 
        .rst(rst), 
        .dff_delay_set_hold_flag_in(idd_jump_flag_in),
        .dff_delay_set_data_in(idd_reg1_addr_in),
        .dff_delay_set_data_rst_value(5'b0),
        .dff_delay_set_data_out(idd_reg1_addr_out)
        );
    dff_delay_keep#(.DATA_WIDTH(5)) dff_delay_set_reg2_addr(
        .clk(clk), 
        .rst(rst), 
        .dff_delay_set_hold_flag_in(idd_jump_flag_in),
        .dff_delay_set_data_in(idd_reg2_addr_in),
        .dff_delay_set_data_rst_value(5'b0),
        .dff_delay_set_data_out(idd_reg2_addr_out)
        );
    dff_delay_keep#(.DATA_WIDTH(32)) dff_delay_set_op1(
        .clk(clk), 
        .rst(rst), 
        .dff_delay_set_hold_flag_in(idd_jump_flag_in),
        .dff_delay_set_data_in(idd_op1_in),
        .dff_delay_set_data_rst_value(32'b0),
        .dff_delay_set_data_out(idd_op1_out)
        );
    dff_delay_keep#(.DATA_WIDTH(32)) dff_delay_set_op2(
        .clk(clk), 
        .rst(rst), 
        .dff_delay_set_hold_flag_in(idd_jump_flag_in),
        .dff_delay_set_data_in(idd_op2_in),
        .dff_delay_set_data_rst_value(32'b0),
        .dff_delay_set_data_out(idd_op2_out)
        );
    dff_delay_keep#(.DATA_WIDTH(32)) dff_delay_set_jump_op1(
        .clk(clk), 
        .rst(rst), 
        .dff_delay_set_hold_flag_in(idd_jump_flag_in),
        .dff_delay_set_data_in(idd_jump_op1_in),
        .dff_delay_set_data_rst_value(32'b0),
        .dff_delay_set_data_out(idd_jump_op1_out)
        );
    dff_delay_keep#(.DATA_WIDTH(32)) dff_delay_set_jump_op2(
        .clk(clk), 
        .rst(rst), 
        .dff_delay_set_hold_flag_in(idd_jump_flag_in),
        .dff_delay_set_data_in(idd_jump_op2_in),
        .dff_delay_set_data_rst_value(32'b0),
        .dff_delay_set_data_out(idd_jump_op2_out)
        );
    dff_delay_keep#(.DATA_WIDTH(32)) dff_delay_set_mem_write_addr_offset(
        .clk(clk), 
        .rst(rst), 
        .dff_delay_set_hold_flag_in(idd_jump_flag_in),
        .dff_delay_set_data_in(idd_mem_write_addr_offset_in),
        .dff_delay_set_data_rst_value(32'b0),
        .dff_delay_set_data_out(idd_mem_write_addr_offset_out)
        );
    dff_delay_keep#(.DATA_WIDTH(1)) dff_delay_set_wen(
        .clk(clk), 
        .rst(rst), 
        .dff_delay_set_hold_flag_in(idd_jump_flag_in),
        .dff_delay_set_data_in(idd_wen_in),
        .dff_delay_set_data_rst_value(1'b0),
        .dff_delay_set_data_out(idd_wen_out)
        );
endmodule