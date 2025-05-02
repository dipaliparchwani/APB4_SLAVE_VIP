import file_pkg::*;
import my_pkg::*;   //this package contains all testcase files
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//----file name : test.sv 
//----Description : it has handle of environment class and it control the testcases execution
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//we an not use class because in class we can not write procedural block
//we used program block because it run in reactive region to avoid conflicting between dut and tb
//we also can used module but it may conflict between dut and tb

class test;
  virtual apb_slave_if vif;
  apb_slave_environment env;             //environment class handle 
  sanity_test st;                        //sanity_test class handle
  function new(virtual apb_slave_if vif);
    this.vif = vif;
    env = new(vif);
   endfunction


  task testcase_run();                   //testcase execution ccontrol API
	  if($test$plusargs("sanity")) begin //if we provide sanity from argument then sanity testcase run
	    st = new(vif);
	    st.sanity_run();
	  end
  endtask

  task test_run();                       //it call the env main task and testcase_run task in parallel
    fork
      env.main();
      testcase_run();
    join
  endtask
  
endclass


