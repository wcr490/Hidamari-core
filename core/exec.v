`include "./core/core_defines.v"

module exec (
    input wire[31: 0] exec_instr_addr_in,
    input wire[31: 0] exec_instr_in, 
    input wire[4: 0] exec_write_addr_in,
    input wire[4: 0] exec_reg1_addr_in,
    input wire[4: 0] exec_reg2_addr_in,
    input wire[31: 0] exec_op1_in,
    input wire[31: 0] exec_op2_in,
    input wire[31: 0] exec_id_jump_op1_in,
    input wire[31: 0] exec_id_jump_op2_in,
    input wire[31: 0] exec_mem_write_addr_offset_in,
    input wire exec_wen_in,

    output reg[4: 0] exec_write_addr_out,
    output reg[31: 0] exec_write_data_out,
    output reg[31: 0] exec_jump_addr_out,
    output reg exec_jump_flag_out,
    output reg exec_wen_out,

    input reg exec_mem_valid_in,
    input wire[31: 0] exec_mem_data_in,
    output reg exec_read_mem_en_out,
    output reg exec_write_mem_en_out,
    output reg[31: 0] exec_mem_addr_out,
    output reg[31: 0] exec_mem_data_out,
    output reg[3: 0] exec_mem_data_byte_num_out
);
    wire[6: 0] opcode = exec_instr_in[6: 0];
    wire[4: 0] rd = exec_instr_in[11: 7];
    wire[4: 0] reg1_addr = exec_instr_in[19: 15];
    wire[4: 0] reg2_addr = exec_instr_in[24: 20];
    wire[2: 0] func3 = exec_instr_in[14: 12];
    wire[6: 0] func7 = exec_instr_in[31: 25];

    wire op1_eq_op2 = (exec_op1_in == exec_op2_in);
    wire op1_neq_op2 = ~op1_eq_op2;

    wire[31: 0] jump_op1_add_op2 = exec_id_jump_op1_in + exec_id_jump_op2_in;

    always @(*) begin
        exec_write_addr_out = 5'b0;
        exec_write_data_out = 32'b0;
        exec_wen_out = 1'b0;
        exec_jump_addr_out = 32'b0;
        exec_jump_flag_out = 1'b0;
        exec_read_mem_en_out = 1'b0;
        exec_write_mem_en_out = 1'b0;
        exec_mem_addr_out = 32'b0;
        exec_mem_data_out = 32'b0;
        exec_mem_data_byte_num_out = 4'b0;
        case (opcode)
            `OP_TYPE_IMM: begin
                case (func3)
                    `FUNC3_ADDI: begin
                        exec_write_addr_out = exec_write_addr_in;
                        exec_write_data_out = exec_op1_in + exec_op2_in;
                        exec_wen_out = 1'b1;
                    end
                    default: begin
                    end
                endcase
            end
            `OP_TYPE_BRANCH: begin
                case (func3)
                    `FUNC3_BEQ: begin
                        if (op1_eq_op2) begin
                            exec_jump_addr_out = jump_op1_add_op2;
                            exec_jump_flag_out = 1'b1;
                        end else begin
                            exec_jump_addr_out = 32'b0;
                            exec_jump_flag_out = 1'b0;
                        end
                    end
                    `FUNC3_BNE: begin
                        if (op1_neq_op2) begin
                            exec_jump_addr_out = jump_op1_add_op2;
                            exec_jump_flag_out = 1'b1;
                        end else begin
                            exec_jump_addr_out = 32'b0;
                            exec_jump_flag_out = 1'b0;
                        end
                    end
                    default: begin
                    end
                endcase
            end
            `OP_TYPE_LUI: begin
                exec_write_addr_out = exec_write_addr_in;
                exec_write_data_out = exec_op1_in;
                exec_wen_out = 1'b1;
            end
            `OP_TYPE_JAL: begin
                exec_write_addr_out = exec_write_addr_in;
                exec_write_data_out = exec_instr_addr_in + 4;
                exec_wen_out = 1'b1;
                exec_jump_addr_out = jump_op1_add_op2;
                exec_jump_flag_out = 1'b1;
            end
            `OP_TYPE_LOAD: begin
                exec_mem_addr_out = exec_op1_in + exec_op2_in;
                if (exec_mem_valid_in) begin
                    exec_write_addr_out = exec_write_addr_in;
                    exec_write_data_out = exec_mem_data_in;
                    exec_read_mem_en_out = 1'b0;
                    exec_wen_out = 1'b1;
                end
                else begin
                    // exec_write_addr_out = 5'b0;
                    // exec_mem_addr_out = exec_op1_in + exec_op2_in;
                    case (func3)
                        `FUNC3_LB: begin
                            exec_write_data_out = 
                                {{24{exec_mem_data_in[7]}}, exec_mem_data_in[7: 0]};
                        end
                        `FUNC3_LH: begin
                            exec_write_data_out = 
                                {{16{exec_mem_data_in[15]}}, exec_mem_data_in[15: 0]};
                        end
                        `FUNC3_LW: begin
                            exec_write_data_out = exec_mem_data_in;
                        end
                        `FUNC3_LBU: begin
                            exec_write_data_out = 
                                {24'b0, exec_mem_data_in[7: 0]};
                        end
                        `FUNC3_LHU: begin
                            exec_write_data_out = 
                                {16'b0, exec_mem_data_in[15: 0]};
                        end
                        default: begin
                            exec_write_data_out = 32'b0;
                        end
                    endcase
                    exec_read_mem_en_out = 1'b1;
                end
            end
            `OP_TYPE_STORE: begin
                exec_mem_addr_out = exec_op1_in + exec_mem_write_addr_offset_in;
                exec_mem_data_out = exec_op2_in;
                exec_write_mem_en_out = 1'b1;
                case (func3)
                    `FUNC3_SB: begin
                        exec_mem_data_byte_num_out = 4'b0001;
                    end
                    `FUNC3_SH: begin
                        exec_mem_data_byte_num_out = 4'b0011;
                    end
                    `FUNC3_SW: begin
                        exec_mem_data_byte_num_out = 4'b1111;
                    end
                    default: begin
                    end
                endcase
            end
            default: begin

            end
        endcase
    end
    
endmodule
