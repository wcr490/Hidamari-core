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
    input wire exec_wen_in,

    output reg[4: 0] exec_write_addr_out,
    output reg[31: 0] exec_write_data_out,
    output reg[31: 0] exec_jump_addr_out,
    output reg exec_jump_flag_out,
    output reg exec_wen_out
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
                exec_write_addr_out = exec_write_addr_in;
                exec_wen_out = 1'b1;
            end
            default: begin

            end
        endcase
    end
    
endmodule