// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples


import uvm_pkg::*;
`include "uvm_macros.svh";

//transaction class------------------------------------------------------

class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)
  
  function new(string name="transaction");
    super.new(name);
  endfunction
  
  rand bit[3:0] x;
  rand bit[3:0] y;
  bit [7:0]p;
  
endclass




//Sequence class-------------------------------------------------------
class t_sequence extends uvm_sequence#(transaction);
  `uvm_object_utils(t_sequence)
   transaction trans;
  function new(string name="t_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    int t=0;
    repeat(256)
      begin
        t=t+1;
        $display("\n");
        $display("Start of New transaction==>%0d",t);
        
        trans=transaction::type_id::create("trans");
        
        wait_for_grant();
        
        trans.randomize();
        
        send_request(trans);
        
        wait_for_item_done();
      end
  endtask
  
endclass




//Sequencer class----------------------------------------------

class t_sequencer extends uvm_sequencer#(transaction);
  `uvm_component_utils(t_sequencer)
  
  function new(string name="t_sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass




//Driver class-------------------------------------------------
class t_driver extends uvm_driver#(transaction);
  `uvm_component_utils(t_driver)
  transaction trans;
  virtual IF if1;
  event next;
  
  uvm_analysis_port#(transaction) cov_port;
  
  
  function new(string name="t_driver",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual IF)::get(this,"","if1",if1))
      $display("error......");
   cov_port=new("cov_port",this); 
  endfunction
 
  
  virtual task run_phase(uvm_phase phase);
     forever
     begin
      seq_item_port.get_next_item(trans);
      cov_port.write(trans); 
      if1.x=trans.x;            //driving logic
      if1.y=trans.y;
     
      ->next;
       
      seq_item_port.item_done();
     end
  endtask
  
endclass


//Monitor class------------------------------------------------------------
class t_monitor extends uvm_monitor;
  `uvm_component_utils(t_monitor)
  transaction trans1;
  virtual IF if1;
  event next;
  
  uvm_blocking_put_port#(transaction) put_port;
  
  function new(string name="t_monitor",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    if(uvm_config_db#(virtual IF)::get(this,"","if1",if1))
      $display("error.....");
    trans1=transaction::type_id::create("trans1");
    put_port=new("put_port",this);
  endfunction
    
  
  virtual task run_phase(uvm_phase phase);
    forever
    begin
      @(next);
      
    trans1.x=if1.x;
    trans1.y=if1.y;
    trans1.p=if1.p;    
    put_port.put(trans1);
    end
  endtask
    
endclass


//Agent class--------------------------------------------------

class t_agent extends uvm_agent;
  `uvm_component_utils(t_agent)
   t_sequencer seqr;
   t_driver drv;
   t_monitor mon;
   event next;
  
  function new(string name="t_agent",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    seqr=t_sequencer::type_id::create("seqr",this);
    drv=t_driver::type_id::create("drv",this);
    mon=t_monitor::type_id::create("mon",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
   drv.seq_item_port.connect(seqr.seq_item_export);
   drv.next=next;
   mon.next=next;
  endfunction
  
  
endclass



//Scoreboard class-----------------------------------------------
class t_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(t_scoreboard)
  uvm_blocking_put_imp#(transaction,t_scoreboard) put_imp;
  
  function new(string name="t_scoreboard",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    put_imp=new("put_imp",this);
  endfunction
  
  virtual task put(transaction trans1);
    begin
      if(trans1.x*trans1.y==trans1.p)
        begin
        $display("%d*%d=%d",trans1.x,trans1.y,trans1.p);
        $display("DATA_MATCHED");
        end
    else
      $display("DATA_MISMATCHED");
    end
  endtask
        
endclass




//class coverage-------------------------------------------------
class coverage extends uvm_component;
  `uvm_component_utils(coverage)
   transaction trans;
   uvm_analysis_imp#(transaction,coverage) analysis_imp;
  
   covergroup my_cover;
   option.per_instance=1;
   c1:coverpoint trans.x;
   c2:coverpoint trans.y;
   endgroup
  
  function new(string name="coverage",uvm_component parent);
    super.new(name,parent);
    my_cover=new();
  endfunction 
  
  function void build_phase(uvm_phase phase);
   analysis_imp=new("analysis_imp",this);  
  endfunction
     
  virtual function void write(transaction trans);
    this.trans=trans;
    my_cover.sample();
  endfunction
  
endclass
    



//Environment class-----------------------------------------------
class t_env extends uvm_env;
  `uvm_component_utils(t_env)
  t_agent agn;
  t_scoreboard scr;
  coverage cov;
  
  function new(string name="t_env",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    agn=t_agent::type_id::create("agn",this);
    scr=t_scoreboard::type_id::create("scr",this);
    cov=coverage::type_id::create("cov",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    agn.mon.put_port.connect(scr.put_imp);
    agn.drv.cov_port.connect(cov.analysis_imp);
  endfunction 
  
endclass




//Test class-----------------------------------------------------------------
class test extends uvm_test;
  `uvm_component_utils(test)
   t_env env;
   t_sequence seqn;
  
  function new(string name="test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    env=t_env::type_id::create("env",this);
    seqn=t_sequence::type_id::create("seqn");
  endfunction
        
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seqn.start(env.agn.seqr);
    phase.drop_objection(this);
  endtask
  
endclass



//Top module----------------------------------------------------
        
module tb;
  
 IF if1();
  
 Braun_multiplier M1(.x(if1.x),.y(if1.y),.p(if1.p));
  
    initial
    begin
      uvm_config_db#(virtual IF)::set(null,"*","if1",if1);
      run_test("test");
    end
  
  
    initial
    begin
      $dumpfile("dump.vcd"); 
      $dumpvars;
    end
       
endmodule
        
     
        
        
        
        
        
