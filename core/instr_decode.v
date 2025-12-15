`include "./core/core_defines.v"

module instr_decode (
    input wire[31: 0] id_instr_addr_in,
    input wire[31: 0] id_instr_in,
    input wire id_instr_valid_in,
    output reg[31: 0] id_instr_addr_out,
    output reg[31: 0] id_instr_out,
    output reg id_instr_valid_out,

    input wire[31: 0] id_reg1_data_in, 
    input wire[31: 0] id_reg2_data_in, 
    output reg[4: 0] id_write_addr_out,
    output reg[4: 0] id_reg1_addr_out,
    output reg[4: 0] id_reg2_addr_out,
    output reg[31: 0] id_op1_out,
    output reg[31: 0] id_op2_out,
    output reg[31: 0] id_jump_op1_out,
    output reg[31: 0] id_jump_op2_out,
    output reg id_wen_out
);
    wire[6: 0] opcode = id_instr_in[6: 0];
    wire[4: 0] rd = id_instr_in[11: 7];
    wire[4: 0] reg1_addr = id_instr_in[19: 15];
    wire[4: 0] reg2_addr = id_instr_in[24: 20];
    wire[2: 0] func3 = id_instr_in[14: 12];
    wire[6: 0] func7 = id_instr_in[31: 25];
    wire[31: 0] type_imm_imm = 
        {{21{id_instr_in[31]}}, id_instr_in[30:20]};
    wire[31: 0] type_branch_imm = 
        {{20{id_instr_in[31]}}, id_instr_in[7], id_instr_in[30:25], id_instr_in[11:8], 1'b0};
    wire[31: 0] type_jal_imm = 
        {{12{id_instr_in[31]}}, id_instr_in[19:12], id_instr_in[20], id_instr_in[30:21], 1'b0};
    wire[31: 0] type_lui_imm_shifted = 
        {{id_instr_in[31:12]}, 12'b0};

    always @(*) begin
        id_instr_addr_out = id_instr_addr_in;
        id_instr_out = id_instr_in;
        id_instr_valid_out = id_instr_valid_in;
        id_write_addr_out = 5'b0;
        id_reg1_addr_out = 5'b0;
        id_reg2_addr_out = 5'b0;
        id_op1_out = 32'b0;
        id_op2_out = 32'b0;
        id_jump_op1_out = 32'b0;
        id_jump_op2_out = 32'b0;
        id_wen_out = 1'b0;

        // if (!id_instr_valid_in) begin
        // end
        // else begin
            case (opcode)
                `OP_TYPE_IMM: begin
                    case (func3)
                        `FUNC3_ADDI,
                        `FUNC3_SLLI,
                        `FUNC3_SLTI,
                        `FUNC3_SLTIU,
                        `FUNC3_XORI,
                        `FUNC3_SRLI,
                        `FUNC3_SRAI,
                        `FUNC3_ORI ,
                        `FUNC3_ANDI: begin
                            id_reg1_addr_out = reg1_addr;
                            id_op1_out = id_reg1_data_in;
                            id_op2_out = type_imm_imm;
                            id_write_addr_out = rd;
                            id_wen_out = 1'b1;
                        end
                    default: begin
                    end
                    endcase
                end
                `OP_TYPE_BRANCH: begin
                    case (func3)
                        `FUNC3_BEQ,
                        `FUNC3_BNE,
                        `FUNC3_BLT,
                        `FUNC3_BGE,
                        `FUNC3_BLTU,
                        `FUNC3_BGEU: begin
                            id_reg1_addr_out = reg1_addr;
                            id_reg2_addr_out = reg2_addr;
                            id_op1_out = id_reg1_data_in;
                            id_op2_out = id_reg2_data_in;
                            id_jump_op1_out = id_instr_addr_in;
                            id_jump_op2_out = type_branch_imm;
                        end
                        default: begin
                        end
                    endcase
                end
                `OP_TYPE_LUI: begin
                    id_op1_out = type_lui_imm_shifted;
                    id_write_addr_out = rd;
                    id_wen_out = 1'b1;
                end
                `OP_TYPE_JAL: begin
                    id_write_addr_out = rd;
                    id_wen_out = 1'b1;
                    id_jump_op1_out = id_instr_addr_in;
                    id_jump_op2_out = type_jal_imm;
                end
                `OP_TYPE_LOAD: begin
                    id_op1_out = id_reg1_data_in;
                    id_op2_out = type_imm_imm;
                    id_write_addr_out = rd;
                    id_wen_out = 1'b1;
                    // case (func3)
                    //     `FUNC3_LB: begin
                    //     end
                    //     `FUNC3_LH: begin
                    //     end
                    //     `FUNC3_LW: begin
                    //     end
                    //     `FUNC3_LBU: begin
                    //     end
                    //     `FUNC3_LHU: begin
                    //     end
                    //     default: 
                    // endcase
                end
                `OP_TYPE_STORE: begin
                end
                default: begin
                end
            endcase
        end
    // end
endmodule