//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//###################################### SCOREBOARD CLASS  ######################################
//----File Name   : slave_scoreboard.sv 
//----Description : it receives the packet from monitor and it compare the actual data and expected data for result
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
class slave_scoreboard#(parameter int gdata_width = 32);
  mailbox mon2scb;  //mailbox to receive packet
  int count,wr_count_scb,rd_count_scb,pass_count,fail_count;  //varios counts to track status
  //Associative array to use as local memory and to prevent wastage of space
  //--here we take golden memory
  bit [gdata_width-1:0] golden_memory [*];
  apb_slave_transaction scbt;  //transaction class handle
  apb_slave_config scbc;
  virtual apb_slave_if.slave vif;  //interface handle

  //new constructor
  function new(mailbox mon2scb,virtual apb_slave_if vif,apb_slave_config scbc);
    this.mon2scb = mon2scb;
    this.vif = vif;
    this.scbc = scbc;
    count = 0;
  endfunction
  //run task of scoreboard
  task run();
    forever begin
      mon2scb.get(scbt);  //get packet using mailbox
      count++;	
      $display("[scb] : data received from monitor at %0t count = %0d",$time,count);
      scbt.display();  //calling transaction class display method
      $display("________________________________");
      //if PSLVERR is high it give error message
      if(scbt.PSLVERR == 1'b1)
        $error("#####################################  ERROR  ################################################################");
      if(scbt.PWRITE)begin                             //----if write request than it write in scoreboard memory
	   foreach(scbt.PSTRB[i]) begin
		   if(scbt.PSTRB[i])
		     golden_memory[scbt.PADDR][8*i +: 8] = scbt.PWDATA[8*i +: 8];
	   end
	  wr_count_scb++;  //increase the write count
	  $display("[scb] : [%0t] ==> [wr_count_scb] = {%0d}  write operation done successfully",$time,wr_count_scb);
      end
      else begin
	rd_count_scb++;  //increase read count because write oeration
        //here we use case equality operator to compare x or z values because in case
        //of x or z equality operator results in x
        if(scbc.memory[scbt.PADDR] === golden_memory[scbt.PADDR]) begin   //----if read request than it compare scopreboard memory data with the actual data
	  $display("#################################################################################");
	  $display("########################  TESTCASE PASSED  ######################################");
	  $display("#################################################################################");
	  pass_count++;
	  $info("[scb] : [%0t]  ==> [rd_count_scb] = {%0d} TESTCASE PASSED at || {PADDR = %0h],[actual_data = %0h],[expected_data = %0h] ||",$time,rd_count_scb,scbt.PADDR,scbt.PRDATA,golden_memory[scbt.PADDR]);
	end

	else begin
	  $display("##################################################################################");
          $display("########################  TESTCASE FAILED  #######################################");
	  $display("##################################################################################");
	  fail_count++;
	  $info("[scb] : [%0t] ==> [rd_count_scb] = {%0d}  TESTCASE FAILED at || [PADDR = %0h],[actual_data = %0h],[expected_data = %0h] ||",$time,rd_count_scb,scbt.PADDR,scbt.PRDATA,golden_memory[scbt.PADDR]);
	end
      end
      $display("[pass_count = %0d],[fail_count = %0d]",pass_count,fail_count);
    end
  endtask
endclass
