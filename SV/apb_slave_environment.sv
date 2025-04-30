//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//----apb_slave_environment.sv : it call the run task of all components in 
//----paralle
//---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
class apb_slave_environment;
  apb_slave_generator gen;
  apb_slave_driver drv;
  apb_slave_monitor mon;
  slave_scoreboard scb;
  virtual apb_slave_if vif;
  mailbox mon2scb;

  function new(virtual apb_slave_if vif);
    this.vif = vif;
    mon2scb = new();
    drv = new(vif);
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

