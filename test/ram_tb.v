/*
iverilog -Wall -g2012 -o ./build/ram_out ./peripheral/dual_port_mem_controller.v ./peripheral/ram.v ./test/dual_port_mem_tb.v 
*/
/*
vvp -n ./build/ram_out -vcd ./build/ram_out.vcd
*/
`timescale 1ps/1ps

module ram_tb (
);
    reg clk;
    reg rst;
    reg ram_read_en, ram_write_en, in_valid;
    reg[3: 0] ram_write_byte_en;
    reg[31: 0] ram_addr, ram_write_data, debug_ram;
    
    reg ram_data_ready, ram_out_valid;
    reg[31: 0] ram_data_out;
    
    reg mem_data_ready, mem_out_valid;
    reg[31: 0] mem_data_out;

    ram ram_inst (
        .clk                    (clk),
        .rst                    (rst),
        .ram_addr_in            (ram_addr),
        .ram_write_data_in      (ram_write_data),
        .ram_read_en_in         (ram_read_en),
        .ram_write_en_in        (ram_write_en),
        .ram_write_byte_en_in   (ram_write_byte_en),
        .valid_in               (in_valid),
        .ready_out              (ram_data_ready),
        .rdata_valid_out        (ram_out_valid),
        .ram_read_data_out      (ram_data_out),
        .debug_ram(debug_ram)
    );

    reg ram_cs;
    mem_controller mem_controller_inst (
        .clk                    (clk),
        .rst                    (rst),
        .mc_addr_in             (ram_addr),
        .mc_write_data_in       (ram_write_data),
        .mc_write_byte_en_in    (ram_write_byte_en),
        .cs                     (ram_cs),
        .mc_read_en_in          (ram_read_en),
        .mc_write_en_in         (ram_write_en),
        .valid_in               (in_valid),
        .ready_out              (mem_data_ready),
        .rdata_valid_out        (mem_out_valid),
        .mc_read_data_out       (mem_data_out)
    );

    always #10 clk = ~clk;
    
    initial begin
        rst <= 1'b0;
        clk <= 1'b1;

        #30
        ram_cs <= 1'b1;
        rst <= 1'b1;
        ram_addr <= 32'h00000008;
        ram_write_en <= 1'b1;
        ram_write_data <= 32'hffff0000;
        ram_write_byte_en <= 4'b1111;
        in_valid <= 1'b1;

        #20
        wait(ram_data_ready)
        ram_write_en <= 1'b0;
        ram_read_en <= 1'b1;
        #40
        ram_read_en <= 1'b0;
        in_valid <= 1'b0;
        #80
        $finish;
    end

    initial begin
        $dumpfile("./build/ram_out.vcd");
        $dumpvars(0, ram_tb);
        $dumpvars(1, ram_inst);
    end
endmodule