`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/18 08:58:00
// Design Name: 
// Module Name: tb_sramc_top
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


`define START_ADDR   8192//32bit:0~2*8192-1��16bit:0~4*8192-1��8bit:0~8*8192-1
`define DATA_SIZE    16  
`define IS_SEQ       1   //1��SEQ write��read  0��NOSEQ write��read��STL�����ֶ�һ����


class random_data;
    rand  bit [`DATA_SIZE-1:0] data;
    rand  bit [`DATA_SIZE-1:0] delay;
    constraint c_delay{
        delay <=50;
    }
endclass

module tb_sramc_top();

//interface define
reg           hclk       ;//����ʱ���ź�
wire          sram_clk   ;//hclk �ķ�����hclk����ͬһ��ʱ����
reg           hresetn    ;//��λ
reg           hsel       ;//ѡ�и�slave
reg           hwrite     ;//��дģʽ0:����1:д
reg [1:0]     htrans     ;//�����Ƿ���Ч00:���С�01:æ��10:��������11:����
reg [2:0]     hsize      ;//��Ч����λ00��8bit��01��16bit��10��32bit
reg           hready     ;// master -> slave��һ��ӳ���
reg [31:0]    haddr      ;//����������ʵĵ�ַ
reg [31:0]    hwdata     ;// д����
wire [31:0]   hrdata     ;// ��sram����������
wire          hready_resp;// slave -> master���� slave �Ƿ�ready
wire [1:0]    hresp      ;// hresp Ҳֻ�᷵��0����ok״̬��

reg  [`DATA_SIZE-1:0]   rdata      ;//��������
reg                     r_data_en;
static int wr_iter = 0 ;
static int rd_iter = 0 ;


always #10 hclk = ~hclk;
assign     sram_clk = ~hclk;

random_data  rm_data;


initial begin
    hclk  =1;
    hresetn = 0;
    #200
    hresetn = 1;
end

initial begin:process
    rm_data = new();
    direct_write_during_read(16'd8);
    #200;
    loop_wr_rd_data(16'd18);
    
    $finish;
end

task ahb_init();
    hsel   = 1'b0 ;//δ�и�slave
    hwrite = 1'b1 ;//д
    htrans = `IS_SEQ?2'b11:2'b10;
    hsize  = (`DATA_SIZE==32)?2'b10:((`DATA_SIZE==16)?2'b01:((`DATA_SIZE==8)?2'b00:2'b10));//00:8bit��01:16bit��10:32bit��11:32bit
    hready = 1'b1;
    haddr  = 32'd0;
    hwdata = 32'd0;
    rdata  = 32'd0;
    r_data_en = 1'b0;
    wait(hresetn);
    repeat(3)@(posedge sram_clk);
endtask

task write_data;
input [15:0] wr_nums;
begin
    repeat(wr_nums)begin
        @(posedge hclk);
        rm_data.randomize();
        hsel   = 1'b1 ;//ѡ�и�slave
        hwrite = 1'b1 ;//д
        haddr  =  `START_ADDR + wr_iter;
        wr_iter = wr_iter +1;
        @(posedge hclk);
        hwdata = rm_data.data;
        hsel = 1;
    end
end
endtask

task read_data;
input [15:0] rd_nums;
begin
    repeat(rd_nums)begin
        @(posedge sram_clk);
        hsel   = 1'b1 ;//ѡ�и�slave
        hwrite = 1'b0;//read
        haddr  =  `START_ADDR + rd_iter;//bank1 cs0
        rd_iter = rd_iter +1;
        @(posedge sram_clk); 
        hsel   = 1'b0 ;
        //@(posedge hclk);
        rdata <= hrdata[`DATA_SIZE-1:0];
    end
end
endtask

task direct_write_during_read;
input [15:0] wr_nums;//��д����
begin
    ahb_init();
    repeat(wr_nums)begin
        write_data(1);
        read_data(1);
    end
    @(posedge sram_clk);
    @(posedge hclk);
    ahb_init();
    #200;
end 
endtask

task loop_wr_rd_data;
input [15:0] wr_nums;
begin
    ahb_init();
    write_data(wr_nums);
    #rm_data.delay;
    read_data(wr_nums);
    @(posedge sram_clk);
    @(posedge hclk);
    ahb_init();
    #200;
end
endtask

sramc_top   u_sramc_top(                 
          .hclk           (hclk      ),    //input
          .sram_clk       (sram_clk   ),   //input
          .hresetn        (hresetn    ),   //input
          .hsel           (hsel       ),   //input
          .hwrite         (hwrite     ),   //input
          .htrans         (htrans     ),   //input [1:0]
          .hsize          (hsize      ),   //input [2:0]
          .hready         (hready     ),   //input
          .haddr          (haddr      ),   //input [31:0]
          .hwdata         (hwdata     ),   //input [31:0]
          .hrdata         (hrdata     ),   //output [31:0]
          .hready_resp    (hready_resp),   //output           
          .hresp          (hresp      ),   //output [1:0]   
             
          .hburst         (3'b0),      	   //burstû�õĻ��ͽ�0����tr���漤������ʲô����ϵ������              
          .dft_en         (1'b0),      	   //����    dft���⣬д��0        
          .bist_en        (1'b0),          //����
          .bist_done      ( ),             //����              
          .bist_fail      ( )          	   //����
);

endmodule

