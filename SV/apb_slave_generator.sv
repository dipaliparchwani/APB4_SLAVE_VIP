class apb_slave_generator;
  apb_slave_transaction t1;  //transaction class handle
  virtual apb_slave_if.slave vif; //interface handle
  //new constructor
  function new(virtual apb_slave_if vif);
    this.vif = vif;
  endfunction
  //run task
  task run();
        $display("[gen] : executes at %0t",$time);
  endtask
endclass
