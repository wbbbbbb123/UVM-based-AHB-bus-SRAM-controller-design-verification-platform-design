`ifndef WRITE_SRAMC_SEQUENCER__SV
`define WRITE_SRAMC_SEQUENCER__SV

class write_sramc_sequencer extends uvm_sequencer #(my_transaction);
   
   function new(string name = "write_sramc_sequencer", uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(write_sramc_sequencer)
endclass

`endif
