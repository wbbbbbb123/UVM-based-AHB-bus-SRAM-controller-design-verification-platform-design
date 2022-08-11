`timescale 1ns/1ps
//`include "uvm_macros.svh"
// import uvm_pkg::*;
`include "define.sv"
`include "my_if.sv"
`include "my_transaction.sv"
`include "read_sramc_transaction.sv"
`include "write_sramc_sequencer.sv"
`include "read_sramc_sequencer.sv"
`include "write_sramc_seq.sv"
`include "read_sramc_seq.sv"
`include "my_virtual_sequencer.sv"
`include "write_sramc_driver.sv"
`include "read_sramc_driver.sv"
`include "write_sramc_monitor.sv"
`include "read_sramc_monitor.sv"
`include "write_sramc_agent.sv"
`include "read_sramc_agent.sv"
`include "my_model.sv"
`include "my_scoreboard.sv"
`include "my_env.sv"
`include "base_test.sv"
`include "my_case0.sv"
`include "my_case1.sv"
`include "my_case2.sv"

module top_tb;

reg hclk;
reg hresetn;


my_if vif(hclk, hresetn);


  
sramc_top   u_sramc_top(                 
  .hclk           (hclk            ),
  .sram_clk       (vif.sram_clk    ),
  .hresetn        (hresetn         ),//给DUT
  .hsel           (vif.hsel        ),//给DUT
  .hwrite         (vif.hwrite      ),//给DUT
  .htrans         (vif.htrans      ),//给DUT
  .hsize          (vif.hsize       ),//给DUT
  .hready         (vif.hready      ),//给DUT
  .hburst         (3'b0),                 //无用 burst没用的话就接0，在tr里面激励产生什么都关系不大了
  .haddr          (vif.haddr       ),//给DUT
  .hwdata         (vif.hwdata      ),//给DUT
  .hrdata         (vif.hrdata      ),//给DUT
  .dft_en         (1'b0),            //不测    dft不测，写成0        
  .bist_en        (1'b0),            //不测
  .hready_resp    (vif.hready_resp ),              
  .hresp          (vif.hresp       ),
  .bist_done      ( ),               //不测              
  .bist_fail      ( )                //不测
);  

initial begin
   hclk = 0;
   forever begin
     #(`HCLK_PERIOD/2); 
     hclk = ~hclk;
   end
end

initial begin
   hresetn = 1'b0;
   #101;
   hresetn = 1'b1;
end

initial begin
  run_test("my_case0");
end

initial begin
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.drv", "wr_if", vif);
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.mon", "wr_if", vif);
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.o_agt.drv", "rd_if", vif);
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.o_agt.mon", "rd_if", vif);
end

initial begin
   $dumpfile("top_tb.vcd");
   $dumpvars;
end

endmodule




// /*///////////////////////
// 	   TESTBENCH
// *////////////////////////
// `timescale 1ns/1ps
// `define START_ADDR   8192//32bit:0~2*8192-1、16bit:0~4*8192-1、8bit:0~8*8192-1
// `define DATA_SIZE    16  
// `define IS_SEQ       1   //1：SEQ write、read  0：NOSEQ write、read（STL中两种都一样）


// class random_data;
//     rand  bit [`DATA_SIZE-1:0] data;
//     rand  bit [`DATA_SIZE-1:0] delay;
//     constraint c_delay{
//         delay <=50;
//     }
// endclass

// module tb_sramc_top();

// //interface define
// reg           hclk       ;//产生时钟信号
// wire          sram_clk   ;//hclk 的反向，与hclk属于同一个时钟沿
// reg           hresetn    ;//复位
// reg           hsel       ;//选中该slave
// reg           hwrite     ;//读写模式0:读、1:写
// reg [1:0]     htrans     ;//传输是否有效00:空闲、01:忙、10:非连续、11:连续
// reg [2:0]     hsize      ;//有效传输位00：8bit、01：16bit、10：32bit
// reg           hready     ;// master -> slave，一般接常高
// reg [31:0]    haddr      ;//本次命令访问的地址
// reg [31:0]    hwdata     ;// 写数据
// wire [31:0]   hrdata     ;// 从sram读出的数据
// wire          hready_resp;// slave -> master，看 slave 是否ready
// wire [1:0]    hresp      ;// hresp 也只会返回0，即ok状态。

// reg  [`DATA_SIZE-1:0]   rdata      ;//读出数据
// reg                     r_data_en;
// static int wr_iter = 0 ;
// static int rd_iter = 0 ;


// always #10 hclk = ~hclk;
// assign     sram_clk = ~hclk;

// random_data  rm_data;


// initial begin
//     hclk  =1;
//     hresetn = 0;
//     #200
//     hresetn = 1;
// end

// initial begin:process
//     rm_data = new();
//     direct_write_during_read(16'd8);
//     #200;
//     loop_wr_rd_data(16'd18);
    
//     $finish;
// end

// task ahb_init();
//     hsel   = 1'b0 ;//未中该slave
//     hwrite = 1'b1 ;//写
//     htrans = `IS_SEQ?2'b11:2'b10;
//     hsize  = (`DATA_SIZE==32)?2'b10:((`DATA_SIZE==16)?2'b01:((`DATA_SIZE==8)?2'b00:2'b10));//00:8bit、01:16bit、10:32bit、11:32bit
//     hready = 1'b1;
//     haddr  = 32'd0;
//     hwdata = 32'd0;
//     rdata  = 32'd0;
//     r_data_en = 1'b0;
//     wait(hresetn);
//     repeat(3)@(posedge sram_clk);
// endtask

// task write_data;
// input [15:0] wr_nums;
// begin
//     repeat(wr_nums)begin
//         @(posedge hclk);
//         rm_data.randomize();
//         hsel   = 1'b1 ;//选中该slave
//         hwrite = 1'b1 ;//写
//         haddr  =  `START_ADDR + wr_iter;
//         wr_iter = wr_iter +1;
//         @(posedge hclk);
//         hwdata = rm_data.data;
//         hsel = 1;
//     end
// end
// endtask

// task read_data;
// input [15:0] rd_nums;
// begin
//     repeat(rd_nums)begin
//         @(posedge sram_clk);
//         hsel   = 1'b1 ;//选中该slave
//         hwrite = 1'b0;//read
//         haddr  =  `START_ADDR + rd_iter;//bank1 cs0
//         rd_iter = rd_iter +1;
//         @(posedge sram_clk); 
//         hsel   = 1'b0 ;
//         //@(posedge hclk);
//         rdata <= hrdata[`DATA_SIZE-1:0];
//     end
// end
// endtask

// task direct_write_during_read;
// input [15:0] wr_nums;//读写次数
// begin
//     ahb_init();
//     repeat(wr_nums)begin
//         write_data(1);
//         read_data(1);
//     end
//     @(posedge sram_clk);
//     @(posedge hclk);
//     ahb_init();
//     #200;
// end 
// endtask

// task loop_wr_rd_data;
// input [15:0] wr_nums;
// begin
//     ahb_init();
//     write_data(wr_nums);
//     #rm_data.delay;
//     read_data(wr_nums);
//     @(posedge sram_clk);
//     @(posedge hclk);
//     ahb_init();
//     #200;
// end
// endtask

// sramc_top   u_sramc_top(                 
//           .hclk           (hclk      ),    //input
//           .sram_clk       (sram_clk   ),   //input
//           .hresetn        (hresetn    ),   //input
//           .hsel           (hsel       ),   //input
//           .hwrite         (hwrite     ),   //input
//           .htrans         (htrans     ),   //input [1:0]
//           .hsize          (hsize      ),   //input [2:0]
//           .hready         (hready     ),   //input
//           .haddr          (haddr      ),   //input [31:0]
//           .hwdata         (hwdata     ),   //input [31:0]
//           .hrdata         (hrdata     ),   //output [31:0]
//           .hready_resp    (hready_resp),   //output           
//           .hresp          (hresp      ),   //output [1:0]   
             
//           .hburst         (3'b0),      	   //burst没用的话就接0，在tr里面激励产生什么都关系不大了              
//           .dft_en         (1'b0),      	   //不测    dft不测，写成0        
//           .bist_en        (1'b0),          //不测
//           .bist_done      ( ),             //不测              
//           .bist_fail      ( )          	   //不测
// );

// endmodule
