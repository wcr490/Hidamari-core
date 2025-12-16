module flush_ctrl (
    input wire clk,
    input wire rst,
    input wire fc_jump_flag_in,
    input wire[31: 0] fc_jump_addr_in,

    output reg fc_jump_flag_out,
    output reg[31: 0] fc_jump_addr_out,
    output reg hold_flag_out
);
    reg [1:0] jump_counter;
    reg jump_flag_d1;
    
    always @(posedge clk) begin
        if (!rst) begin
            jump_counter <= 2'b00;
            jump_flag_d1 <= 1'b0;
            fc_jump_flag_out <= 1'b0;
            fc_jump_addr_out <= 32'b0;
            hold_flag_out <= 1'b0;
        end
        else begin
            // 检测到新的jump_flag上升沿
            if (fc_jump_flag_in && !jump_flag_d1) begin
                jump_counter <= 2'b10;  // 设置计数器为2，表示需要维持2个时钟周期
                fc_jump_flag_out <= 1'b1;
                fc_jump_addr_out <= fc_jump_addr_in;
                hold_flag_out <= 1'b1;
            end
            // 如果计数器大于0，继续维持jump_flag
            else if (jump_counter > 0) begin
                jump_counter <= jump_counter - 1;
                fc_jump_flag_out <= 1'b1;
                hold_flag_out <= 1'b1;
                // 只在第一个时钟周期更新jump_addr
                if (jump_counter == 2'b10) begin
                    fc_jump_addr_out <= fc_jump_addr_in;
                end
            end
            // 计数器归零，清除jump_flag
            else begin
                fc_jump_flag_out <= 1'b0;
                fc_jump_addr_out <= 32'b0;
                hold_flag_out <= 1'b0;
            end
            
            // 更新延迟的jump_flag信号，用于检测上升沿
            jump_flag_d1 <= fc_jump_flag_in;
        end
    end
endmodule