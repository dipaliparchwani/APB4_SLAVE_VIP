//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//apb_slave_config class : provide control of various things to user
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class apb_slave_config;
  //static int addr_width = 32;
  logic [`cdata_width-1:0] memory [`depth-1:0];
  bit wait_state; //if you want wait state for PREADY then make it high
  int no_of_wait_cycles; // if you want wait state then set the no_of_wait_cycles
endclass
