`timescale 1ps/1ps

module cpu_tb (
);
    reg clk;
    reg rst;

    cpu cpu_inst(.clk(clk), .rst(rst));

    always #10 clk = ~clk;
    
    initial begin
        rst <= 1'b0;
        clk <= 1'b1;

        #30
        rst <= 1'b1;
    end

    initial begin
        $readmemh("./test/bne_test.hex", cpu_inst.rom_inst.mem);
    end

    initial begin
        // integer i;
        // for (i = 0; i < 50; i = i + 1) begin
        //     @(posedge clk)
            // $display("Cycle %d: PC=%h, Instr=%h (opcode=%h), IFD_Instr=%h, ID_Instr=%h (id_opcode=%h), IDD_Instr=%h, x1=%h, x2=%h, x3=%h, x4=%h, x5=%h, x6=%h, x7=%h, x8=%h, id_wen=%b, exec_wen=%b, jump_flag=%b, jump_addr=%h",
            //          i,
            //          cpu_inst.pc_reg_inst.pc_reg_out,
            //          cpu_inst.rom_inst.rom_instr_out,
            //          cpu_inst.rom_inst.rom_instr_out[6:0],
            //          cpu_inst.instr_fetch_delay_inst.ifd_instr_out,
            //          cpu_inst.instr_decode_inst.id_instr_out,
            //          cpu_inst.instr_decode_inst.opcode,
            //          cpu_inst.instr_decode_delay_inst.idd_instr_out,
            //          cpu_inst.regs_inst.registers[1],
            //          cpu_inst.regs_inst.registers[2],
            //          cpu_inst.regs_inst.registers[3],
            //          cpu_inst.regs_inst.registers[4],
            //          cpu_inst.regs_inst.registers[5],
            //          cpu_inst.regs_inst.registers[6],
            //          cpu_inst.regs_inst.registers[7],
            //          cpu_inst.regs_inst.registers[8],
            //          cpu_inst.instr_decode_inst.id_wen_out,
            //          cpu_inst.exec_inst.exec_wen_out,
            //          cpu_inst.exec_inst.exec_jump_flag_out,
            //          cpu_inst.exec_inst.exec_jump_addr_out);
        // end
        #1000
        $finish;
    end
    
    
    initial begin
        $dumpfile("./build/out.vcd");
        $dumpvars(0, cpu_tb);
    end
endmodule