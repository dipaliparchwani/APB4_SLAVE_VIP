//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//----apb_slave_scoreboard.sv : it receives the packet from monitor
//----here we take golden memory
//----it compare the actual data and expected data for result
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//`include "apb_slave_transaction.sv"
class slave_scoreboard#(parameter int gdata_width = 32);
  mailbox mon2scb;
  int count;
  logic [gdata_width-1:0] golden_memory [*];
  apb_slave_transaction scbt;
  virtual apb_slave_if vif;


  function new(mailbox mon2scb,virtual apb_slave_if vif);
    this.mon2scb = mon2scb;
    this.vif = vif;
    count = 0;
  endfunction

  task run();
    forever begin
      mon2scb.get(scbt);
      count++;	
      $display("[scb] : data received from monitor at %0t count = %0d",$time,count);
      scbt.display();
      $display("________________________________");
	if(scbt.PWRITE)begin                             //----if write request than it write in scoreboard memory
          golden_memory[scbt.PADDR] <= scbt.PWDATA;
	  $display("[scb] : [%0t] write operation done successfully",$time);
	end
        else
//here we use case equality operator to compare x or z values because in case
//of x or z equality operator results in x
	  if(scbt.PRDATA === golden_memory[scbt.PADDR])     //----if read request than it compare scopreboard memory data with the actual data
	    $info("[scb] : [%0t]  TESTCASE PASSED at PADDR = %0h,actual_data = %0h,expected_data = %0h",$time,scbt.PADDR,scbt.PRDATA,golden_memory[scbt.PADDR]);
          else
	    $info("[scb] : [%0t]  TESTCASE FAILED at PADDR = %0h,actual_data = %0h,expected_data = %0h",$time,scbt.PADDR,scbt.PRDATA,golden_memory[scbt.PADDR]);
    end
  endtask
endclass
