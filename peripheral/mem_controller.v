module mem_controller (
    input wire clk,
    input wire rst,

    input wire[31: 0] mc_addr_in,
    input wire[31: 0] mc_write_data_in,
    input wire[3: 0]  mc_write_byte_en_in,
    input wire cs,

    input wire mc_read_en_in,
    input wire mc_write_en_in,

    input wire valid_in,
    output reg ready_out,
    output reg rdata_valid_out,
    output reg[31: 0] mc_read_data_out
);
    wire data_ram_valid_in;
    wire instr_ram_valid_in;
    wire data_ram_valid_out;
    wire instr_ram_valid_out;
    wire data_ram_ready;
    wire instr_ram_ready;
    
    wire [31:0] data_ram_read_data_out;
    wire [31:0] instr_ram_read_data_out;

    assign data_ram_valid_in = cs & valid_in;
    assign instr_ram_valid_in = !cs & valid_in; 

    always @(posedge clk) begin
        if (!rst) begin
            ready_out           <= 1'b0;
            rdata_valid_out     <= 1'b0;
            mc_read_data_out    <= 32'b0;
        end
        else begin
       end
    end
    always@(*) begin
        ready_out <= cs ? data_ram_ready : instr_ram_ready;
        rdata_valid_out <= cs ? data_ram_valid_out : instr_ram_valid_out;
        mc_read_data_out = cs ? data_ram_read_data_out : instr_ram_read_data_out;
    end

    /* data ram
    */
    ram data_ram (
        .clk                        (clk),
        .rst                        (rst),
        .ram_addr_in                (mc_addr_in),
        .ram_write_data_in          (mc_write_data_in),
        .ram_read_en_in             (mc_read_en_in),
        .ram_write_en_in            (mc_write_en_in),
        .ram_write_byte_en_in       (mc_write_byte_en_in),
        .valid_in                   (data_ram_valid_in),
        .ready_out                  (data_ram_ready),
        .rdata_valid_out            (data_ram_valid_out),
        .ram_read_data_out          (data_ram_read_data_out)
    );
    
    /* instr ram
    read only
    */
    ram instr_ram (
        .clk                        (clk),
        .rst                        (rst),
        .ram_addr_in                (mc_addr_in),
        .ram_write_data_in          (mc_write_data_in),
        .ram_read_en_in             (mc_read_en_in),
        .ram_write_en_in            (1'b0),
        .ram_write_byte_en_in       (4'b0),
        .valid_in                   (instr_ram_valid_in),
        .ready_out                  (instr_ram_ready),
        .rdata_valid_out            (instr_ram_valid_out),
        .ram_read_data_out          (instr_ram_read_data_out)
    );

endmodule