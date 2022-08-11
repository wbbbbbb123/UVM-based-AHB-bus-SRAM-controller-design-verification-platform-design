
`define DSIZE 16  //data_size 8bit/16bit/32bit
`define DATA_DEPTH 2**15 //data_size=8bit-->DATA_DEPTH=2**16    data_size=16bit-->DATA_DEPTH=2**15   data_size=32bit-->DATA_DEPTH=2**14
`define HCLK_PERIOD 50 //write clk 200ns
`define START_ADDR  324
/////////////////////AHB CTR////////////////////////
//h_size
`define SIZE8  3'b000 //00:8bit、01:16bit、10:32bit
`define SIZE16 3'b001
`define SIZE32 3'b010
//htrans
`define NOTRANS 2'b00 //是否传输
`define TRANS   2'b10
//hwrite
`define WR_EN    1'b1
`define RD_EN    1'b0
//hsel
`define SEL      1'b1
`define NOSEL    1'b0
//hburst
`define BURST    3'd0
`define BURST_EN 3'd1
//hready
`define READY    1'b1
`define NOREADY  1'b0

