class transaction #(parameter int addr_width = 32,data_width = 32); //parameterized data and address width
  rand bit PWRITE;
  bit PSLVERR;
  rand bit [addr_width-1:0] PADDR;
  rand bit [data_width-1:0] PWDATA;
  bit [data_width-1:0] PRDATA;
  rand bit [data_width/8] PSTRB;
  rand bit wait_state;
  rand int no_of_wait_cycles;

  constraint addr_control{PADDR inside {[0:1023]};} //for valid address generation
  constraint strb_control{PWRITE == 0 -> PSTRB == 0;} //when pwrite low than pstrb must low as per spec
  constraint wait_control{if(wait_state) no_of_wait_cycles inside {[0:10]}; else no_of_wait_cycles == 0;}


  function void display();
    $info("[%0t] : PWRITE = %0h,PSLVERR = %0h,PADDR = %0h,PWDATA = %0h,PRDATA = %0h,PSTRB = %0h",$time,PWRITE,PSLVERR,PADDR,PWDATA,PRDATA,PSTRB);
  endfunction
endclass

