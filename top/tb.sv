`include "../SV/interface.sv"
import file_pkg::*;
import test_pkg::*; 
module tb;
logic PCLK;
logic PRESETn;
apb_slave_if vif(.PCLK(PCLK),.PRESETn(PRESETn));
test tst;
initial begin
  tst = new(vif);
  tst.test_run();
end

initial begin
  PCLK = 0;
end

initial begin
  #1 PRESETn = 0;
  #30 PRESETn = 1;
end

always #10 PCLK  = ~PCLK;

initial begin
  $dumpfile("slave.vcd");
  $dumpvars(0,tb);
  #690 $finish;
end

endmodule

