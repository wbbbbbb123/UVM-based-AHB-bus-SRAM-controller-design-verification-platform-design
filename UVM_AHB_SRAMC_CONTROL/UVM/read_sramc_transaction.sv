`ifndef READ_SRAMC_TRANSACTION__SV
`define READ_SRAMC_TRANSACTION__SV

class read_sramc_transaction extends uvm_sequence_item;

   rand bit[`DSIZE-1:0] data;

   `uvm_object_utils_begin(read_sramc_transaction)
      `uvm_field_int(data, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "read_sramc_transaction");
      super.new();
   endfunction
  
endclass
`endif
