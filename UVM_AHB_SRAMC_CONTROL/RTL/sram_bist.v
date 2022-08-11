`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/17 16:53:17
// Design Name: 
// Module Name: sram_bist
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sram_bist(
    //input signals
    input         hclk,
    input         sram_clk,
    input         sram_rst_n,
    input         sram_csn_in,   //chip select(negative) enable (0 有效)
    input         sram_wen_in,   //sram write or read enable; 0:write; 1:read
    input[12:0]   sram_addr_in,  // 物理地址 8个8K = 2^13
    input[7:0 ]   sram_wdata_in, // 每个8K x 8bit 的数据位宽
    input         bist_en,       // MBIST mode
    input         dft_en,      // DFT mode

    //output signals
    output[7:0 ]  sram_data_out, 
    output        bist_done,     // 1: test over
    output        bist_fail      // high: MBIST Fail
);
				
    //----------------------------------------------------
    //Internal signals connected the sram with bist module 
    //when "bist_en" active high.
    //----------------------------------------------------
    wire sram_csn;
    wire sram_wen;
    wire sram_oen;
    wire [12:0] sram_a;
    wire [7:0]  sram_d;
    wire [7:0]  data_out;

    //Sram output data when "dft_en" active high.
    wire [7:0] dft_data;
    reg [7:0]  dft_data_r;

    wire [12:0] sram_addr;
    wire [7:0]  sram_wdata;

    //clock for bist logic, when bist is not work, clock should be 0.
    wire bist_clk;

    genvar K;

    //block sram input when cs is diable for low power design 
    assign sram_addr = sram_csn_in ? 0 : sram_addr_in;
    assign sram_wdata = sram_csn_in ? 0 : sram_wdata_in;

    //dft test result 具体为什么这么异或，不需要太关注
    assign dft_data = (sram_d ^ sram_a[7:0]) ^ {sram_csn, sram_wen, sram_oen, sram_a[12:8]}; 

    always @(posedge hclk or negedge sram_rst_n) begin
    if(!sram_rst_n)
        dft_data_r <= 0;
    else if(dft_en)
        dft_data_r <= dft_data;
    end

    //sram data output
    assign sram_data_out = dft_en ? dft_data_r : data_out;
    // Note: Need to take place the mux using the special library cell
    /*
    generate for(K = 0; K < 8; K = K+1 )
    begin :hold
    //BHDBWP7T holdQ (.Z(data_out[K])); // 作用：把data_out做一个保持 在做DFT的时候是例化标准单元（源语）实现的，没有用RTL方式
    end 
    endgenerate
    */

    //clock for bist logic, when bist is not work, clock should be 0.
    // Note: Need to take place the mux using the special library cell
    // CKMUX2D2BWP7T U_bist_clk_mux (.I0(1'b0), .I1(hclk), .S(bist_en), .Z(bist_clk));
    assign bist_clk = bist_en ? hclk : 1'b0;

    // One sram with BIST and DFT function
    // 在整个SRAM_BIST 中实际上包含了两部分代码，一部分是存储单元，一部分是Memory Bist
    // sram_sp_hse_8kx8 : sram singleport high density 8k depth x 8bit width
    RA1SH u_RA1SH(
        .Q      (data_out), // 输出数据端口
        .CLK    (sram_clk), // hclk 取反
        .CEN    (sram_csn), // chip select 低有效
        .WEN    (sram_wen), // 写使能，低有效
        .A      (sram_a),   // Address 地址(要么是读，要么是写) 选择功能地址还是DFT测试地址
        .D      (sram_d),   // Data 数据 从下面的Bist过来的
        .OEN    (sram_oen)  // 没怎么用，只在bist的时候用了一下
    );

    //测试控制逻辑
    sram_bist_8kx8 u_sram_bist_8kx8(
        .b_clk   (bist_clk),   // 同hclk
        .b_rst_n (sram_rst_n), 
        .b_te    (bist_en),    // 外面给过来的启动使能
        //--------------------------------------------------------
        //All the input signals will be derectly connected to
        //the sram input when in normal operation; and when in
        //BIST TEST mode, there are some mux in BIST module
        //selcting all sram input signals which generated by itself:
        //sram controll signals, sram write data, etc.
        //--------------------------------------------------------

        // xx_fun 表示从ahb过来的， 需要验证的功能
        .addr_fun     (sram_addr), // 物理地址 = 系统地址 / 4
        .wen_fun      (sram_wen_in), // ahb_wen 基础上取反 1读 0写
        .cen_fun      (sram_csn_in), // ahb的address 和 size 低两比特得到的 csn
//        .oen_fun      (~sram_wen_in),        // 低电平有效，一直打开
        .oen_fun      (1'b0),        // 低电平有效，一直打开
        .data_fun     (sram_wdata),  // 写数据

        // 输出不用选，测试电路和功能电路都会送过去
        .ram_read_out (sram_data_out), //
        .data_test    (sram_d),
        .addr_test    (sram_a), // sram_addr 和 内部产生的addr进行 bist_en 选择之后输出的一个值
        .wen_test     (sram_wen), // wen 也是通过bist_en选择之后输出的
        .cen_test     (sram_csn),
        .oen_test     (sram_oen),

        .b_done       (bist_done),
        .b_fail       (bist_fail)
    );

endmodule
