class configure #(parameter int depth = 1024,width = 8);
  bit [width-1:0] memory [depth-1:0];
  bit wait_state; //if you want wait state for PREADY rhen make it high
  int no_of_wait_cycles; // if you want wait state then set the no_of_wait_cycles
endclass
