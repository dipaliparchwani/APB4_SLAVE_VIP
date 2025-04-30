import my_pkg::*;
class apb_slave_generator;
  apb_slave_transaction t1;
  sanity_test t; 
  virtual apb_slave_if vif;

  function new(virtual apb_slave_if vif);
    this.vif = vif;
    t = new(vif);
  endfunction
  task run();
    if(!vif.PRESETn) begin // when reset come it reset the all signals irrespective of clk
      vif.PSEL <= 0;
      vif.PENABLE <= 0;
      vif.PADDR <= 0;
      vif.PWDATA <= 0;
      vif.PWRITE <= 0;
    end
    if($test$plusargs("sanity")) // if we provide sanity from argument thaen it executes the run method of sanity_test                                  
      t.run();
  endtask
endclass
