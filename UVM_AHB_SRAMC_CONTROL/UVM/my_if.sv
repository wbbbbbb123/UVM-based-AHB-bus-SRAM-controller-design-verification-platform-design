`include "define.sv"
`ifndef MY_IF__SV
`define MY_IF__SV
interface my_if(input hclk,input hresetn);        
  logic               sram_clk   ;  //sram时钟信号
  logic               hsel       ;  //slave选择信号
  logic               hwrite     ;  //读/写命令(控制信号)
  logic               hready     ;  //由mater发给slave(状态信号)，高：有效；低，无效
  logic  [1:0]        htrans     ;  //指示命令是否有效、是否连续传输(控制信号)
  logic  [2:0]        hsize      ;  //传输总线的有效数据位(控制信号)
  logic  [2:0]        hburst     ;  //
  logic  [31:0]       haddr      ;  //32位系统总线地址信号
  logic  [31:0]       hwdata     ;  //写数据总线信号
  logic               hready_resp;  //output hready_out(状态信号)，slave输出给master，表明slave是否OK
  logic  [1:0]        hresp      ;  //output hrdata信号(状态信号)，表明传输是否OK，00：OKAY，01：ERROR
  logic  [`DSIZE:0]   hrdata     ;  //output 读数据总线信号

  assign sram_clk = ~hclk;	

  
//   clocking c_wr @(posedge hclk);//写时钟

//     output  hsel    ;
//     output  hwrite  ;
//     output  hready  ;
//     output  htrans  ;
//     output  hsize   ;
//     output  hburst  ;
//     output  haddr   ;
//     output  hwdata  ;      

//   endclocking

//   clocking c_rd @(posedge hclk);//读时钟

//     output  hsel    ;
//     output  hwrite  ;
//     output  hready  ;
//     output  htrans  ;
//     output  hsize   ;
//     output  hburst  ;
//     output  haddr   ;
//     input   hrdata  ;      

//   endclocking
  

endinterface
`endif //ASYNCF_IF__SV
