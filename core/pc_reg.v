module pc_reg (
    input   wire                        clk,
    input   wire                        rst,

    input   wire            pc_jump_flag_in,
    input   wire[31: 0]     pc_jump_addr_in,
    input   wire            pc_hold_flag_in,
    output  reg[31: 0]           pc_reg_out
);
    always @(posedge clk) begin
        if (rst == 1'b0)
            pc_reg_out <= 0;
        else if (pc_jump_flag_in == 1'b1)
            pc_reg_out <= pc_jump_addr_in;
        else if (pc_hold_flag_in == 1'b0)
            pc_reg_out <= pc_reg_out + 4;
    end
endmodule