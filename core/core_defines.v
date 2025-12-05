`define INSTR_NOP   32'h00000013

`define OP_TYPE_IMM     7'b0010011  
`define OP_TYPE_LOAD    7'b0000011 
`define OP_TYPE_JAL     7'b1101111 
`define OP_TYPE_JALR    7'b1100111 
`define OP_TYPE_BRANCH  7'b1100011
`define OP_TYPE_STORE   7'b0100011 
`define OP_TYPE_LUI     7'b0110111  
`define OP_TYPE_AUIPC   7'b0010111
`define OP_TYPE_SYSTEM  7'b1110011

`define FUNC3_ADDI  3'b000
`define FUNC3_SLLI  3'b001
`define FUNC3_SLTI  3'b010
`define FUNC3_SLTIU 3'b011
`define FUNC3_ADDI  3'b000
`define FUNC3_XORI  3'b100
`define FUNC3_SRLI  3'b101
`define FUNC3_SRAI  3'b101
`define FUNC3_ORI   3'b110
`define FUNC3_ANDI  3'b111

`define FUNC3_LB    3'b000
`define FUNC3_LH    3'b001
`define FUNC3_LW    3'b010
`define FUNC3_LBU   3'b100
`define FUNC3_LHU   3'b101
`define FUNC3_LWU   3'b110

`define FUNC3_BEQ   3'b000
`define FUNC3_BNE   3'b001
`define FUNC3_BLT   3'b100
`define FUNC3_BGE   3'b101
`define FUNC3_BLTU  3'b110
`define FUNC3_BGEU  3'b111