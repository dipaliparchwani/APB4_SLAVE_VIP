//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//############################ CONFIG CLASS  ############################
//----File Name   : apb_slave_config.sv
//----Description : provide control of various things to user
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class apb_slave_config;
  //data width and depth defined in the package file
  logic [`cdata_width-1:0] memory [`depth-1:0];
  bit wait_state; //if user want wait state for PREADY then make it high
  int no_of_wait_cycles; // if user want wait state then set the no_of_wait_cycles
endclass
