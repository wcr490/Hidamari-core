module flush_ctrl (
    input wire fc_jump_flag_in,
    input wire[31: 0] fc_jump_addr_in,

    output reg fc_jump_flag_out,
    output reg[31: 0] fc_jump_addr_out,
    output reg hold_flag_out
);
    always @(*) begin
        fc_jump_flag_out = fc_jump_flag_in;
        fc_jump_addr_out = fc_jump_addr_in;
        hold_flag_out = 0;

        if (fc_jump_flag_in) begin
            hold_flag_out = 1;
        end
        else begin
            hold_flag_out = 0;
        end
    end
endmodule