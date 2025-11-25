`include "./core/core_defines.v"

module cpu (
    input clk,
    input rst,

    input wire instr_valid_in,
    input wire instr_ready_in,
    input wire[31: 0] instr_in,
    output reg[31: 0] instr_addr_out,
    output reg instr_addr_valid_out,

    input wire cpu_mem_valid_in,
    input wire[31: 0] cpu_mem_rdata_in,
    output wire[31: 0] cpu_mem_wdata_out,
    output wire[3: 0] cpu_mem_write_byte_en_out,
    output wire[31: 0] cpu_mem_addr_out
);
    wire[31: 0] jump_addr;
    wire jump_flag;
    wire[31: 0] flush_ctrl_jump_addr;
    wire flush_ctrl_jump_flag;
    wire hold_flag;
    flush_ctrl flush_ctrl_inst(
        .fc_jump_flag_in(jump_flag),
        .fc_jump_addr_in(jump_addr),
        .fc_jump_flag_out(flush_ctrl_jump_flag),
        .fc_jump_addr_out(flush_ctrl_jump_addr),
        .hold_flag_out(hold_flag)
    );



    reg [1:0] instr_state;
    reg instr_ready;
    localparam INSTR_IDLE = 2'b00;
    localparam INSTR_REQUEST = 2'b01;
    localparam INSTR_RESPONSE = 2'b10;

    // Need to be connected to i_ram
    reg[31: 0] if_instr_reg;
    reg if_valid_reg;

    wire[31: 0] instr = if_instr_reg;
    wire instr_valid = if_valid_reg;
    wire[31: 0] instr_addr;

    // Used to hold the pc increment
    wire if_hold_flag = flush_ctrl_jump_flag || !instr_ready;

    always @(posedge clk) begin
        if (!rst) begin
            if_instr_reg <= 32'h0;
            if_valid_reg <= 1'b0;
            instr_state <= INSTR_IDLE;
            instr_ready <= 1'b0;
            instr_addr_valid_out <= 1'b0;
            instr_addr_out <= `INSTR_NOP;
        end
        else begin
            instr_addr_out <= instr_addr;
            // if_valid_reg <= 1'b1;
            case (instr_state)
                INSTR_IDLE: begin
                    instr_ready <= 1'b0;
                    if (!flush_ctrl_jump_flag) begin
                        instr_state <= INSTR_REQUEST;
                    end
                end
                INSTR_REQUEST: begin
                    instr_addr_valid_out <= 1'b1;
                    if (instr_ready_in) begin
                        instr_state <= INSTR_RESPONSE;
                    end
                end
                INSTR_RESPONSE: begin
                    if (instr_valid_in) begin
                        if_instr_reg <= instr_in;
                        if_valid_reg <= 1'b1;
                        instr_ready <= 1'b1;
                        instr_state <= INSTR_IDLE;
                    end
                end
            endcase
        end
    end



    pc_reg pc_reg_inst(
        .clk(clk),
        .rst(rst),
        .pc_jump_flag_in(flush_ctrl_jump_flag),
        .pc_jump_addr_in(flush_ctrl_jump_addr),
        .pc_hold_flag_in(if_hold_flag),
        .pc_reg_out(instr_addr)
    );

    wire[31: 0] ifd_instr_addr, ifd_instr;
    wire ifd_instr_valid;
    instr_fetch_delay instr_fetch_delay_inst(
        .clk(clk),
        .rst(rst),
        .ifd_jump_flag_in(jump_flag),
        .ifd_instr_addr_in(instr_addr),
        .ifd_instr_in(instr),
        .ifd_instr_valid_in(instr_valid),
        .ifd_instr_addr_out(ifd_instr_addr),
        .ifd_instr_out(ifd_instr),
        .ifd_instr_valid_out(ifd_instr_valid)
    );

    wire[31: 0] reg1_data, reg2_data;
    wire[31: 0] id_instr_addr, id_instr;
    wire[4: 0] id_write_addr;
    wire[4: 0] id_reg1_addr;
    wire[4: 0] id_reg2_addr;
    wire[31: 0] id_op1;
    wire[31: 0] id_op2;
    wire[31: 0] id_jump_op1;
    wire[31: 0] id_jump_op2;
    wire id_wen;
    instr_decode instr_decode_inst(
        .id_instr_addr_in(ifd_instr_addr),
        .id_instr_in(ifd_instr),
        .id_instr_valid_in(ifd_instr_valid),
        .id_instr_addr_out(id_instr_addr),
        .id_instr_out(id_instr),
        .id_instr_valid_out(),
        .id_reg1_data_in(reg1_data),
        .id_reg2_data_in(reg2_data),
        .id_write_addr_out(id_write_addr),
        .id_reg1_addr_out(id_reg1_addr),
        .id_reg2_addr_out(id_reg2_addr),
        .id_op1_out(id_op1),
        .id_op2_out(id_op2),
        .id_jump_op1_out(id_jump_op1),
        .id_jump_op2_out(id_jump_op2),
        .id_wen_out(id_wen)
    );

    wire[31: 0] idd_instr_addr;
    wire[31: 0] idd_instr;
    wire[4: 0] idd_write_addr;
    wire[4: 0] idd_reg1_addr;
    wire[4: 0] idd_reg2_addr;
    wire[31: 0] idd_op1;
    wire[31: 0] idd_op2;
    wire[31: 0] idd_jump_op1;
    wire[31: 0] idd_jump_op2;
    wire idd_wen;
    instr_decode_delay instr_decode_delay_inst(
        .clk(clk),
        .rst(rst),
        .idd_jump_flag_in(jump_flag),
        .idd_instr_addr_in(id_instr_addr),
        .idd_instr_in(id_instr),
        .idd_write_addr_in(id_write_addr),
        .idd_reg1_addr_in(id_reg1_addr),
        .idd_reg2_addr_in(id_reg2_addr),
        .idd_op1_in(id_op1),
        .idd_op2_in(id_op2),
        .idd_jump_op1_in(id_jump_op1),
        .idd_jump_op2_in(id_jump_op2),
        .idd_wen_in(id_wen),
        .idd_instr_addr_out(idd_instr_addr),
        .idd_instr_out(idd_instr),
        .idd_write_addr_out(idd_write_addr),
        .idd_reg1_addr_out(idd_reg1_addr),
        .idd_reg2_addr_out(idd_reg2_addr),
        .idd_op1_out(idd_op1),
        .idd_op2_out(idd_op2),
        .idd_jump_op1_out(idd_jump_op1),
        .idd_jump_op2_out(idd_jump_op2),
        .idd_wen_out(idd_wen)
    );

    wire[4: 0] exec_write_addr;
    wire[31: 0] exec_write_data;
    wire exec_wen;
    exec exec_inst (
        .exec_instr_addr_in(idd_instr_addr),
        .exec_instr_in(idd_instr), 
        .exec_write_addr_in(idd_write_addr),
        .exec_reg1_addr_in(idd_reg1_addr),
        .exec_reg2_addr_in(idd_reg2_addr),
        .exec_op1_in(idd_op1),
        .exec_op2_in(idd_op2),
        .exec_id_jump_op1_in(idd_jump_op1),
        .exec_id_jump_op2_in(idd_jump_op2),
        .exec_wen_in(idd_wen),
        .exec_write_addr_out(exec_write_addr),
        .exec_write_data_out(exec_write_data),
        .exec_jump_addr_out(jump_addr),
        .exec_jump_flag_out(jump_flag),
        .exec_wen_out(exec_wen)
    );

    regs regs_inst (
        .clk(clk),
        .rst(rst),

        .output_reg1(),
        .output_reg2(),
        .output_reg3(),
        .output_reg4(),
        .output_reg5(),
        .output_reg6(),
        .output_reg7(),
        .output_reg8(),
        .output_reg9(),
        .output_reg10(),

        .regs_wen_in(exec_wen),
        .regs_write_addr_in(exec_write_addr),
        .regs_reg1_addr_in(id_reg1_addr),
        .regs_reg2_addr_in(id_reg2_addr),
        .regs_write_data_in(exec_write_data),
        .regs_reg1_data_out(reg1_data),
        .regs_reg2_data_out(reg2_data)
    );
endmodule