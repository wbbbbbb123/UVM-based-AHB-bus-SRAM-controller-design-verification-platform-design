`ifndef WRITE_SRAMC_AGENT__SV
`define WRITE_SRAMC_AGENT__SV

class write_sramc_agent extends uvm_agent ;
   write_sramc_sequencer  sqr;
   write_sramc_driver     drv;
   write_sramc_monitor    mon;
   
  uvm_analysis_port #(my_transaction)  ap;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);

   `uvm_component_utils(write_sramc_agent)
endclass 


function void write_sramc_agent::build_phase(uvm_phase phase);
   super.build_phase(phase);
   sqr = write_sramc_sequencer::type_id::create("sqr", this);
   drv = write_sramc_driver::type_id::create("drv", this);
   mon = write_sramc_monitor::type_id::create("mon", this);
endfunction 

function void write_sramc_agent::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   drv.seq_item_port.connect(sqr.seq_item_export);
   ap = mon.ap;
endfunction

`endif

