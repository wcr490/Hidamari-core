`include "./core/core_defines.v"
`include "./peripheral/peripheral_defines.v"

module soc_top (
    input clk,
    input rst
);
    wire mem_instr_valid, mem_instr_ready, cpu_instr_addr_valid;
    wire mem_data_valid, mem_data_ready, cpu_data_addr_valid;
    wire data_read_en, data_write_en;
    wire[31: 0] instr, instr_addr;
    wire[31: 0] mem_rdata, cpu_wdata, data_addr;
    wire[3: 0] cpu_byte_num_en;
    cpu cpu_inst (
        .clk                        (clk),
        .rst                        (rst),

        .instr_valid_in             (mem_instr_valid),
        .instr_ready_in             (mem_instr_ready),
        .instr_in                   (instr),
        .instr_addr_out             (instr_addr),
        .instr_addr_valid_out       (cpu_instr_addr_valid),


        .cpu_mem_valid_in               (mem_data_valid),
        .cpu_mem_ready_in               (mem_data_ready),
        .cpu_mem_rdata_in               (mem_rdata),
        .cpu_mem_wdata_out              (cpu_wdata),
        .cpu_mem_write_byte_en_out      (cpu_byte_num_en),
        .cpu_mem_addr_out               (data_addr),
        .cpu_mem_read_en_out            (data_read_en),
        .cpu_mem_write_en_out           (data_write_en),
        .cpu_mem_valid_out              (cpu_data_addr_valid)
    );
    dual_port_mem_controller mem_controller_inst(
        .clk                    (clk),
        .rst                    (rst),

        .instr_addr_in          (instr_addr),
        .instr_valid_in         (cpu_instr_addr_valid),
        .instr_ready_out        (mem_instr_ready),
        .instr_rdata_valid_out  (mem_instr_valid),
        .instr_rdata_out        (instr),

        .data_addr_in           (data_addr),
        .data_wdata_in          (cpu_wdata),
        .data_byte_en_in        (cpu_byte_num_en),
        .data_read_en_in        (data_read_en),
        .data_write_en_in       (data_write_en),
        .data_valid_in          (cpu_data_addr_valid),
        .data_ready_out         (mem_data_ready),
        .data_rdata_valid_out   (mem_data_valid),
        .data_rdata_out         (mem_rdata)
    );
    // mem_controller mem_controller_inst (
    //     .clk                    (clk),
    //     .rst                    (rst),
    //     .mc_addr_in             (instr_addr),
    //     .mc_write_data_in       (),
    //     .mc_write_byte_en_in    (),
    //     .cs                     (1'b0),
    //     .mc_read_en_in          (),
    //     .mc_write_en_in         (1'b0),
    //     .valid_in               (cpu_instr_addr_valid),
    //     .ready_out              (mem_instr_ready),
    //     .rdata_valid_out        (mem_instr_valid),
    //     .mc_read_data_out       (instr)
    // );
endmodule