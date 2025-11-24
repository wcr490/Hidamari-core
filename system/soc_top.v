`include "./bus/bus_defines.v"
`include "./core/core_defines.v"
`include "./peripheral/peripheral_defines.v"

module soc_top (
    input clk,
    input rst
);

    wire[31: 0] cpu_sb_addr;
    wire cpu_sb_req;
    wire cpu_sb_wr;
    wire[31: 0] cpu_sb_wdata;
    wire cpu_sb_gnt;
    wire[31: 0] cpu_sb_read_data;
    wire cpu_sb_read_valid;
    wire cpu_sb_err;
    
    wire[31: 0] sb_rom_addr;
    wire sb_rom_req;
    wire[31: 0] sb_rom_read_data;
    wire sb_rom_read_valid;

    // CPU实例
    cpu cpu_inst (
        .clk(clk),
        .rst(rst),
        // 总线接口
        .cpu_sb_addr_out(cpu_sb_addr),
        .cpu_sb_req_out(cpu_sb_req),
        .cpu_sb_wr_out(cpu_sb_wr),
        .cpu_sb_wdata_out(cpu_sb_wdata),
        .cpu_sb_gnt_in(cpu_sb_gnt),
        .cpu_sb_read_data_in(cpu_sb_read_data),
        .cpu_sb_read_valid_in(cpu_sb_read_valid),
    );

    // ROM实例
    rom rom_inst (
        .clk(clk),
        .rom_req(sb_rom_req),
        .rom_addr_in(sb_rom_addr),
        .rom_read_data_out(sb_rom_read_data),
        .rom_read_valid_out(sb_rom_read_valid)
    );
endmodule