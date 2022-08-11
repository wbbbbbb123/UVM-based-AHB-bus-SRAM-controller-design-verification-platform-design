`ifndef MY_VIRTUAL_SEQUENCER__SV
`define MY_VIRTUAL_SEQUENCER__SV

class my_virtual_sequencer extends uvm_sequencer;
   //Declaration.
   write_sramc_sequencer m_wr_seqr;
   read_sramc_sequencer  m_rd_seqr;
   
   function new(string name = "my_virtual_sequencer", uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(my_virtual_sequencer)
endclass

`endif