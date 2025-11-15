`include "./peripheral/peripheral_defines.v"

module rom (
    input clk,
    input rom_req,
    input wire[31: 0] rom_addr_in,
    output reg[31: 0] rom_read_data_out,
    output reg rom_read_valid_out
);
    reg[31: 0] mem[`ROM_SIZE - 1: 0];
    
    always @(posedge clk) begin
        if (rom_req) begin
            rom_read_data_out <= mem[rom_addr_in >> 2];
            rom_read_valid_out <= 1'b1;
        end
        else begin
            rom_read_valid_out <= 1'b0;
        end
    end
endmodule