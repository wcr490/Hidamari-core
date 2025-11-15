`timescale 1ps/1ps

module ram_tb (
);
    reg clk;
    reg rst;
    reg ram_read_en, ram_write_en, in_valid, out_valid, data_ready;
    reg[3: 0] ram_write_byte_en;
    reg[31: 0] ram_addr, ram_write_data, ram_data_out, debug_ram; 

    ram ram_inst (
        .clk                    (clk),
        .rst                    (rst),
        .ram_addr_in            (ram_addr),
        .ram_write_data_in      (ram_write_data),
        .ram_read_en_in         (ram_read_en),
        .ram_write_en_in        (ram_write_en),
        .ram_write_byte_en_in   (ram_write_byte_en),
        .valid_in               (in_valid),
        .ready_out              (data_ready),
        .rdata_valid_out        (out_valid),
        .ram_read_data_out      (ram_data_out),
        .debug_ram              (debug_ram)
    ); 
    always #10 clk = ~clk;
    
    initial begin
        rst <= 1'b0;
        clk <= 1'b1;

        #30
        rst <= 1'b1;
        ram_addr <= 32'h00000008;
        ram_write_en <= 1'b1;
        ram_write_data <= 32'hffff0000;
        ram_write_byte_en <= 4'b1111;
        in_valid <= 1'b1;

        #10
        wait(data_ready)
        ram_write_en <= 1'b0;
        ram_read_en <= 1'b1;

        #30
        $finish;
    end

    initial begin
        $dumpfile("./build/ram_out.vcd");
        $dumpvars(0, ram_tb);
        $dumpvars(1, ram_inst);
    end
endmodule

