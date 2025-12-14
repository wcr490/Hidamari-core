`include "./peripheral/peripheral_defines.v"

/* HANDSHAKE

MASTER <------ready------- SLAVE
       -------valid------> 
       <------valid-------
*/

module ram (
    input wire clk,
    input wire rst,

    input wire[31: 0] ram_addr_in,
    input wire[31: 0] ram_write_data_in,
    input wire ram_read_en_in,
    input wire ram_write_en_in,
    input wire[3: 0] ram_write_byte_en_in,

    input wire valid_in,
    output reg ready_out,

    output reg rdata_valid_out,
    output reg[31: 0] ram_read_data_out,

    output reg[31: 0] debug_ram0,
    output reg[31: 0] debug_ram1,
    output reg[31: 0] debug_ram2,
    output reg[31: 0] debug_ram3,
    output reg[31: 0] debug_ram4,
    output reg[31: 0] debug_ram5,
    output reg[31: 0] debug_ram6,
    output reg[31: 0] debug_ram7
);
    reg[31: 0] mem[`RAM_SIZE - 1: 0];

    assign debug_ram0 = mem[32'h0];
    assign debug_ram1 = mem[32'h1];
    assign debug_ram2 = mem[32'h2];
    assign debug_ram3 = mem[32'h3];
    assign debug_ram4 = mem[32'h4];
    assign debug_ram5 = mem[32'h5];
    assign debug_ram6 = mem[32'h6];
    assign debug_ram7 = mem[32'h7];

    integer i;

    reg busy;
    wire handshake_done = valid_in && ready_out;
    wire[31: 0] ram_addr = ram_addr_in / 4;

    always @(*) begin
        if (!rst) begin
            ready_out = 1'b0;
            for (i = 0; i < `RAM_SIZE; i = i + 1) begin
                mem[i] = 32'b0;
            end
        end
        else begin
            ready_out = ~busy;
        end
    end

    always @(posedge clk or negedge rst) begin
        rdata_valid_out <= 1'b0;
        if (!rst) begin
            busy <= 1'b0;
            ram_read_data_out <= 32'b0;
        end
        else begin
            if (handshake_done) begin
                busy <= 1'b1;
                if (ram_write_en_in) begin
                    case (ram_write_byte_en_in)
                        4'b0001: mem[ram_addr][7: 0] <= ram_write_data_in[7: 0];
                        4'b0010: mem[ram_addr][15: 8] <= ram_write_data_in[7: 0];
                        4'b0100: mem[ram_addr][23: 16] <= ram_write_data_in[7: 0];
                        4'b1000: mem[ram_addr][31: 24] <= ram_write_data_in[7: 0];
                        4'b0011: mem[ram_addr][15: 0] <= ram_write_data_in[15: 0];
                        4'b1100: mem[ram_addr][31: 16] <= ram_write_data_in[15: 0];
                        4'b1111: mem[ram_addr] <= ram_write_data_in;
                        default: mem[ram_addr] <= mem[ram_addr];
                    endcase
                end
                else begin
                    ram_read_data_out <= mem[ram_addr];
                    rdata_valid_out <= 1'b1;
                end
            end
            else if(busy) begin
                busy <= 1'b0;
                rdata_valid_out <= 1'b0;
            end
        end
    end
endmodule