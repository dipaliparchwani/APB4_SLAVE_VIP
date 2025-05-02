class apb_slave_generator;
  apb_slave_transaction t1;
  virtual apb_slave_if vif;

  function new(virtual apb_slave_if vif);
    this.vif = vif;
  endfunction
  task run();
    $display("[gen_before _if] : executes at %0t",$time);
    #2;

    $display("[gen_after_delay] : executes at %0t",$time);
      if(!vif.PRESETn) begin // when reset come it reset the all signals irrespective of clk
        vif.PSEL <= 0;
        vif.PENABLE <= 0;
        vif.PADDR <= 0;
        vif.PWDATA <= 0;
        vif.PWRITE <= 0;
        $display("[gen] : executes at %0t",$time);
      end
  endtask
endclass
