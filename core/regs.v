module regs(
    input wire clk,
    input wire rst,

    output wire[31: 0] output_reg1,
    output wire[31: 0] output_reg2,
    output wire[31: 0] output_reg3,
    output wire[31: 0] output_reg4,
    output wire[31: 0] output_reg5,
    output wire[31: 0] output_reg6,
    output wire[31: 0] output_reg7,
    output wire[31: 0] output_reg8,
    output wire[31: 0] output_reg9,
    output wire[31: 0] output_reg10,

    input wire regs_wen_in,
    input wire[4: 0] regs_write_addr_in,
    input wire[4: 0] regs_reg1_addr_in,
    input wire[4: 0] regs_reg2_addr_in,
    input wire[31: 0] regs_write_data_in,
    output reg[31: 0] regs_reg1_data_out,
    output reg[31: 0] regs_reg2_data_out
);
    reg[31: 0] registers[0: 31];

    assign output_reg1 = registers[1];
    assign output_reg2 = registers[2];
    assign output_reg3 = registers[3];
    assign output_reg4 = registers[4];
    assign output_reg5 = registers[5];
    assign output_reg6 = registers[6];
    assign output_reg7 = registers[7];
    assign output_reg8 = registers[8];
    assign output_reg9 = registers[9];
    assign output_reg10 = registers[10];

    always @(posedge clk) begin
        if (rst == 1'b0) begin
            integer i;
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end
        else begin
            if ((regs_write_addr_in != 5'b0) && (regs_wen_in))
                registers[regs_write_addr_in] <= regs_write_data_in;
        end
    end

    always @(*) begin
        if (regs_reg1_addr_in == 5'b0) 
            regs_reg1_data_out = 32'b0;
        else if ((regs_reg1_addr_in == regs_write_addr_in) && (regs_wen_in))
            regs_reg1_data_out = regs_write_data_in;
        else
            regs_reg1_data_out = registers[regs_reg1_addr_in];
    end
    always @(*) begin
        if (regs_reg2_addr_in == 5'b0) 
            regs_reg2_data_out = 32'b0;
        else if ((regs_reg2_addr_in == regs_write_addr_in) && (regs_wen_in))
            regs_reg2_data_out = regs_write_data_in;
        else
            regs_reg2_data_out = registers[regs_reg2_addr_in];
    end
endmodule