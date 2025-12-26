/*
iverilog -Wall -g2012 -o ./build/cache_out ./core/cache.v ./test/cache_tb.v 
*/
/*
vvp -n ./build/cache_out -vcd ./build/cache_out.vcd
*/

`timescale 1ps/1ps

module cache_tb (
);
    reg clk, rst;
    reg wen, len;
    wire dirty, hit;
    reg[1: 0] byte_en;
    reg[31: 0] addr, wdata;
    wire[31: 0] rdata;
    reg[16*8 - 1: 0] ldata;
    always #10 clk = ~clk;
    
    // Include the cache modules
    `define CACHE_LINE_NUM 64
    `define CACHE_LINE_SIZE 16
    `define CACHE_LINE_BIT_NUM (`CACHE_LINE_SIZE * 8)
    `define CACHE_WAY_NUM 64

    cache_way cache_way_inst(
        .clk                                     (clk),
        .rst                                     (rst),
        .cw_addr_in                              (addr),
        .cw_wdata_in                             (wdata),
        .cw_ldata_in                             (ldata),
        .cw_byte_en_in                           (byte_en),
        .cs                                      (1'b1),
        .cw_write_en                             (wen),
        .cw_load_en                              (len),
        .cw_rdata_out                            (rdata),
        .cw_wbdata_out                           (),
        .cw_dirty_out                            (dirty),
        .cw_hit_out                              (hit) 
    );

    reg ren, begin_load;
    wire ready_out, cs_dirty, cs_hit;
    wire[31: 0] cs_rdata;
    cache_set cache_set_inst (
        .clk                (clk),
        .rst                (rst),
        .cs_addr_in         (addr),
        .cs_wdata_in        (wdata),
        .cs_ldata_in        (ldata),
        .cs_byte_en_in      (byte_en),
        .cs_read_en         (ren),
        .cs_write_en        (wen),
        .cs_load_en         (len),
        .begin_load         (begin_load),
        .cs_rdata_out       (cs_rdata),
        .cs_wbdata_out      (),
        .cs_dirty_out       (cs_dirty),
        .cs_hit_out         (cs_hit),
        .cs_ready_out       (ready_out) 
    );
    initial begin
        clk <= 1'b0;
        rst <= 1'b0;
        wdata <= 32'b0;
        wen <= 1'b0;
        len <= 1'b0;
        ren <= 1'b0;
        addr <= 32'b0;
        byte_en <= 2'b00;
        #50
        rst <= 1'b1;
        len <= 1'b1;
        begin_load <= 1'b1;
        ren <= 1'b0;
        ldata <= 128'h00000000_00000000_12345678_00000000;
        addr <= 32'hfff11110;
        #50
        byte_en <= 2'b00;
        addr <= 32'hfff11114;
        len <= 1'b0;
        #50
        ren <= 1'b1;
        begin_load <= 1'b0;
        #50
        ren <= 1'b0;
        wen <= 1'b1;
        addr <= 32'hfff11118;
        wdata <= 32'h87654321;
        #50
        ren <= 1'b1;
        wen <= 1'b0;
        addr <= 32'hfff11118;
        #50
        ren <= 1'b0;
        len <= 1'b1;
        begin_load <= 1'b1;
        ldata <= 128'hffffffff_00000000_ffffffff_00000000;
        addr <= 32'haaaa0000;
        #50
        ren <= 1'b1;
        len <= 1'b0;
        begin_load <= 1'b0;
        addr <= 32'haaaa0004;
        #100
        $finish;
    end

    initial begin
        $dumpfile("./build/cache_out.vcd");
        $dumpvars(0, cache_way_inst);
        $dumpvars(0, cache_set_inst);
    end
endmodule
