`include "define.sv"
`ifndef WRITE_SRAMC_DRIVER__SV
`define WRITE_SRAMC_DRIVER__SV
class write_sramc_driver extends uvm_driver#(my_transaction);

  virtual my_if wr_if;
  int i=`START_ADDR;
  //logic no_tr = 1'b0;

  `uvm_component_utils(write_sramc_driver)
  function new(string name = "write_sramc_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual my_if)::get(this, "", "wr_if", wr_if))
      `uvm_fatal("write_sramc_driver", "virtual interface must be set for my_if!!!")
  endfunction
  	
  extern task reset_phase(uvm_phase phase);
      
  extern task main_phase(uvm_phase phase);
  extern task ahb_init();
  extern task write_data(my_transaction tr);
  //extern task write_data_noseq(my_transaction tr);
    
  extern task drive_one_pkt(my_transaction tr);
  extern task drive_nothing();
endclass

task write_sramc_driver::reset_phase(uvm_phase phase);//init
  super.reset_phase(phase);
  wr_if.hsel   <= `NOSEL  ;//NOSEL:未中该slave、SEL:选中该slave
  wr_if.hwrite <= `WR_EN  ;//WR_EN:写、RD_EN:读
  wr_if.htrans <= `TRANS  ;//TRANS/NOTRANS eanble/disable transmit
  wr_if.hsize  <= `SIZE16 ;//SIZE8:8bit、SIZE16:16bit、SIZE32:32bit
  wr_if.hburst <= `BURST  ;//BURST
  wr_if.hready <= `READY  ;//READY or NOREADY
  wr_if.haddr  <= 32'd0;
  wr_if.hwdata <= 32'd0;
endtask
    
    
task write_sramc_driver::main_phase(uvm_phase phase);
   super.main_phase(phase);
   while(!wr_if.hresetn)
     @(posedge wr_if.hclk);
   fork
       while(1) begin
          seq_item_port.get_next_item(req);
          drive_one_pkt(req);
          i++;
          seq_item_port.item_done();
       end
   join
endtask

task write_sramc_driver::ahb_init();  
  wr_if.hsel   <= `NOSEL ;//未中该slave
endtask       

task write_sramc_driver::write_data(my_transaction tr);
  @(posedge wr_if.hclk);
  wr_if.hsel   <= `SEL   ;//未中该slave
  wr_if.hwrite <= `WR_EN ;//写
  wr_if.haddr  <=  i; 
  @(posedge wr_if.hclk);
  wr_if.hwdata <= tr.data;//[`DSIZE-1:0]
  
endtask     
     
    
// task write_sramc_driver::write_data_noseq(my_transaction tr);
//     //#(tr.delay);
//     @(posedge wr_if.hclk);
//     wr_if.hsel   <= `SEL ;//选中该slave
//     wr_if.hwrite <= `WR_EN ;//写
//     wr_if.haddr  <=  i; 
//   	wr_if.hwdata <= tr.data;//[`DSIZE-1:0]
//     //`uvm_info("write_sramc_driver", $sformatf("write_data_noseq data:%0d",tr.data), UVM_LOW);
//     @(posedge wr_if.hclk);
//     //wr_if.hwdata <= tr.data;//[`DSIZE-1:0]
//     //@(posedge wr_if.hclk);
//     ahb_init();

// endtask      
    
task write_sramc_driver::drive_one_pkt(my_transaction tr);
  //`uvm_info("write_sramc_driver", "begin to drive one pkt", UVM_LOW);
  
  while(!wr_if.hresetn)
    @(posedge wr_if.hclk);  
  while(1) begin
    if(((`TRANS)==2'b10)|((`TRANS)==2'b11))begin
      //write_data_seq(tr);
      write_data(tr);
      break;
    end
    else
      ahb_init();
  end
  
  //`uvm_info("write_sramc_driver", "end drive one pkt", UVM_LOW);

endtask
    


`endif
