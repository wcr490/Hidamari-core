`include "./peripheral/peripheral_defines.v"

module dual_port_mem_controller (
    input wire clk,
    input wire rst,

    input wire[31:0] instr_addr_in,
    input wire instr_valid_in,
    output reg instr_ready_out,
    output reg instr_rdata_valid_out,
    output reg[31:0] instr_rdata_out,

    input wire[31:0] data_addr_in,
    input wire[31:0] data_wdata_in,
    input wire[3:0] data_byte_en_in,
    input wire data_read_en_in,
    input wire data_write_en_in,
    input wire data_valid_in,
    output reg data_ready_out,
    output reg data_rdata_valid_out,
    output reg[31:0] data_rdata_out
);

    wire instr_ram_ready;
    wire instr_ram_rdata_valid;
    wire [31:0] instr_ram_rdata;

    wire data_ram_ready;
    wire data_ram_rdata_valid;
    wire [31:0] data_ram_rdata;

    always @(*) begin
        instr_ready_out = instr_ram_ready;
        instr_rdata_valid_out = instr_ram_rdata_valid;
        instr_rdata_out = instr_ram_rdata;
    end

    always @(*) begin
        data_ready_out = data_ram_ready;
        data_rdata_valid_out = data_ram_rdata_valid;
        data_rdata_out = data_ram_rdata;
    end

    ram instr_ram (
        .clk                        (clk),
        .rst                        (rst),
        .ram_addr_in                (instr_addr_in),
        .ram_write_data_in          (32'b0),
        .ram_read_en_in             (1'b1),
        .ram_write_en_in            (1'b0),
        .ram_write_byte_en_in       (4'b0),
        .valid_in                   (instr_valid_in),
        .ready_out                  (instr_ram_ready),
        .rdata_valid_out            (instr_ram_rdata_valid),
        .ram_read_data_out          (instr_ram_rdata),
        .debug_ram0(),
        .debug_ram1(),
        .debug_ram2(),
        .debug_ram3(),
        .debug_ram4(),
        .debug_ram5(),
        .debug_ram6(),
        .debug_ram7()
    );
    
    ram data_ram (
        .clk                        (clk),
        .rst                        (rst),
        .ram_addr_in                (data_addr_in),
        .ram_write_data_in          (data_wdata_in),
        .ram_read_en_in             (data_read_en_in),
        .ram_write_en_in            (data_write_en_in),
        .ram_write_byte_en_in       (data_byte_en_in),
        .valid_in                   (data_valid_in),
        .ready_out                  (data_ram_ready),
        .rdata_valid_out            (data_ram_rdata_valid),
        .ram_read_data_out          (data_ram_rdata),
        .debug_ram0(),
        .debug_ram1(),
        .debug_ram2(),
        .debug_ram3(),
        .debug_ram4(),
        .debug_ram5(),
        .debug_ram6(),
        .debug_ram7()
    );

endmodule