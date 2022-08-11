`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/17 16:54:29
// Design Name: 
// Module Name: RA1SH
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


`celldefine
module RA1SH ( //8K
   Q,          //data_out [7:0]
   CLK,        //ʱ�� hclk ȡ��
   CEN,        //chip select ����Ч
   WEN,        //��дʹ�ܡ�// дʹ�ܣ�����Ч
   A,          //��д��ַ [12:0]
   D,          //data_in [7:0]
   OEN         //
);
   parameter		   BITS = 8; // ����λ�� 8 bit
   parameter		   word_depth = 8192; // 8K = 8 x 1024
   parameter		   addr_width = 13;
   parameter		   wordx = {BITS{1'bx}}; // x ̬
   parameter		   addrx = {addr_width{1'bx}};
	
   output [BITS-1:0] Q;
   input CLK;
   input CEN;
   input WEN;
   input [addr_width-1:0] A;
   input [BITS-1:0] D;
   input OEN;

   reg [BITS-1:0]	   mem [word_depth-1:0]; // SRAM ����Ϊ�����Ͼ���һ���������Ϊ [word_depth-1:0]Ϊ���  [BITS-1:0]Ϊ���

   reg			           NOT_CEN; // NOT ��ʾȡ�� Ϊʲôȡ������Ϊ�����л��õ�һЩBUFFER
   reg			           NOT_WEN;

   reg			           NOT_A0;
   reg			           NOT_A1;
   reg			           NOT_A2;
   reg			           NOT_A3;
   reg			           NOT_A4;
   reg			           NOT_A5;
   reg			           NOT_A6;
   reg			           NOT_A7;
   reg			           NOT_A8;
   reg			           NOT_A9;
   reg			           NOT_A10;
   reg			           NOT_A11;
   reg			           NOT_A12;
   reg [addr_width-1:0]	   NOT_A;
   reg			           NOT_D0;
   reg			           NOT_D1;
   reg			           NOT_D2;
   reg			           NOT_D3;
   reg			           NOT_D4;
   reg			           NOT_D5;
   reg			           NOT_D6;
   reg			           NOT_D7;
   reg [BITS-1:0]	       NOT_D ;
   reg			           NOT_CLK_PER;
   reg			           NOT_CLK_MINH;
   reg			           NOT_CLK_MINL;

   reg			           LAST_NOT_CEN;
   reg			           LAST_NOT_WEN;
   reg [addr_width-1:0]    LAST_NOT_A;
   reg [BITS-1:0]	       LAST_NOT_D;
   reg			           LAST_NOT_CLK_PER;
   reg			           LAST_NOT_CLK_MINH;
   reg			           LAST_NOT_CLK_MINL;


   wire [BITS-1:0]         _Q;
   wire			           _OENi;
   wire [addr_width-1:0]   _A;
   wire			           _CLK;
   wire			           _CEN;
   wire			           _OEN;
   wire                    _WEN;

   wire [BITS-1:0]   _D;
   wire                    re_flag;
   wire                    re_data_flag;


   reg			           LATCHED_CEN;
   reg	                   LATCHED_WEN;
   reg [addr_width-1:0]	   LATCHED_A;
   reg [BITS-1:0]	       LATCHED_D;

   reg			           CENi;
   reg           	       WENi;
   reg [addr_width-1:0]	   Ai;
   reg [BITS-1:0]	       Di;
   reg [BITS-1:0]	       Qi;
   reg [BITS-1:0]	       LAST_Qi;

   reg			           LAST_CLK;

task update_notifier_buses;
begin
    NOT_A = {
             NOT_A12,
             NOT_A11,
             NOT_A10,
             NOT_A9,
             NOT_A8,
             NOT_A7,
             NOT_A6,
             NOT_A5,
             NOT_A4,
             NOT_A3,
             NOT_A2,
             NOT_A1,
             NOT_A0};
    NOT_D = {
             NOT_D7,
             NOT_D6,
             NOT_D5,
             NOT_D4,
             NOT_D3,
             NOT_D2,
             NOT_D1,
             NOT_D0};
end
endtask

task mem_cycle;
begin
    casez({WENi,CENi})//WENi 0:д��1:��   CENi:Ƭѡ(����Ч)
        2'b10: begin//��״̬
            read_mem(1,0);//���������
        end
        2'b00: begin//д״̬
            write_mem(Ai,Di);//д������
            read_mem(0,0);//��д��������ʾ�ڶ��������
        end
        2'b?1: ;
        2'b1x: begin
            read_mem(0,1);  //��������̬����
        end
        2'bx0: begin
            write_mem_x(Ai);//д�벻��̬����
            read_mem(0,1);  //��������̬����
        end
        2'b0x,
        2'bxx: begin
            write_mem_x(Ai);//д�벻��̬����
            read_mem(0,1);  //��������̬����
        end
    endcase
end
endtask
      

task update_last_notifiers;
begin
    LAST_NOT_A = NOT_A;
    LAST_NOT_D = NOT_D;
    LAST_NOT_WEN = NOT_WEN;
    LAST_NOT_CEN = NOT_CEN;
    LAST_NOT_CLK_PER = NOT_CLK_PER;
    LAST_NOT_CLK_MINH = NOT_CLK_MINH;
    LAST_NOT_CLK_MINL = NOT_CLK_MINL;
end
endtask

task latch_inputs;
begin
    LATCHED_A = _A ;
    LATCHED_D = _D ;
    LATCHED_WEN = _WEN ;
    LATCHED_CEN = _CEN ;
    LAST_Qi = Qi;
end
endtask


task update_logic;
begin
    CENi = LATCHED_CEN;
    WENi = LATCHED_WEN;
    Ai = LATCHED_A;
    Di = LATCHED_D;
end
endtask



task x_inputs;
    integer n;
begin
    for (n=0; n<addr_width; n=n+1)begin
        LATCHED_A[n] = (NOT_A[n]!==LAST_NOT_A[n]) ? 1'bx : LATCHED_A[n] ;
    end
    for (n=0; n<BITS; n=n+1)begin
        LATCHED_D[n] = (NOT_D[n]!==LAST_NOT_D[n]) ? 1'bx : LATCHED_D[n] ;
    end
    LATCHED_WEN = (NOT_WEN!==LAST_NOT_WEN) ? 1'bx : LATCHED_WEN ;
    LATCHED_CEN = (NOT_CEN!==LAST_NOT_CEN) ? 1'bx : LATCHED_CEN ;
end
endtask

task read_mem;
    input r_wb;
    input xflag;
begin
    if (r_wb)begin
        if (valid_address(Ai))begin
            Qi=mem[Ai];
        end
        else begin
            Qi=wordx;
        end
    end
    else begin
        if (xflag)begin
            Qi=wordx;
        end
        else begin
            Qi=Di;
        end
    end
end
endtask

task write_mem;
    input [addr_width-1:0] a;
    input [BITS-1:0] d;
begin
    casez({valid_address(a)})
        1'b0:x_mem;
        1'b1: mem[a]=d;
    endcase
end
endtask

task write_mem_x;
    input [addr_width-1:0] a;
begin
    casez({valid_address(a)})//����ַ�Ƿ���Ч
        1'b0:x_mem;        
        1'b1: mem[a]=wordx;
    endcase
end
endtask

task x_mem;
    integer n;
begin
    for (n=0; n<word_depth; n=n+1)
        mem[n]=wordx;
end
endtask

task process_violations;//������
begin
    if ((NOT_CLK_PER!==LAST_NOT_CLK_PER) ||
    (NOT_CLK_MINH!==LAST_NOT_CLK_MINH) ||
    (NOT_CLK_MINL!==LAST_NOT_CLK_MINL))begin
        if (CENi !== 1'b1)begin
            x_mem;
            read_mem(0,1);
        end
    end
    else begin
        update_notifier_buses;
        x_inputs;
        update_logic;
        mem_cycle;
    end
    update_last_notifiers;
end
endtask

function valid_address;
  input [addr_width-1:0] a;
begin
  valid_address = (^(a) !== 1'bx);
end
endfunction


bufif0 (Q[0], _Q[0], _OENi);//��̬��bufif0(out, in, ctrl)enable-->ctrl=0
bufif0 (Q[1], _Q[1], _OENi);//��̬��bufif1(out, in, ctrl)enable-->ctrl=1
bufif0 (Q[2], _Q[2], _OENi);
bufif0 (Q[3], _Q[3], _OENi);
bufif0 (Q[4], _Q[4], _OENi);
bufif0 (Q[5], _Q[5], _OENi);
bufif0 (Q[6], _Q[6], _OENi);
bufif0 (Q[7], _Q[7], _OENi);
buf (_D[0], D[0]);//�������buf(out1, out2,..., in);�����ж���������ֻ��һ������
buf (_D[1], D[1]);
buf (_D[2], D[2]);
buf (_D[3], D[3]);
buf (_D[4], D[4]);
buf (_D[5], D[5]);
buf (_D[6], D[6]);
buf (_D[7], D[7]);
buf (_A[0], A[0]);
buf (_A[1], A[1]);
buf (_A[2], A[2]);
buf (_A[3], A[3]);
buf (_A[4], A[4]);
buf (_A[5], A[5]);
buf (_A[6], A[6]);
buf (_A[7], A[7]);
buf (_A[8], A[8]);
buf (_A[9], A[9]);
buf (_A[10], A[10]);
buf (_A[11], A[11]);
buf (_A[12], A[12]);
buf (_CLK, CLK);
buf (_WEN, WEN);
buf (_OEN, OEN);
buf (_CEN, CEN);


assign _OENi = _OEN;
assign _Q = Qi;
assign re_flag = !(_CEN);
assign re_data_flag = !(_CEN || _WEN);


always @( // Verilog 95 �﷨
	    NOT_A0 or // 13λ��ַ��8λ���ݷ�Ϊ��bit���ź� (д����ģ�͵�һ�����)
	    NOT_A1 or
	    NOT_A2 or
	    NOT_A3 or
	    NOT_A4 or
	    NOT_A5 or
	    NOT_A6 or
	    NOT_A7 or
	    NOT_A8 or
	    NOT_A9 or
	    NOT_A10 or
	    NOT_A11 or
	    NOT_A12 or
	    NOT_D0 or
	    NOT_D1 or
	    NOT_D2 or
	    NOT_D3 or
	    NOT_D4 or
	    NOT_D5 or
	    NOT_D6 or
	    NOT_D7 or
	    NOT_WEN or
	    NOT_CEN or
	    NOT_CLK_PER or
	    NOT_CLK_MINH or
	    NOT_CLK_MINL
	    )begin
         process_violations; // ʱ�����㣬����ǰ�˷���һ�㲻��ȥ��ʱ��ֻ�ܹ��ܣ�
end

always@( _CLK )begin // ʱ�Ӽ�� 
    casez({LAST_CLK,_CLK})
	   2'b01: begin
	      latch_inputs;
	      update_logic;
	      mem_cycle;
	   end
	   2'b10,
	   2'bx?,
	   2'b00,
	   2'b11: ;
	   2'b?x: begin
	      x_mem;
          read_mem(0,1);
	   end
	 endcase
	 LAST_CLK = _CLK;
end

specify //·���ӳٿ�
      $setuphold(posedge CLK, CEN, 1.000, 0.500, NOT_CEN); //  $setuphold ��� setup �� hpld ��ϵͳ��������������һ��Ὣ��ر�
      $setuphold(posedge CLK &&& re_flag, WEN, 1.000, 0.500, NOT_WEN);
      $setuphold(posedge CLK &&& re_flag, A[0], 1.000, 0.500, NOT_A0);
      $setuphold(posedge CLK &&& re_flag, A[1], 1.000, 0.500, NOT_A1);
      $setuphold(posedge CLK &&& re_flag, A[2], 1.000, 0.500, NOT_A2);
      $setuphold(posedge CLK &&& re_flag, A[3], 1.000, 0.500, NOT_A3);
      $setuphold(posedge CLK &&& re_flag, A[4], 1.000, 0.500, NOT_A4);
      $setuphold(posedge CLK &&& re_flag, A[5], 1.000, 0.500, NOT_A5);
      $setuphold(posedge CLK &&& re_flag, A[6], 1.000, 0.500, NOT_A6);
      $setuphold(posedge CLK &&& re_flag, A[7], 1.000, 0.500, NOT_A7);
      $setuphold(posedge CLK &&& re_flag, A[8], 1.000, 0.500, NOT_A8);
      $setuphold(posedge CLK &&& re_flag, A[9], 1.000, 0.500, NOT_A9);
      $setuphold(posedge CLK &&& re_flag, A[10], 1.000, 0.500, NOT_A10);
      $setuphold(posedge CLK &&& re_flag, A[11], 1.000, 0.500, NOT_A11);
      $setuphold(posedge CLK &&& re_data_flag, D[0], 1.000, 0.500, NOT_D0);
      $setuphold(posedge CLK &&& re_data_flag, D[1], 1.000, 0.500, NOT_D1);
      $setuphold(posedge CLK &&& re_data_flag, D[2], 1.000, 0.500, NOT_D2);
      $setuphold(posedge CLK &&& re_data_flag, D[3], 1.000, 0.500, NOT_D3);
      $setuphold(posedge CLK &&& re_data_flag, D[4], 1.000, 0.500, NOT_D4);
      $setuphold(posedge CLK &&& re_data_flag, D[5], 1.000, 0.500, NOT_D5);
      $setuphold(posedge CLK &&& re_data_flag, D[6], 1.000, 0.500, NOT_D6);
      $setuphold(posedge CLK &&& re_data_flag, D[7], 1.000, 0.500, NOT_D7);
    
      $period(posedge CLK, 3.000, NOT_CLK_PER);
      $width(posedge CLK, 1.000, 0, NOT_CLK_MINH);
      $width(negedge CLK, 1.000, 0, NOT_CLK_MINL);
       /////////////////////////////////////////////////////////////////////////
	   //��·����ʱ�п���˵��6����ʱֵ(0->1, 1->0, 0->Z, Z->1, 1->Z, Z->0)
	   //��·����ʱ��˵������12����ʱֵ(0->1, 1->0, 0->Z, Z->1, 1->Z, Z->0, 0->X, X->1, 1->X, X->0, X->Z, Z->X)
	   //
	   //������ʱ�����ת��Ϊ1ʱ����ʱ(0->1,Z->1,X->1)
	   //�½���ʱ�����ת��Ϊ0ʱ����ʱ(1->0,Z->0,X->0)
	   //�ض���ʱ���ת��Ϊ��̬Zʱ����ʱ(0->Z,1->Z,X->Z,)
	   //��X��ת����ʱ����С��ʱ������X������ֵ��ת��ʹ���(��)��ʱ
	   //
	   //���ֻ˵����һ����ʱ��������ת��ʹ�������ʱ��
	   //���ֻ˵�����������½���ʱ���� 1->X �� X->0 ʹ���½���ʱ�� X->Z ʹ���������½���ʱ����С��ʱ
	   //���˵����������ʱ���� 1->X ʹ�� 1->X �� 1->Z ����С��ʱ�� X->0 ʹ�� 1->0 �� X->0 �������ʱ�� X->Z ʹ�� 1->Z �� 0->Z �е������ʱ��
	   ////////////////////////////////////////////////////////////////////////////
      (CLK => Q[0])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[1])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[2])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[3])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[4])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[5])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[6])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[7])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (OEN => Q[0])=(1.000, 1.000, 1.000, 1.000, 1.000, 1.000);
      (OEN => Q[1])=(1.000, 1.000, 1.000, 1.000, 1.000, 1.000);
      (OEN => Q[2])=(1.000, 1.000, 1.000, 1.000, 1.000, 1.000);
      (OEN => Q[3])=(1.000, 1.000, 1.000, 1.000, 1.000, 1.000);
      (OEN => Q[4])=(1.000, 1.000, 1.000, 1.000, 1.000, 1.000);
      (OEN => Q[5])=(1.000, 1.000, 1.000, 1.000, 1.000, 1.000);
      (OEN => Q[6])=(1.000, 1.000, 1.000, 1.000, 1.000, 1.000);
      (OEN => Q[7])=(1.000, 1.000, 1.000, 1.000, 1.000, 1.000);
endspecify 

endmodule
`endcelldefine

