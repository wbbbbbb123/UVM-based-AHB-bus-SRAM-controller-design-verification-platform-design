# UVM-based-AHB-bus-SRAM-controller-design-verification-platform-design
## UVM testbench topology

------------------------------------------------------------------
Name                       Type                        Size  Value

------------------------------------------------------------------
uvm_test_top               my_case2                    -     @457 

  env                      my_env                      -     @473 
  
    agt_mdl_fifo           uvm_tlm_analysis_fifo #(T)  -     @693 
      analysis_export      uvm_analysis_imp            -     @737 
      get_ap               uvm_analysis_port           -     @728 
      get_peek_export      uvm_get_peek_imp            -     @710 
      put_ap               uvm_analysis_port           -     @719 
      put_export           uvm_put_imp                 -     @701 
    agt_scb_fifo           uvm_tlm_analysis_fifo #(T)  -     @640 
      analysis_export      uvm_analysis_imp            -     @684 
      get_ap               uvm_analysis_port           -     @675 
      get_peek_export      uvm_get_peek_imp            -     @657 
      put_ap               uvm_analysis_port           -     @666 
      put_export           uvm_put_imp                 -     @648 
    i_agt                  write_sramc_agent           -     @485 
      drv                  write_sramc_driver          -     @926 
        rsp_port           uvm_analysis_port           -     @943 
        seq_item_port      uvm_seq_item_pull_port      -     @934 
      mon                  write_sramc_monitor         -     @952 
        ap                 uvm_analysis_port           -     @962 
      sqr                  write_sramc_sequencer       -     @803 
        rsp_export         uvm_analysis_export         -     @811 
        seq_item_export    uvm_seq_item_pull_imp       -     @917 
        arbitration_queue  array                       0     -    
        lock_queue         array                       0     -    
        num_last_reqs      integral                    32    'd1  
        num_last_rsps      integral                    32    'd1  
    m_vseqr                my_virtual_sequencer        -     @517 
      rsp_export           uvm_analysis_export         -     @525 
      seq_item_export      uvm_seq_item_pull_imp       -     @631 
      arbitration_queue    array                       0     -    
      lock_queue           array                       0     -    
      num_last_reqs        integral                    32    'd1  
      num_last_rsps        integral                    32    'd1  
    mdl                    my_model                    -     @501 
      ap                   uvm_analysis_port           -     @990 
      port                 uvm_blocking_get_port       -     @981 
    mdl_scb_fifo           uvm_tlm_analysis_fifo #(T)  -     @746 
      analysis_export      uvm_analysis_imp            -     @790 
      get_ap               uvm_analysis_port           -     @781 
      get_peek_export      uvm_get_peek_imp            -     @763 
      put_ap               uvm_analysis_port           -     @772 
      put_export           uvm_put_imp                 -     @754 
    o_agt                  read_sramc_agent            -     @493 
      drv                  read_sramc_driver           -     @1134
        rsp_port           uvm_analysis_port           -     @1151
        seq_item_port      uvm_seq_item_pull_port      -     @1142
      mon                  read_sramc_monitor          -     @1126
        ap                 uvm_analysis_port           -     @1162
      sqr                  read_sramc_sequencer        -     @1003
        rsp_export         uvm_analysis_export         -     @1011
        seq_item_export    uvm_seq_item_pull_imp       -     @1117
        arbitration_queue  array                       0     -    
        lock_queue         array                       0     -    
        num_last_reqs      integral                    32    'd1  
        num_last_rsps      integral                    32    'd1  
    scb                    my_scoreboard               -     @509 
      act_port             uvm_blocking_get_port       -     @1185
      exp_port             uvm_blocking_get_port       -     @1176
------------------------------------------------------------------
------------------------------------------------------------------
