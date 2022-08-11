`ifndef WRITE_SRAMC_MONITOR__SV
`define WRITE_SRAMC_MONITOR__SV
class write_sramc_monitor extends uvm_monitor;

  virtual my_if wr_if;

  uvm_analysis_port #(my_transaction)  ap;

  `uvm_component_utils(write_sramc_monitor)
  function new(string name = "write_sramc_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual my_if)::get(this, "", "wr_if", wr_if))
      `uvm_fatal("write_sramc_monitor", "virtual interface must be set for wr_if!!!")
      ap = new("ap", this);
  endfunction

  extern task main_phase(uvm_phase phase);
  extern task collect_one_pkt(my_transaction tr);
endclass

task write_sramc_monitor::main_phase(uvm_phase phase);
   my_transaction tr;
   while(1) begin
      tr = new("tr");
      collect_one_pkt(tr);
      //`uvm_info("write_sramc_monitor", $sformatf("write_data_seq data:%0d",tr.data), UVM_LOW);
      ap.write(tr);
   end
endtask

task write_sramc_monitor::collect_one_pkt(my_transaction tr);
   
   while(1) begin
     @(posedge wr_if.hclk);
     if(wr_if.hwrite&wr_if.hsel) 
       break;
   end
   
   //`uvm_info("write_sramc_monitor", "begin to collect one pkt", UVM_MEDIUM);
   @(posedge wr_if.hclk);
   tr.data = wr_if.hwdata;

   //`uvm_info("write_sramc_monitor", "end collect one pkt", UVM_MEDIUM);
endtask


`endif
