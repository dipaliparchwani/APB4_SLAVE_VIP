//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//----apb_slave_environment.sv : it call the run task of all components in 
//----paralle
//---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
class apb_slave_environment;
  apb_slave_config con;    //config class handle
  apb_slave_generator gen; //generator class handle
  apb_slave_driver drv;    //driver class handle
  apb_slave_monitor mon;   //monitor class handle
  slave_scoreboard scb;    //scoreboard class handle
  virtual apb_slave_if vif;// interface 
  mailbox mon2scb;
//wait state and wait cycles support provided from an argument hence it is
//tested various cases by an argument
  function new(virtual apb_slave_if vif);
    this.vif = vif;
    mon2scb = new();
    con = new();
    $value$plusargs("wait_state=%0d",con.wait_state);
    $display("[wait_state] : %0d",con.wait_state);
    //user provide wait_state value 0 or 1 from an argument
    $value$plusargs("no_of_wait_cycles=%0d",con.no_of_wait_cycles);
    $display("[no_of_wait_cycles] : %0d",con.no_of_wait_cycles);
    // user provide no_of_wait_cycles from an argument if not provide than it take 3 by default
    drv = new(vif,con);
    mon = new(vif,mon2scb);
    gen = new(vif);
    scb = new(mon2scb,vif);
  endfunction

  task main();
    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join

  endtask

endclass

