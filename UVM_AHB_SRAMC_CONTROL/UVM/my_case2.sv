`include "define.sv"
`ifndef MY_CASE2__SV
`define MY_CASE2__SV

class my_case2_sequence extends uvm_sequence;
    
    `uvm_object_utils(my_case2_sequence)
  `uvm_declare_p_sequencer(my_virtual_sequencer)
    
   function  new(string name= "my_case2_sequence");
      super.new(name);
   endfunction 
   
   extern virtual task body();
   extern virtual task pre_body();
   extern virtual task post_body();

endclass

task my_case2_sequence::body();
   write_sramc_seq wr_seq;
   read_sramc_seq  rd_seq;
  //write full
  repeat (2000) begin
    `uvm_do_on(wr_seq,p_sequencer.m_wr_seqr)
  end  
  //read empty
  repeat (2000) begin
    `uvm_do_on(rd_seq,p_sequencer.m_rd_seqr)
  end   
  #(2*(`HCLK_PERIOD));;
  `uvm_info("my_case2", "body finished", UVM_MEDIUM)
endtask

task my_case2_sequence::pre_body();
    if(starting_phase != null) begin 
        starting_phase.raise_objection(this);
    end
endtask

task my_case2_sequence::post_body();
  `uvm_info("my_case2", "Entering post_body", UVM_MEDIUM)
    if(starting_phase != null) begin 
      `uvm_info("my_case2", "starting_pase is drop", UVM_MEDIUM)
        starting_phase.drop_objection(this);
    end
endtask


class my_case2 extends base_test;

  function new(string name = "my_case2", uvm_component parent = null);
      super.new(name,parent);
   endfunction 
   extern virtual function void build_phase(uvm_phase phase); 
   extern task main_phase(uvm_phase phase); 
     `uvm_component_utils(my_case2)
endclass


function void my_case2::build_phase(uvm_phase phase);
   super.build_phase(phase);

   uvm_config_db#(uvm_object_wrapper)::set(this, 
                                           "env.m_vseqr.main_phase", 
                                           "default_sequence", 
                                           my_case2_sequence::type_id::get());
endfunction
task my_case2::main_phase(uvm_phase phase);
  
  super.main_phase(phase);
  uvm_top.print_topology();
endtask
`endif