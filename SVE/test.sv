import file_pkg::*; //this package contain sv dirctory files which are reusable and `define 
import my_pkg::*;   //this package contains all testcase files and `define
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//#############################  TEST  #############################
//----file name   : test.sv 
//----Description : it has handle of environment class and it control the testcases execution
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


class test;
  //virtual interface
  virtual apb_slave_if vif;
  //environment class handle 
  apb_slave_environment env;
  //various testcase class handles
  sanity_test st; 
  sanity_test_strb sts; 
  sanity_pro_test stp;
  sanity_pro_strb_test stps;
  directed_basic dbt;
  directed_basic_strb dbts;
  error_check ect;
  directed_simultaneous dst;
  directed_simultaneous_strb dsts;
  directed_last_check dlt;
  directed_last_check_strb dlts;
  reset_on_fly roft;
  random_test rt;
  //new constructor
  function new(virtual apb_slave_if vif);
    this.vif = vif;
    env = new(vif);
   endfunction

  //testcase execution ccontrol API
  task testcase_run();      
          //if we provide sanity from an argument then sanity testcase run
	  if($test$plusargs("sanity")) begin 
	    st = new(vif);
	    st.sanity_run();
	    wait(st.count_t == env.scb.count);
	  end

          //if we provide sanity_strb from an argument then sanity_strb testcase run
	  else if($test$plusargs("check_strb")) begin 
	    sts = new(vif);
	    sts.sanity_strb_run();
	    wait(sts.count_t == env.scb.count);
	  end

          //if we provide sanity_pro from an argument then sanity_pro testcase run
	  else if($test$plusargs("state_pro"))begin 
	    stp = new(vif);
            stp.sanity_pro_run();
	    wait(stp.count_t == env.scb.count);
	  end

          //if we provide sanity_pro_strb from an argument then sanity_pro_strb testcase run
	  else if($test$plusargs("pro_strb_check"))begin 
	    stps = new(vif);
            stps.sanity_pro_strb_run();
	    wait(stps.count_t == env.scb.count);
	  end

	  //if we provide directed_basic from an argument then directed_basic testcase run
	  else if($test$plusargs("directed_basic"))begin
	    dbt = new(vif);
	    dbt.directed_basic_run();
	    wait(dbt.count_t == env.scb.count);
	  end

           //if we provide directed_basic_strb from an argument then directed_basic_strb testcase run
	  else if($test$plusargs("test_directed_strb"))begin
	    dbts = new(vif);
	    dbts.directed_basic_strb_run();
	    wait(dbts.count_t == env.scb.count);
	  end

	   //if we provide error_check from an argument then error_check testcase run
	  else if($test$plusargs("error_check"))begin
	    ect = new(vif);
	    ect.error_check_run();
	    wait(ect.count_t == env.scb.count);
	  end

	   //if we provide directed_simultaneous from an argument then directed_simultaneous testcase run
	  else if($test$plusargs("directed_simultaneous"))begin
	    dst = new(vif);
	    dst. directed_simultaneous_run();
	    wait(dst.count_t == env.scb.count);
	  end

	   //if we provide directed_simultaneous_strb from an argument then directed_simultaneous_strb testcase run
	  else if($test$plusargs("simultaneous_strb_check"))begin
	    dsts = new(vif);
	    dsts. directed_simultaneous_strb_run();
	    wait(dsts.count_t == env.scb.count);
	  end

	   //if we provide reset_on_fly from an argument then reset_on_fly testcase run
	  else if($test$plusargs("reset_on_fly"))begin
	    roft = new(vif);
	    roft. reset_on_fly_run();
	    wait(roft.count_t == env.scb.count);
	  end

	   //if we provide directed_last_check from an argument then directed_last_check testcase run
	  else if($test$plusargs("directed_last_check"))begin
	    dlt = new(vif);
	    dlt. directed_last_check_run();
	    wait(dlt.count_t == env.scb.count);
	  end

	   //if we provide directed_last_check_strb from an argument then directed_last_check_strb testcase run
	  else if($test$plusargs("last_check_strb"))begin
	    dlts = new(vif);
	    dlts. directed_last_check_strb_run();
	    wait(dlts.count_t == env.scb.count);
	  end

	   //if we provide random_test from an argument then random_test testcase run
	  else if($test$plusargs("random_test"))begin
	    rt = new(vif);
	    rt. random_test_run();
	    wait(rt.count_t == env.scb.count);
	  end

  endtask
  //main run task of test
  task test_run();  //it call the env main task and testcase_run task in parallel
    fork
      env.main();  //environment main task
      testcase_run();  //testcase ontrol API
    join_any  //when any one task of fork join_any block complete it will finish
    $finish;
  endtask
  
endclass


