`ifndef READ_SRAMC_AGENT__SV
`define READ_SRAMC_AGENT__SV

class read_sramc_agent extends uvm_agent ;
  read_sramc_sequencer  sqr;
  read_sramc_monitor    mon;
  read_sramc_driver     drv;

  uvm_analysis_port #(my_transaction)  ap;

  function new(string name="read_sramc_agent", uvm_component parent);
    super.new(name, parent);
  endfunction 

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

  `uvm_component_utils(read_sramc_agent)
endclass 


function void read_sramc_agent::build_phase(uvm_phase phase);
   super.build_phase(phase);
   sqr = read_sramc_sequencer::type_id::create("sqr", this);
   mon = read_sramc_monitor::type_id::create("mon", this);
   drv = read_sramc_driver::type_id::create("drv", this);
endfunction 

function void read_sramc_agent::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   drv.seq_item_port.connect(sqr.seq_item_export);
   ap = mon.ap;
endfunction

`endif

