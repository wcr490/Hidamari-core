module cpu (
    input clk,
    input rst,
    
    output wire[31: 0] cpu_sb_addr_out,
    output wire cpu_sb_req_out,
    output wire cpu_sb_wr_out,
    output wire[31: 0] cpu_sb_wdata_out,
    input wire cpu_sb_gnt_in,
    input wire[31: 0] cpu_sb_read_data_in,
    input wire cpu_sb_read_valid_in,
    input wire cpu_sb_err_in
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



    //--------BUS-CPU-IF-----------//
    typedef enum logic[1: 0] {
        IF_IDLE,
        IF_REQ,
        IF_WAIT
    } if_state_t;
    reg[1: 0] cur_if_state, next_if_state;
    reg[31: 0] if_addr_reg;
    reg[31: 0] if_instr_reg;
    reg if_valid_reg;
    wire if_hold_flag;
    
    assign if_hold_flag = 
        (cur_if_state != IF_IDLE) || 
        (cur_if_state == IF_IDLE && !if_valid_reg) || 
        (flush_ctrl_jump_flag);
    
        always @(posedge clk) begin
            if (rst == 1'b0) begin
                cur_if_state <= IF_IDLE;
                if_addr_reg <= 32'h0;
                if_instr_reg <= 32'h0;
                if_valid_reg <= 1'b0;
            end
            else begin
                cur_if_state <= next_if_state;

                case (cur_if_state)
                    IF_IDLE: begin
                        if_valid_reg <= 1'b0;
                    end

                    IF_REQ: begin
                        if_valid_reg <= 1'b0;
                        if_addr_reg <= instr_addr;
                    end

                    IF_WAIT: begin
                        if (cpu_sb_read_valid_in) begin
                            if_instr_reg <= cpu_sb_read_data_in;
                            if_valid_reg <= 1'b1;
                        end
                    end
                endcase
            end
        end
    
        always @(*) begin
            next_if_state = cur_if_state;
            case (cur_if_state)
                IF_IDLE: begin
                    if (!flush_ctrl_jump_flag)
                        next_if_state = IF_REQ;
                end

                IF_REQ: begin
                    if (cpu_sb_gnt_in)
                        next_if_state = IF_WAIT;
                end

                IF_WAIT: begin
                    if (cpu_sb_read_valid_in)
                        next_if_state = IF_IDLE;
                end
            endcase
        end
    assign cpu_sb_addr_out = (cur_if_state == IF_REQ) ? if_addr_reg : 32'h0;
    assign cpu_sb_req_out = (cur_if_state == IF_REQ);
    assign cpu_sb_wr_out = 1'b0;
    assign cpu_sb_wdata_out = 32'h0;
    
    wire[31: 0] instr = if_instr_reg;
    wire instr_valid = if_valid_reg;
    //--------BUS-CPU-IF-----------//

    wire[31: 0] instr_addr;
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