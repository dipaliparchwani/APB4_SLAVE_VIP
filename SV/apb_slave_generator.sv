class apb_slave_generator;
  apb_slave_transaction t1;
  virtual apb_slave_if.slave vif;

  function new(virtual apb_slave_if vif);
    this.vif = vif;
  endfunction
  task run();
    #2;          // delay is given because at 0 time it consider reset value as x and never true if condition

     /* if(!vif.PRESETn) begin // when reset come it reset the all signals irrespective of clk
        vif.slave_cb.PSEL <= 0;
        vif.slave_cb.PENABLE <= 0;
        vif.slave_cb.PADDR <= 0;
        vif.slave_cb.PWDATA <= 0;
        vif.slave_cb.PWRITE <= 0;*/
        $display("[gen] : executes at %0t",$time);
   
  endtask
endclass
