`include "./core/core_defines.v"
`include "./peripheral/peripheral_defines.v"

module soc_top (
    input clk,
    input rst
);
    wire mem_instr_valid, mem_instr_ready, cpu_instr_addr_valid;
    wire[31: 0] instr, instr_addr;
    cpu cpu_inst (
        .clk                        (clk),
        .rst                        (rst),
        .instr_valid_in             (mem_instr_valid),
        .instr_ready_in             (mem_instr_ready),
        .instr_in                   (instr),
        .instr_addr_out             (instr_addr),
        .instr_addr_valid_out       (cpu_instr_addr_valid),
        .cpu_mem_valid_in           (),
        .cpu_mem_rdata_in           (),
        .cpu_mem_wdata_out          (),
        .cpu_mem_write_byte_en_out  (),
        .cpu_mem_addr_out           ()
    );
    mem_controller mem_controller_inst (
        .clk                    (clk),
        .rst                    (rst),
        .mc_addr_in             (instr_addr),
        .mc_write_data_in       (),
        .mc_write_byte_en_in    (),
        .cs                     (1'b0),
        .mc_read_en_in          (),
        .mc_write_en_in         (1'b0),
        .valid_in               (cpu_instr_addr_valid),
        .ready_out              (mem_instr_ready),
        .rdata_valid_out        (mem_instr_valid),
        .mc_read_data_out       (instr)
    );
endmodule