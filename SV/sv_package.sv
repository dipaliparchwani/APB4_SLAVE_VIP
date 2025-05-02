package file_pkg;
  `define cdata_width 32
  `define depth 1024 
  `define addr_width 32 // `define compiler directive hence we can not change at runtime
  `define data_width 32 // it perform global substitution it remain active for all files compiled after macro definition
  `include "apb_slave_config.sv"  // `include copy the content of one file to another during compilation
  `include "apb_slave_transaction.sv"
  `include "apb_slave_generator.sv"
  `include "apb_slave_driver.sv"
  `include "apb_slave_monitor.sv"
  `include "slave_scoreboard.sv"
  `include "apb_slave_environment.sv"
endpackage



