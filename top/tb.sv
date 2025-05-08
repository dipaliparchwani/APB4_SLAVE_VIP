`include "../SV/interface.sv"
import file_pkg::*;     //SV files Package
import test_pkg::*;     //test file Package

module tb;

  logic PCLK = 0;
  logic PRESETn;
  real freq;      //frequency is supported in MHz
  real clk_period;

  apb_slave_if vif(.PCLK(PCLK), .PRESETn(PRESETn));
  test tst;

  // Set up frequency and clk_period at runtime
  initial begin
    if ($value$plusargs("freq=%0f", freq)) 
    clk_period = ((1/(freq * 1e6)) * 1e9);
    $info("freq = %0.2f MHz, clk_period = %0.2f ns", freq, clk_period);
  end

  // Clock generation
  initial begin
    wait (clk_period > 0); // ensure clk_period is valid
    forever #(clk_period / 2) PCLK = ~PCLK;     //clk designed based on frequency because we don't know APB Master Frequency
  end

  // Reset logic
  initial begin
    PRESETn = 0;
    #30 PRESETn = 1;
  end

  // Test execution
  initial begin
    tst = new(vif);
    tst.test_run();
  end

  // VCD dump
  initial begin
    $dumpfile("slave.vcd");
    $dumpvars(0, tb);
  end

endmodule

