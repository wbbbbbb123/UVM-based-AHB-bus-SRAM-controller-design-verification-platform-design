`include "define.sv"
`ifndef MY_TRANSACTION__SV
`define MY_TRANSACTION__SV

class my_transaction extends uvm_sequence_item;

  rand bit[`DSIZE-1:0] data;

  
  `uvm_object_utils_begin(my_transaction)
  `uvm_field_int(data, UVM_ALL_ON)
  `uvm_object_utils_end
	
  
  function new(string name = "my_transaction");
    super.new();
  endfunction

endclass
`endif