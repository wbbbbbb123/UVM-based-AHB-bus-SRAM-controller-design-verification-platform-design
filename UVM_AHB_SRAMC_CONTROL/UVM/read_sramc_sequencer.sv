`ifndef READ_SRAMC_SEQUENCER__SV
`define READ_SRAMC_SEQUENCER__SV

class read_sramc_sequencer extends uvm_sequencer #(read_sramc_transaction);
   
   function new(string name = "read_sramc_sequencer", uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(read_sramc_sequencer)
endclass

`endif