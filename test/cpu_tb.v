`timescale 1ps/1ps

module cpu_tb (
);
    reg clk;
    reg rst;
    reg mem_valid, mem_ready, addr_valid;
    reg[31: 0] instr, instr_addr;

    cpu cpu_inst(
        .clk                            (clk),
        .rst                            (rst),
        .instr_valid_in                 (mem_valid),
        .instr_ready_in                 (mem_ready),
        .instr_in                       (instr),
        .instr_addr_out                 (instr_addr),
        .instr_addr_valid_out           (addr_valid)
        // ,
        // .cpu_mem_valid_in               (),
        // .cpu_mem_rdata_in               (),
        // .cpu_mem_wdata_out              (),
        // .cpu_mem_write_byte_en_out      (),
        // .cpu_mem_addr_out               ()
    );
    always #10 clk = ~clk;
    
    initial begin
        rst <= 1'b0;
        clk <= 1'b1;
        mem_valid <= 1'b0;
        mem_ready <= 1'b0;
        instr <= 32'b0;
        #30
        rst <= 1'b1;
        mem_valid <= 1'b1;
        mem_ready <= 1'b1;
        instr <= 32'h00500093;
        #70
        // mem_valid <= 1'b0;
        // mem_ready <= 1'b0;
        instr <= 32'hFFD00113;
        #150
        $finish;
    end

    // initial begin
    //     $readmemh("./test/bne_test.hex", cpu_inst.rom_inst.mem);
    // end

    initial begin
        $dumpfile("./build/out.vcd");
        $dumpvars(0, cpu_tb);
    end
endmodule