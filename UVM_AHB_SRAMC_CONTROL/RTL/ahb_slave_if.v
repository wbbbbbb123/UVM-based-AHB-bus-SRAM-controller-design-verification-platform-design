`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/17 16:56:04
// Design Name: 
// Module Name: ahb_slave_if
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


module ahb_slave_if(
    //               AHB�ź��б�
    // singals used during normal operation
    input  hclk,
    input  hresetn,
    // signals from AHB bus during normal operation
    input  hsel,                   //hsel��Ϊ1����ʾѡ�и�SRAMC
    input  hready,                 //��Master���߷�����hready=1����/д������Ч��������Ч
    input  hwrite,                 //hwrite=1��д������hwrite=0��������
    input  [1:0]   htrans,         //��ǰ��������10��NONSEQ��11��SEQ(�����Ƿ���Ч)
    input  [2:0]   hsize,          //ÿһ�δ�������ݴ�С��֧��8/16/32bit����
    input  [2:0]   hburst,         //burst����������Ŀ���ã���0����
    input  [31:0]  haddr,          //AHB��32λϵͳ���ߵ�ַ
    input  [31:0]  hwdata,         //AHB��32λд���ݲ���
    // signals from sram_core data output (read srams)
    input  [7:0]  sram_q0,              //��ʾ��ȡsram�����ź�
    input  [7:0]  sram_q1,              //8ƬRAM�ķ�������
    input  [7:0]  sram_q2,              //���Ը���hsize��haddr�ж���һƬRAM��Ч
    input  [7:0]  sram_q3,
    input  [7:0]  sram_q4,
    input  [7:0]  sram_q5,
    input  [7:0]  sram_q6,
    input  [7:0]  sram_q7,
    


    // signals to AHB bus used during normal operation 
    //�����������->����AHB���ߣ��������ظ�Master������ź�
    output  [1:0]  hresp,             //״̬�źţ��ж�hrdata�������Ƿ����00��OKAY��01��ERROR�������
    output         hready_resp,       //�ж�hrdata�Ƿ���Ч��hready_out
    output  [31:0] hrdata,            //�������ź�

    // sram read or write enable signals��
    // ����5���ź�Ϊ���ظ�RAM���ź�
    // when "sram_w_en" is low, it means write sram, when "sram_w_en" is high, it means read sram,
    output  sram_w_en,         //дʹ���źţ�0��д��1����

    // choose the write srams when bank is confirmed
    // bank_csn allows the four bytes in the 32-bit width to be written independently
    output  reg        bank_sel,//bank_selΪ1����bank0�����ʣ�bank_selΪ0����bank1������
    output  reg [3:0]  bank0_csn,//bank0��Ƭ��ѡ��0Ϊѡ�и�Ƭ������4��b1100��ѡ��bank0����λƬ����
    output  reg [3:0]  bank1_csn,//bank1��Ƭ��ѡ��

    // signals to sram_core in normal operation, it contains sram address and data writing into sram 
    //��д�������->����sram�洢��Ԫ��
    output  [12:0]  sram_addr_out,          // ��ַ�������sram��13λ��ַ��8k=2^3*2^10=2^13��
    output  [31:0]  sram_wdata              //д���ݽ���sram
); 

    // internal registers used for temp the input ahb signals ����ʱ�źţ�
    // temperate all the AHB input signals
    reg         hwrite_r;         //_r:��ʾ��Щ�źŻᾭ���Ĵ����Ĵ�һ�ģ�
    reg  [2:0]  hsize_r;          //��ΪAHBЭ�鴫���Ϊ��ַ�׶κ����ݽ׶��������֣���SRAM�ĵ�ַ����������ͬһ�Ľ��д��䣬
    reg  [2:0]  hburst_r;         //AHB�ĵ�ַ�Ϳ����źŻ��������źŵ�ǰһ����Ч�����ԣ�Ϊ�˽�AHB��SRAM֮���Э�����ת����
    reg  [1:0]  htrans_r;         //ʹ���ݶ��룬�轫AHB�ĵ�ַ������źŴ�һ���ٴ��䣬��������SRAM�ĵ�ַ�����ݱ㴦��ͬһ�ģ�
    reg  [31:0] haddr_r;          //������SRAM��ʱ��Ҫ��

    reg  [3:0]  sram_csn;         //�ڲ��źţ�����sram��Ϊbank0��bank1�����֣��ڽ��ж�д����ʱ�����Ȼ���ݵ�ַ��Χ�ж�ѡ��bank0
                                  //����bank1���ٸ���hsize_r��haddr_r��ȷ��������ʵ�bank0/bank1�еľ�����һƬsram��
    // Internal signals    �м��ź�
    // "haddr'_sel" and "hsize_sel" used to generate banks of sram: "bank0_sel" and "bank1_sel"
    wire  [1:0]  haddr_sel;
    wire  [1:0]  hsize_sel;
    //reg          bank_sel;

    wire         sram_csn_en;     //sramƬѡʹ���ź�

    wire         sram_write;     //����AHB���ߵ�sramдʹ���ź�
    wire         sram_read;      //����AHB���ߵ�sram��ʹ���ź�
    wire  [15:0] sram_addr;      //����AHB���ߵ�sram��ַ�źţ�64K=2^5*2^10=2^15
    reg   [31:0] sram_data_out;  //��sram�����Ķ������źţ�������AHB����

    // transfer type signal encoding
    parameter  IDLE   = 2'b00; //����htrans��״̬
    parameter  BUSY   = 2'b01;
    parameter  NONSEQ = 2'b10; //���ݴ�����Ч(����������)
    parameter  SEQ    = 2'b11;  //���ݴ�����Ч(��������)
   
    parameter SUB_DATA = 1'b0;//������ݲ�״̬(�����16λ���ݣ����16λ��SUB_DATA)
//--------------------------------------------------------------------------------------------------------
//----------------------------------------------Main code��������------------------------------------------
//--------------------------------------------------------------------------------------------------------


    // Combitional portion ,     ����߼�����
    // assign the response and read data of the AHB slave
    // To implement sram function-writing or reading in one cycle, value of hready_resp is always "1"
    assign  hready_resp = 1'b1;    //hready_resp��Ϊ1����֧�ַ�ѹ����Slave���ظ�Master����/д���ݿ���һ��ѭ�������
    assign  hresp       = 2'b00;   //00��ʾhrdata������OKAY����֧��ERROR��RETRY��SPLIT,ֻ����OKAY״̬

    // sram data output to AHB bus
    assign  hrdata = sram_data_out;  //��sram�洢��Ԫ������ݣ���hrdata������AHB���ߣ�֧��8/16/32bitλ

    // Generate sram write and read enable signals
    assign  sram_write = ((htrans_r == NONSEQ) || (htrans_r == SEQ)) && hwrite_r;
    assign  sram_read = ((htrans_r == NONSEQ) || (htrans_r == SEQ)) && (! hwrite_r);
    assign  sram_w_en = !sram_write;     //SRAMдʹ��Ϊ0������д��Ϊ1����������京���������߲�����sram_write�м��ź��෴


    // Generate sram address 
    // ϵͳ�߼���ַ(eg:CPU)�����Ŀռ��� 0 1 2 3 4 5 6 7 8 ...�����Ƿ��ʵ�ʱ������λ����32bit�����Է��ʵ�ַ������0 4 8 C��
    // ���Ƕ���SRAM����洢���������������Ŀռ���ʵ�ʵ������ַ��ÿ����ַ����32bit��ɵģ����Է��ʵ�ַ������:0 1 2 3
    assign  sram_addr = haddr_r[15:0];      //ϵͳ�ڴ�ռ䣺64K=2^6*2^10=2^16,��ϵͳ��ַ��16����ַ�����--ϵͳ��ַ
    //assign  sram_addr_out = sram_addr[14:2];//�����ַ=ϵͳ��ַ/4����������λ��64KB=8*8K*8bit��ÿһƬSRAM��ַ���Ϊ8K=2^13,��13����ַ�ߣ���ϸԭ��ο����ģ�
    assign  sram_addr_out = sram_addr[12:0];//�����ַ=ϵͳ��ַ/4����������λ��64KB=8*8K*8bit��ÿһƬSRAM��ַ���Ϊ8K=2^13,��13����ַ�ߣ���ϸԭ��ο����ģ�
    // Generate bank select signals by the value of sram_addr[15].
    // Each bank(32K*32��comprises of four sram block(8K*8), and the width of the address of the bank is
    // 15 bits(14-0),so the sram_addr[15] is the minimum of the next bank. if it is value is '1', it means 
    // the next bank is selected.
    assign sram_csn_en = (sram_write || sram_read); 

    // signals used to generating sram chip select signal in one bank.
    //assign  haddr_sel = sram_addr[1:0];    /*�޸�ǰ*/ 
    assign  haddr_sel = sram_addr[14:13];    /*�޸ĺ�*/ //ͨ��sram�ĵ�ַ����λ��hsize_r�ź��ж�ѡ��4Ƭsram�еľ�����һƬ
    assign  hsize_sel  = hsize_r[1:0];

    // data from AHB writing into sram.
    assign  sram_wdata =hwdata;   //��ͨ��AHB������д��sram�洢��Ԫ��

    /*�޸�ǰ*/
    //Ƭѡʹ��Ϊ1��sram_addr[15]Ϊ0����ʾѡ��bank0�������ٸ���sram_csnѡ��bank0��4��RAM��ĳ����RAM����ϸԭ��ο����ģ�
    //assign  bank0_csn = (sram_csn_en && (sram_addr[15] == 1'b0))?sram_csn:4'b1111;  //ϵͳ��ַ�����λΪsram_addr[15],�����жϷ���sram��bank0����bank1
    //assign  bank1_csn = (sram_csn_en && (sram_addr[15] == 1'b1))?sram_csn:4'b1111;  //sram_addr[15]=0 ����bank0��sram_addr[15]=1 ����bank1 ��Ϊ�Ǿ��ֵ�BANK
    //assign  bank_sel = (sram_csn_en && (sram_addr[15] == 1'b0))?1'b1:1'b0; //bank_selΪ1����bank0�����ʣ�bank_selΪ0����bank1������ 


    
    /*�޸ĺ�*///bank��cs����ѡ��
    always@(*)begin
        if(sram_csn_en)begin
            case(hsize_sel)
                2'b00:begin//8bit
                    bank0_csn = (sram_addr[15] == 1'b0)?sram_csn:4'b1111;
                    bank1_csn = (sram_addr[15] == 1'b1)?sram_csn:4'b1111;
                    bank_sel =  (sram_addr[15] == 1'b0)?1'b1:1'b0;
                end
                2'b01:begin                          
                    bank0_csn = (sram_addr[14] == 1'b0)?sram_csn:4'b1111;
                    bank1_csn = (sram_addr[14] == 1'b1)?sram_csn:4'b1111;
                    bank_sel =  (sram_addr[14] == 1'b0)?1'b1:1'b0;               
                end
                2'b10:begin                            
                    bank0_csn = (sram_addr[13] == 1'b0)?sram_csn:4'b1111;
                    bank1_csn = (sram_addr[13] == 1'b1)?sram_csn:4'b1111;
                    bank_sel =  (sram_addr[13] == 1'b0)?1'b1:1'b0;                
                end
                default:begin//Ĭ��32λ            
                    bank0_csn = (sram_addr[13] == 1'b0)?sram_csn:4'b1111;
                    bank1_csn = (sram_addr[13] == 1'b1)?sram_csn:4'b1111;
                    bank_sel =  (sram_addr[13] == 1'b0)?1'b1:1'b0;                 
                end
            endcase
        end
        else begin
            bank0_csn = 4'b1111;
            bank1_csn = 4'b1111;
            bank_sel  = 1'b1;
        end
    end
    
        
    // Choose the right data output of two banks(bank0,bank1) according to the value of bank_sel.
    
      /*�޸�ǰ*///If bank_sel = 1'b1, bank1 selected;or, bank0 selected.    
//    assign  sram_data_out = (bank_sel) ? {sram_q3,sram_q2,sram_q1,sram_q0}:         //��sram�������������ѡ��
//                                         {sram_q7,sram_q6,sram_q5,sram_q4};

    /*�޸�һ��*///��Ϊ�ɱ�����λ�������Ĭ�����Ϊ0    
//    /assign  sram_data_out = sram_read?//���sram�������sram�������������ѡ�����sram�Ƕ���sram���Ϊ0
//    ((bank_sel) ? ((hsize_sel==2'b10)?{sram_q3,sram_q2,sram_q1,sram_q0}:((hsize_sel==2'b01)?{16'd0,sram_q1,sram_q0}:{24'd0,sram_q0})):
//    ((hsize_sel==2'b10)?{sram_q7,sram_q6,sram_q5,sram_q4}:((hsize_sel==2'b01)?{16'd0,sram_q5,sram_q4}:{24'd0,sram_q4})))
//    :32'd0;

    /*�޸����հ�*///Ƭ���������sram_data_out 
    always@(*)begin
        if(!hresetn)begin
            sram_data_out = {32{SUB_DATA}};
        end
        else if(sram_read)begin
            if(bank_sel)begin
                case(hsize_sel)
                    2'b00:begin//data size 8bit
                        case(haddr_sel)
                            2'b00:sram_data_out = {{24{SUB_DATA}},sram_q0};
                            2'b01:sram_data_out = {{24{SUB_DATA}},sram_q1};
                            2'b10:sram_data_out = {{24{SUB_DATA}},sram_q2};
                            2'b11:sram_data_out = {{24{SUB_DATA}},sram_q3};
                        endcase
                    end
                    2'b01:begin//data size 16bit
                         case(haddr_sel[0])
                            1'b0:sram_data_out = {{16{SUB_DATA}},sram_q1,sram_q0};
                            1'b1:sram_data_out = {{16{SUB_DATA}},sram_q3,sram_q2};
                        endcase                   
                     
                    end
                    2'b10:sram_data_out = {sram_q3,sram_q2,sram_q1,sram_q0};//data size 32bit
                    default:begin 
                          sram_data_out = {sram_q3,sram_q2,sram_q1,sram_q0};//data size 32bit                  
                    end
                endcase
            end
            else begin
                 case(hsize_sel)
                    2'b00:begin//data size 8bit
                        case(haddr_sel)
                            2'b00:sram_data_out = {{24{SUB_DATA}},sram_q4};
                            2'b01:sram_data_out = {{24{SUB_DATA}},sram_q5};
                            2'b10:sram_data_out = {{24{SUB_DATA}},sram_q6};
                            2'b11:sram_data_out = {{24{SUB_DATA}},sram_q7};
                        endcase
                    end
                    2'b01:begin//data size 16bit
                         case(haddr_sel[0])
                            1'b0:sram_data_out = {{16{SUB_DATA}},sram_q5,sram_q4};
                            1'b1:sram_data_out = {{16{SUB_DATA}},sram_q7,sram_q6};
                        endcase                   
                     
                    end
                    2'b10:sram_data_out = {sram_q7,sram_q6,sram_q5,sram_q4};//data size 32bit
                    default:begin 
                          sram_data_out = {sram_q7,sram_q6,sram_q5,sram_q4};//data size 32bit                   
                   end
                endcase           
            end
        end
        else begin
            sram_data_out = sram_data_out;
        end
    end


// Generate the sram chip selecting signals in one bank.
// results show the AHB bus write or read how many data once a time:byte(8),halfword(16) or word(32).
    always@(*) begin
    //always@(*) begin
        if(hsize_sel == 2'b10)            //32bits:word operation��4Ƭsram������з���
          sram_csn = 4'b0;                //active low��sram_csn�źŵ���Ч��4'b0000����4ƬSRAM����ѡ��
        else if(hsize_sel == 2'b01)       //16bits:halfword��ѡ��4Ƭ�е�������Ƭ��ǰ��Ƭ���ߺ���Ƭ��
          begin
            //if(haddr_sel[1] == 1'b0)      /*�޸�ǰ*/ //low halfword������ַ�ĵ���λΪ00������ʵ�16λ����Ϊ10������ʸ�16λ����ϸԭ��ο����ģ�
            if(haddr_sel[0] == 1'b0)        /*�޸ĺ�*/
              sram_csn = 4'b1100;         //���ʵ���ƬSRAM����16bit��
            else                          //high halfword
              sram_csn = 4'b0011;         //���ʸ���ƬSRAM����16bit��
          end
        else if(hsize_sel == 2'b00)       //8bits:byte������4Ƭsram�е�һƬ
          begin
            case(haddr_sel)
              2'b00:sram_csn = 4'b1110;    //�������Ҳ��sram
              2'b01:sram_csn = 4'b1101;    //�������Ҳ���ߵ�һƬsram
              2'b10:sram_csn = 4'b1011;    //����������ұߵ�һƬsram
              2'b11:sram_csn = 4'b0111;    //����������sram
            endcase
          end
        else
          sram_csn = 4'b0;      //Ĭ��32bit����λ��
    end

// Sequential portion,     ʱ���߼�����(SRAM ��ַ������Ҫ���룬���Խ�AHB����תһ��)
// tmp the ahb address and control signals
    always@(posedge hclk or negedge hresetn) begin
        if(!hresetn)
          begin
            hwrite_r <= 1'b0;
            hsize_r  <= 3'b0;
            hburst_r <= 3'b0;         
            htrans_r <= 2'b0;
            haddr_r  <= 32'b0;
          end
        else if(hsel && hready)
          begin
            hwrite_r <= hwrite;
            hsize_r  <= hsize;       //����sram�ĵ�ַ��������ͬһ�ģ�������Ҫ��AH����
            hburst_r <= hburst;      //��ַ�Ϳ����źżĴ�һ�ģ�ʹ�������ݶ���
            htrans_r <= htrans;
            haddr_r  <= haddr;
          end
        else
          begin
            hwrite_r <= 1'b0;
            hsize_r  <= 3'b0;
            hburst_r <= 3'b0;         
            htrans_r <= 2'b0;
            haddr_r  <= 32'b0;
          end
    end

endmodule
