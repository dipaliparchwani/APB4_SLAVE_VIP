//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//----file name : apb_slave_transaction.sv
//----Description : this class consist some signals of APB and some constarints 
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class apb_slave_transaction; //centralized addr_width and data_width provided using `define in sv_package file 
  rand bit PWRITE;
  bit PSLVERR;
  rand bit [`addr_width-1:0] PADDR;
  rand bit [`data_width-1:0] PWDATA;
  bit [`data_width-1:0] PRDATA;
  bit [`data_width/8] PSTRB;
  bit temp_PWRITE;

  constraint addr_control{PADDR inside {[0:1023]};} //for valid address generation
  constraint strb_control{PWRITE == 0 -> PSTRB == 0;} //when pwrite low than pstrb must low as per spec

  function void display(); //---for display values  
    $info("[%0t] : PWRITE = %0h,PSLVERR = %0h,PADDR = %0h,PWDATA = %0h,PRDATA = %0h,PSTRB = %0h",$time,PWRITE,PSLVERR,PADDR,PWDATA,PRDATA,PSTRB);
  endfunction

  /*function void pre_randomize();
    if(temp_PWRITE == 0) begin
      rand_mode(1);
      PWRITE.rand_mode(0);
      PWRITE = 1;
    end
    else begin
      rand_mode(0);
      PWRITE = 0;
    end
  endfunction

  function void post_randomize();
    temp_PWRITE = PWRITE;
    $display("|| [PWRITE = %0h],[PADDR = %0h],[PWDATA = %0h] ||",PWRITE,PADDR,PWDATA);
  endfunction*/

endclass

