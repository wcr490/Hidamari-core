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
        $readmemh("./test/addi_test.hex", soc_top_inst.mem_controller_inst.instr_ram.mem);
        #1000
        $finish;
    end

    initial begin
    end

    initial begin
        $dumpfile("./build/soc_out.vcd");
        $dumpvars(0, soc_tb);
    end
endmodule