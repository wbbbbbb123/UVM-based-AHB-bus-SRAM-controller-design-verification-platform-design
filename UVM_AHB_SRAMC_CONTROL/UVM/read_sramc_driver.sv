`ifndef READ_SRAMC_DRIVER__SV
`define READ_SRAMC_DRIVER__SV
class read_sramc_driver extends uvm_driver#(read_sramc_transaction);

  virtual my_if rd_if;
  int i=`START_ADDR;

  `uvm_component_utils(read_sramc_driver)
  function new(string name = "read_sramc_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual my_if)::get(this, "", "rd_if", rd_if))
      `uvm_fatal("read_sramc_driver", "virtual interface must be set for rd_if!!!")
  endfunction
  extern task reset_phase(uvm_phase phase);
  extern task main_phase(uvm_phase phase);
  extern task ahb_init();
  extern task read_data(read_sramc_transaction tr);  
  //extern task read_data_noseq(read_sramc_transaction tr);
    
  extern task drive_one_pkt(read_sramc_transaction tr);
  extern task drive_nothing();
endclass

task read_sramc_driver::reset_phase(uvm_phase phase);//init
  super.reset_phase(phase);
  rd_if.hsel   <= `NOSEL  ;//NOSEL:未中该slave、SEL:选中该slave
  rd_if.hwrite <= `WR_EN  ;//WR_EN:写 RD_EN:读
  rd_if.htrans <= `TRANS  ;//10or11 enable transmit
  rd_if.hsize  <= `SIZE16 ;//SIZE8:8bit、SIZE16:16bit、SIZE32:32bit
  rd_if.hburst <= `BURST  ;
  rd_if.hready <= `READY  ;
  rd_if.haddr  <= 32'd0   ;
endtask    
    
    
task read_sramc_driver::main_phase(uvm_phase phase);
  super.main_phase(phase);
  while(!rd_if.hresetn)
    @(posedge rd_if.hclk);
  fork
    while(1) begin
      seq_item_port.get_next_item(req);
      drive_one_pkt(req);
      i++;
      seq_item_port.item_done();
    end
  join

endtask

task read_sramc_driver::ahb_init();  
  rd_if.hsel   <= `NOSEL ;//未中该slave
endtask     
  
task read_sramc_driver::read_data(read_sramc_transaction tr);//连续读
    @(posedge rd_if.sram_clk);
    rd_if.hsel   <= `SEL   ;//选中该slave
    rd_if.hwrite <= `RD_EN ;//读
    rd_if.haddr  <=  i; 
    @(posedge rd_if.sram_clk);
    rd_if.hsel   <= `NOSEL ;//未选中该slave
endtask     
    
// task read_sramc_driver::read_data_noseq(read_sramc_transaction tr);
//     @(posedge rd_if.hclk);
//     rd_if.hsel   <= `SEL ;//选中该slave
//     rd_if.hwrite <= `RD_EN ;//读
//     rd_if.haddr  <=  i; 
//     @(posedge rd_if.hclk);
//     ahb_init();
// endtask   
    
    
task read_sramc_driver::drive_one_pkt(read_sramc_transaction tr);
  //`uvm_info("read_sramc_driver", "begin to drive one pkt", UVM_LOW);
  //$display("read addr is %0d",i);
  while(!rd_if.hresetn)
    @(posedge rd_if.hclk);
  while(1)begin
    if(((`TRANS)==2'b10)|((`TRANS)==2'b11))begin//transmit enable
      //read_data_seq(tr);
      read_data(tr);
      break;
    end
    else
      ahb_init();
  end
  //`uvm_info("read_sramc_driver", "end to drive one pkt", UVM_LOW);
endtask

    
    

`endif
