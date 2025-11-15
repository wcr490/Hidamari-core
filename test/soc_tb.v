`timescale 1ps/1ps

module soc_tb (
);
    reg clk;
    reg rst;

    soc_top soc_top_inst(.clk(clk), .rst(rst));

    always #10 clk = ~clk;
    
    initial begin
        rst <= 1'b0;
        clk <= 1'b1;

        #30
        rst <= 1'b1;
    end

    initial begin
        $readmemh("./test/addi_test.hex", soc_top_inst.rom_inst.mem);
    end

    initial begin
        integer i;
        for (i = 0; i < 50; i = i + 1) begin
            @(posedge clk)
            $display("Cycle %d: PC=%h, IF_State=%b, IF_Addr=%h, Instr=%h (opcode=%h), IF_Valid=%b, IFD_Instr=%h, ID_Instr=%h (id_opcode=%h), IDD_Instr=%h, x1=%h, x2=%h, x3=%h, x4=%h, x5=%h, x6=%h, x7=%h, x8=%h, id_wen=%b, exec_wen=%b, jump_flag=%b, jump_addr=%h",
                     i,
                     soc_top_inst.cpu_inst.pc_reg_inst.pc_reg_out,
                     soc_top_inst.cpu_inst.cur_if_state,
                     soc_top_inst.cpu_inst.if_addr_reg,
                     soc_top_inst.cpu_inst.if_instr_reg,
                     soc_top_inst.cpu_inst.if_instr_reg[6:0],
                     soc_top_inst.cpu_inst.if_valid_reg,
                     soc_top_inst.cpu_inst.instr_fetch_delay_inst.ifd_instr_out,
                     soc_top_inst.cpu_inst.instr_decode_inst.id_instr_out,
                     soc_top_inst.cpu_inst.instr_decode_inst.id_instr_out[6:0],
                     soc_top_inst.cpu_inst.instr_decode_delay_inst.idd_instr_out,
                     soc_top_inst.cpu_inst.regs_inst.registers[1],
                     soc_top_inst.cpu_inst.regs_inst.registers[2],
                     soc_top_inst.cpu_inst.regs_inst.registers[3],
                     soc_top_inst.cpu_inst.regs_inst.registers[4],
                     soc_top_inst.cpu_inst.regs_inst.registers[5],
                     soc_top_inst.cpu_inst.regs_inst.registers[6],
                     soc_top_inst.cpu_inst.regs_inst.registers[7],
                     soc_top_inst.cpu_inst.regs_inst.registers[8],
                     soc_top_inst.cpu_inst.instr_decode_inst.id_wen_out,
                     soc_top_inst.cpu_inst.exec_inst.exec_wen_out,
                     soc_top_inst.cpu_inst.exec_inst.exec_jump_flag_out,
                     soc_top_inst.cpu_inst.exec_inst.exec_jump_addr_out);
        end
        #1000
        $finish;
    end
    
    
    initial begin
        $dumpfile("./build/soc_out.vcd");
        $dumpvars(0, soc_tb);
    end
endmodule