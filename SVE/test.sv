import file_pkg::*;
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//----apb_slave_test.sv : it has handle of environment
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//
//we an not use class because in class we can not write procedural block
//we used program block because it run in reactive region to avoid conflicting between dut and tb
//we also can used module but it may conflict between dut and tb

program test(apb_slave_if vif);
  apb_slave_environment env;
  initial begin
    env = new(vif);
    env.main();
  end
endprogram


