`ifndef READ_SRAMC_MONITOR__SV
`define READ_SRAMC_MONITOR__SV
class read_sramc_monitor extends uvm_monitor;

  virtual my_if rd_if;

  uvm_analysis_port #(my_transaction)  ap;

  `uvm_component_utils(read_sramc_monitor)
  function new(string name = "read_sramc_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual my_if)::get(this, "", "rd_if", rd_if))
      `uvm_fatal("read_sramc_monitor", "virtual interface must be set for rd_if!!!")
      ap = new("ap", this);
  endfunction

  extern task main_phase(uvm_phase phase);
  extern task collect_one_pkt(my_transaction tr);
endclass

task read_sramc_monitor::main_phase(uvm_phase phase);
   my_transaction tr;
   while(1) begin
      tr = new("tr");
      collect_one_pkt(tr);
      //`uvm_info("read_sramc_monitor", $sformatf("read_data_seq data:%0d",tr.data), UVM_LOW);
      ap.write(tr);
   end
endtask

task read_sramc_monitor::collect_one_pkt(my_transaction tr);
   
   while(1) begin
      @(posedge rd_if.hclk);
      if(~rd_if.hwrite&rd_if.hsel) 
        break;
   end
  @(posedge rd_if.hclk);
  tr.data = rd_if.hrdata;//读数据应该在读指令发出后的下一个时钟沿读，这里用延时代替
  
endtask


`endif
