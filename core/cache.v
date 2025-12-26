`timescale 1ps/1ps

/*
 *  cache -> set -> way -> line
 */

`define CACHE_LINE_NUM 64
`define CACHE_LINE_SIZE 16
`define CACHE_LINE_BIT_NUM (`CACHE_LINE_SIZE * 8)
`define CACHE_WAY_NUM 64

module cache_way (
    input wire clk,
    input wire rst,

    input wire[31: 0] cw_addr_in,
    input wire[31: 0] cw_wdata_in,
    input wire[`CACHE_LINE_BIT_NUM - 1: 0] cw_ldata_in,
    input wire[1: 0] cw_byte_en_in,
    input wire cs,
    input wire cw_write_en,
    input wire cw_load_en,
    
    output wire[31: 0] cw_rdata_out,
    output wire[`CACHE_LINE_BIT_NUM - 1: 0] cw_wbdata_out,
    output wire cw_dirty_out,
    output wire cw_hit_out
);
    reg[`CACHE_LINE_BIT_NUM - 1: 0] data[`CACHE_LINE_NUM - 1: 0];
    reg[21: 0] tags[`CACHE_LINE_NUM - 1: 0];
    reg valid[`CACHE_LINE_NUM - 1: 0];
    reg dirty[`CACHE_LINE_NUM - 1: 0];
    wire[3: 0] offset = cw_addr_in[3: 0];
    wire[5: 0] index = cw_addr_in[9: 4];
    wire[21: 0] tag = cw_addr_in[31: 10];

    assign cw_hit_out = (valid[index] && (tags[index] == tag)) ? 1'b1 : 1'b0;
    assign cw_dirty_out = dirty[index];
    assign cw_rdata_out = (cs && cw_hit_out) ? 
            (cw_byte_en_in == 2'b01 ? ({24'h0, data[index][offset*8 +: 8]})    : 
                (cw_byte_en_in == 2'b10 ? {16'h0, data[index][offset*8 +: 16]} : 
                {data[index][offset*8 +: 32]})
            )
        : 32'bz;
    assign cw_wbdata_out = cs ? (data[index]) : {`CACHE_LINE_BIT_NUM{1'bz}};

    integer i;
    always @(posedge clk) begin
        if (!rst) begin
            for(i = 0; i < `CACHE_LINE_NUM; i = i + 1) begin
                data[i] <= 32'b0;
                tags[i] <= 22'b0;
                valid[i] <= 1'b0;
                dirty[i] <= 1'b0;
            end
        end
        else if (cs) begin
            if (cw_write_en) begin
                case (cw_byte_en_in)
                    2'b01: begin
                        data[index][offset*8 +: 8] <= cw_wdata_in[7: 0];
                    end 
                    2'b10: begin
                        data[index][offset*8 +: 16] <= cw_wdata_in[15: 0];
                    end
                    default: begin
                        data[index][offset*8 +: 32] <= cw_wdata_in[31: 0];
                    end
                endcase
                dirty[index] <= 1'b1;
            end
            else if (cw_load_en) begin
                dirty[index] <= 1'b0;
                valid[index] <= 1'b1;
                data[index] <= cw_ldata_in;
                tags[index] <= tag;
            end
        end
    end
endmodule

module cache_set (
    input wire clk,
    input wire rst,

    input wire[31: 0] cs_addr_in,
    input wire[31: 0] cs_wdata_in,
    input wire[`CACHE_LINE_BIT_NUM - 1: 0] cs_ldata_in,
    input wire[1: 0] cs_byte_en_in,
    input wire cs_read_en,
    input wire cs_write_en,
    input wire cs_load_en,
    input wire begin_load,
    
    output wire[31: 0] cs_rdata_out,
    output wire[`CACHE_LINE_BIT_NUM - 1: 0] cs_wbdata_out,
    output wire cs_dirty_out,
    output wire cs_hit_out,

    output reg cs_ready_out
);

    wire[5: 0] index = cs_addr_in[9: 4];

    localparam CACHE_IDLE = 3'b000, CACHE_SELECT = 3'b001, CACHE_LOAD = 3'b010;
    localparam DEPTH = $clog2(`CACHE_WAY_NUM);
    reg[2: 0] state, next_state;
    wire[`CACHE_LINE_BIT_NUM - 1: 0] way_wbdata[`CACHE_WAY_NUM - 1: 0];
    reg[`CACHE_WAY_NUM - 1: 0] way_cs[`CACHE_LINE_NUM - 1: 0];
    wire[`CACHE_WAY_NUM - 1: 0] way_hit;
    wire[`CACHE_WAY_NUM - 1: 0] way_dirty;
    reg[`CACHE_WAY_NUM - 1 - 1: 0] plru_tree;
    reg[DEPTH - 1: 0] replace_idx;

    genvar cw_i;
    generate
        for (cw_i = 0; cw_i < `CACHE_WAY_NUM; cw_i = cw_i + 1) begin: cw_gen
            cache_way cw(
                .clk                (clk),
                .rst                (rst),
                .cw_addr_in         (cs_addr_in),
                .cw_wdata_in        (cs_wdata_in),
                .cw_ldata_in        (cs_ldata_in),
                .cw_byte_en_in      (cs_byte_en_in),
                .cs                 (way_cs[index][cw_i]),
                .cw_write_en        (cs_write_en),
                .cw_load_en         (begin_load),
                .cw_rdata_out       (cs_rdata_out),
                .cw_wbdata_out      (way_wbdata[cw_i]),
                .cw_dirty_out       (way_dirty[cw_i]),
                .cw_hit_out         (way_hit[cw_i]) 
            );
        end
    endgenerate

    always @(posedge clk) begin
        if (!rst) begin
            state <= CACHE_IDLE;
        end
        else begin
            state <= next_state;
        end
    end
    integer j;
    integer i, cur_dep, plru_ptr;
    always @(*) begin
        if (!rst) begin
            for (j = 0; j < `CACHE_LINE_NUM; j = j + 1) begin
                way_cs[j] = {`CACHE_WAY_NUM{1'b0}};
            end
            plru_tree = {(`CACHE_WAY_NUM - 1){1'b0}};
            replace_idx = {(DEPTH){1'b0}};
            next_state = CACHE_IDLE;
            cs_ready_out = 1'b0;
            // cs_rdata_out is driven by cache_way modules through three-state bus
            // cs_dirty_out is driven by cache_way modules
            // cs_hit_out is driven by cache_way modules
        end
        else begin
            case (state)
                CACHE_IDLE: begin
                    if (cs_read_en) begin
                        cs_ready_out = 1'b1;
                        update_hit();
                    end
                    else if (cs_write_en || cs_load_en) begin
                        cs_ready_out = 1'b0;
                        next_state = CACHE_SELECT;
                    end
                end
                CACHE_SELECT: begin
                    if (cs_load_en) begin
                        way_cs[index][replace_idx] = 1'b1;
                        next_state = CACHE_LOAD;
                    end
                    else begin
                        update_hit();
                        next_state = CACHE_IDLE;
                    end
                    cs_ready_out = 1'b1;
                end
                CACHE_LOAD: begin
                    if (!begin_load) begin
                        next_state = state;
                        cs_ready_out = 1'b0;
                    end
                    else begin
                        next_state = CACHE_IDLE;
                        cs_ready_out = 1'b1;
                    end
                end
                default: begin
                    next_state = CACHE_IDLE;
                end
            endcase
        end
    end

    task update_hit();
        if (cs_read_en || cs_write_en) begin
            if (|way_hit) begin
                // cs_hit_out is now driven by cache_way modules directly
                // cs_dirty_out is now driven by cache_way modules directly
                // cs_rdata_out is now driven by cache_way modules directly through three-state bus
                for (i = 0; i < `CACHE_WAY_NUM; i = i + 1) begin
                    if (way_hit[i]) begin
                        plru_ptr = 0;
                        for (cur_dep = DEPTH - 1; cur_dep >= 0; cur_dep = cur_dep - 1) begin
                            plru_tree[plru_ptr] = i[cur_dep];
                            if (i[cur_dep]) begin
                                plru_ptr = plru_ptr * 2 + 2;
                            end
                            else begin
                                plru_ptr = plru_ptr * 2 + 1;
                            end
                        end
                        plru_ptr = 0;
                        for (cur_dep = DEPTH - 1; cur_dep >= 0; cur_dep = cur_dep - 1) begin
                            replace_idx[cur_dep] = plru_tree[plru_ptr];
                            if (replace_idx[cur_dep]) begin
                                plru_ptr = plru_ptr * 2 + 2;
                            end
                            else begin
                                plru_ptr = plru_ptr * 2 + 1;
                            end
                        end
                    end
                end
            end
        end
    endtask
endmodule