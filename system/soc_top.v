`include "./bus/bus_defines.v"
`include "./core/core_defines.v"
`include "./peripheral/peripheral_defines.v"

module soc_top (
    input clk,
    input rst
);

    // CPU到总线的信号
    wire[31: 0] cpu_sb_addr;
    wire cpu_sb_req;
    wire cpu_sb_wr;
    wire[31: 0] cpu_sb_wdata;
    wire cpu_sb_gnt;
    wire[31: 0] cpu_sb_read_data;
    wire cpu_sb_read_valid;
    wire cpu_sb_err;
    
    // 总线到ROM的信号
    wire[31: 0] sb_rom_addr;
    wire sb_rom_req;
    wire[31: 0] sb_rom_read_data;
    wire sb_rom_read_valid;
    
    // 总线到RAM的信号
    wire[31: 0] sb_ram_addr;
    wire sb_ram_req;
    wire sb_ram_wr;
    wire[31: 0] sb_ram_wdata;
    wire[31: 0] sb_ram_read_data;
    wire sb_ram_read_valid;

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
        .cpu_sb_err_in(cpu_sb_err)
    );

    // 系统总线实例
    system_bus system_bus_inst (
        .clk(clk),
        .rst(rst),
        // 主设备接口（CPU侧）
        .sb_m_addr_in(cpu_sb_addr),
        .sb_m_req_in(cpu_sb_req),
        .sb_m_wr_in(cpu_sb_wr),
        .sb_m_wdata_in(cpu_sb_wdata),
        .sb_m_gnt_out(cpu_sb_gnt),
        .sb_m_read_data_out(cpu_sb_read_data),
        .sb_m_read_valid_out(cpu_sb_read_valid),
        .sb_m_err_out(cpu_sb_err),
        // ROM接口
        .sb_rom_addr_out(sb_rom_addr),
        .sb_rom_req_out(sb_rom_req),
        .sb_rom_read_data_in(sb_rom_read_data),
        .sb_rom_read_valid_in(sb_rom_read_valid),
        // RAM接口
        .sb_ram_addr_out(sb_ram_addr),
        .sb_ram_req_out(sb_ram_req),
        .sb_ram_wr_out(sb_ram_wr),
        .sb_ram_wdata_out(sb_ram_wdata),
        .sb_ram_read_data_in(sb_ram_read_data),
        .sb_ram_read_valid_in(sb_ram_read_valid)
    );

    // ROM实例
    rom rom_inst (
        .clk(clk),
        .rom_req(sb_rom_req),
        .rom_addr_in(sb_rom_addr),
        .rom_read_data_out(sb_rom_read_data),
        .rom_read_valid_out(sb_rom_read_valid)
    );

    // RAM实例（暂时空置）
    // ram ram_inst (
    //     .clk(clk),
    //     .ram_req(sb_ram_req),
    //     .ram_addr_in(sb_ram_addr),
    //     .ram_wr_in(sb_ram_wr),
    //     .ram_wdata_in(sb_ram_wdata),
    //     .ram_read_data_out(sb_ram_read_data),
    //     .ram_read_valid_out(sb_ram_read_valid)
    // );

endmodule