//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//----testcase1.sv : sanity testcase
//----it basically check normal read and write operation on same address to
//----verify protocol is work perfect or not
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
import my_pkg::*;
class sanity_test;
  apb_slave_transaction t1;
  virtual apb_slave_if vif;

  function new(virtual apb_slave_if vif);
    this.vif = vif;
  endfunction
  task run();
    @(posedge vif.PCLK);
    t1 = new();
    t1.randomize() with {PADDR == 8;PWRITE == 1;};
    vif.PSEL = 0;
    @(posedge vif.PCLK);
    vif.PSEL = 1'b1;
    vif.PWDATA = t1.PWDATA;
    vif.PADDR = t1.PADDR;
    vif.PWRITE = t1.PWRITE;
    @(posedge vif.PCLK);
    vif.PENABLE = 1'b1;
    //@(vif.PREADY == 1'b1);
    repeat(2)
    @(posedge vif.PCLK);
    vif.PSEL = 0;
    vif.PENABLE = 0;
    t1 = new();
    t1.randomize() with {PADDR == 8;PWRITE == 0;};
    @(posedge vif.PCLK);
    vif.PSEL = 1'b1;
    vif.PADDR = t1.PADDR;
    vif.PWRITE = t1.PWRITE;
    vif.PWDATA = t1.PWDATA;
    @(posedge vif.PCLK);
    vif.PENABLE = 1'b1;
    wait(vif.PREADY == 1'b1);
    @(posedge vif.PCLK)
    vif.PSEL = 0;
    vif.PENABLE = 0;
  endtask



endclass
