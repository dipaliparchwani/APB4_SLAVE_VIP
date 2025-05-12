//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//#######################################  TRANSACTION CLASS  #######################################
//----file name   : apb_slave_transaction.sv
//----Description : this class consist some signals of APB Protocol and some constarints 
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class apb_slave_transaction; //centralized addr_width and data_width provided using `define in sv_package file 
  //APB Protocol signals
  rand logic PWRITE;
  logic PSLVERR;
  rand logic [`addr_width-1:0] PADDR;
  rand logic [`data_width-1:0] PWDATA;
  logic [`data_width-1:0] PRDATA;
  rand logic [(`data_width/8)-1:0] PSTRB;
  //constraints
  constraint addr_control{PADDR inside {[0:1023]};} //for valid address generation
  constraint strb_control{PWRITE == 0 -> PSTRB == 0;} //when pwrite low than pstrb must low as per spec
  //general display method
  function void display(); //---for display values  
    $info("[%0t] : PWRITE = %0h,PSLVERR = %0h,PADDR = %0h,PWDATA = %0h,PRDATA = %0h,PSTRB = %0h",$time,PWRITE,PSLVERR,PADDR,PWDATA,PRDATA,PSTRB);
  endfunction
  //post randomization method
  function void post_randomize();
    $display("|| [PWRITE = %0h],[PADDR = %0h],[PWDATA = %0h],[PSTRB = %0h] ||",PWRITE,PADDR,PWDATA,PSTRB);
  endfunction

endclass

