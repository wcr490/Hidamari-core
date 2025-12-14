`timescale 1ps/1ps

module dual_port_mem_tb (
);
    reg clk;
    reg rst;
    
    // 指令端口信号
    reg instr_valid_in;
    reg[31:0] instr_addr_in;
    wire instr_ready_out;
    wire instr_rdata_valid_out;
    wire[31:0] instr_rdata_out;
    
    // 数据端口信号
    reg data_valid_in;
    reg[31:0] data_addr_in;
    reg[31:0] data_wdata_in;
    reg[3:0] data_byte_en_in;
    reg data_read_en_in;
    reg data_write_en_in;
    wire data_ready_out;
    wire data_rdata_valid_out;
    wire[31:0] data_rdata_out;

    // 实例化双端口内存控制器
    dual_port_mem_controller dut (
        .clk                    (clk),
        .rst                    (rst),
        
        // 指令端口
        .instr_addr_in          (instr_addr_in),
        .instr_valid_in         (instr_valid_in),
        .instr_ready_out        (instr_ready_out),
        .instr_rdata_valid_out  (instr_rdata_valid_out),
        .instr_rdata_out        (instr_rdata_out),
        
        // 数据端口
        .data_addr_in           (data_addr_in),
        .data_wdata_in          (data_wdata_in),
        .data_byte_en_in        (data_byte_en_in),
        .data_read_en_in        (data_read_en_in),
        .data_write_en_in       (data_write_en_in),
        .data_valid_in          (data_valid_in),
        .data_ready_out         (data_ready_out),
        .data_rdata_valid_out   (data_rdata_valid_out),
        .data_rdata_out         (data_rdata_out)
    );

    always #10 clk = ~clk;
    
    initial begin
        // 初始化
        rst <= 1'b0;
        clk <= 1'b1;
        instr_valid_in <= 1'b0;
        data_valid_in <= 1'b0;
        data_read_en_in <= 1'b0;
        data_write_en_in <= 1'b0;
        data_addr_in <= 32'h0;
        data_wdata_in <= 32'h0;
        data_byte_en_in <= 4'b0;
        instr_addr_in <= 32'h0;

        #30
        rst <= 1'b1;
        
        // 测试1: 数据端口写入
        $display("测试1: 数据端口写入");
        data_addr_in <= 32'h00000004;
        data_wdata_in <= 32'hdeadbeef;
        data_byte_en_in <= 4'b1111;
        data_write_en_in <= 1'b1;
        data_valid_in <= 1'b1;
        
        #20
        wait(data_ready_out)
        #20
        data_write_en_in <= 1'b0;
        data_valid_in <= 1'b0;
        
        #40
        
        // 测试2: 数据端口读取
        $display("测试2: 数据端口读取");
        data_addr_in <= 32'h00000004;
        data_read_en_in <= 1'b1;
        data_valid_in <= 1'b1;
        
        #20
        wait(data_ready_out)
        #20
        if (data_rdata_valid_out) begin
            $display("读取数据: 0x%h", data_rdata_out);
            if (data_rdata_out == 32'hdeadbeef) begin
                $display("数据端口读写测试通过");
            end else begin
                $display("数据端口读写测试失败");
            end
        end
        data_read_en_in <= 1'b0;
        data_valid_in <= 1'b0;
        
        #40
        
        // 测试3: 指令端口读取 (应该返回0，因为指令RAM未初始化)
        $display("测试3: 指令端口读取");
        instr_addr_in <= 32'h00000008;
        instr_valid_in <= 1'b1;
        
        #20
        wait(instr_ready_out)
        #20
        if (instr_rdata_valid_out) begin
            $display("指令读取数据: 0x%h", instr_rdata_out);
        end
        instr_valid_in <= 1'b0;
        
        #40
        
        // 测试4: 并行访问测试 - 同时访问指令和数据端口
        $display("测试4: 并行访问测试");
        // 先写入一些数据到数据RAM
        data_addr_in <= 32'h00000010;
        data_wdata_in <= 32'h12345678;
        data_byte_en_in <= 4'b1111;
        data_write_en_in <= 1'b1;
        data_valid_in <= 1'b1;
        
        #20
        wait(data_ready_out)
        #20
        data_write_en_in <= 1'b0;
        data_valid_in <= 1'b0;
        
        #20
        
        // 现在同时启动指令和数据端口访问
        data_addr_in <= 32'h00000010;
        data_read_en_in <= 1'b1;
        data_valid_in <= 1'b1;
        
        instr_addr_in <= 32'h0000000c;
        instr_valid_in <= 1'b1;
        
        #20
        wait(data_ready_out && instr_ready_out)
        #20
        if (data_rdata_valid_out && instr_rdata_valid_out) begin
            $display("并行访问成功:");
            $display("  数据端口读取: 0x%h", data_rdata_out);
            $display("  指令端口读取: 0x%h", instr_rdata_out);
            if (data_rdata_out == 32'h12345678) begin
                $display("并行访问测试通过 - 两个端口可以同时工作");
            end else begin
                $display("并行访问测试失败 - 数据不正确");
            end
        end
        
        data_read_en_in <= 1'b0;
        data_valid_in <= 1'b0;
        instr_valid_in <= 1'b0;
        
        #80
        $display("所有测试完成");
        $finish;
    end

    initial begin
        $dumpfile("./build/dual_port_mem_out.vcd");
        $dumpvars(0, dual_port_mem_tb);
        $dumpvars(1, dut);
    end
endmodule