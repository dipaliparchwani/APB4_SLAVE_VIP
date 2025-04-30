//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//----apb_slave_scoreboard.sv : it receives the packet from monitor
//----here we take golden memory
//----it compare the actual data and expected data for result
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//`include "apb_slave_transaction.sv"
class slave_scoreboard;
  apb_slave_transaction t1;
  mailbox mon2scb;
  virtual apb_slave_if vif;
  int count;
  bit [31:0] golden_memory [1024];


  function new(mailbox mon2scb,virtual apb_slave_if vif);
    this.mon2scb = mon2scb;
    this.vif = vif;
    count = 0;
  endfunction

  task run();
    forever begin
      mon2scb.get(t1);
      count++;	
      $display("[scb] : data received from monitor at %0t count = %0d",$time,count);
      t1.display();
      $display("________________________________");
      if(vif.PSEL && vif.PENABLE && vif.PREADY) begin
	if(t1.PWRITE)begin                             //----if write request than it write in scoreboard memory
          golden_memory[t1.PADDR] <= t1.PWDATA;
	  $display("[scb] : [%0t] write operation done successfully",$time);
	end
        else
	  if(t1.PRDATA == golden_memory[t1.PADDR])     //----if read request than it compare scopreboard memory data with the actual data
	    $info("[scb] : [%0t]  testcase passed ",$time);
          else
	    $error("[scb] : [%0t] testcase failed ",$time);
      end
    end
  endtask
endclass
