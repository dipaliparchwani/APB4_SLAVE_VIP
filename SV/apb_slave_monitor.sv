//`include "apb_slave_transaction.sv" //temp. include to compile this file alone
//latter not need to include because it all called in env and not need to
//declare all files in env because env handle is call in test and test have
//pacckege that include files
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//----apb_slave_monitor.sv : it samples the values from an interface 
//------------------------ : it send the packet to scoreboard
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
class apb_slave_monitor;
  mailbox mon2scb;
  int count_m;
  virtual apb_slave_if.monitor vif;  //if we not declared as virtual then we get syntax error like if it is interface declared as virtual 
  apb_slave_transaction trans;
  function new(virtual apb_slave_if.monitor vif,mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
    trans = new();
  endfunction
    task run();
      forever begin
	@(posedge vif.monitor_cb);
	//when write request then it sample below signals
	if(vif.monitor_cb.PWRITE && vif.monitor_cb.PSEL && vif.monitor_cb.PENABLE && vif.monitor_cb.PREADY) begin //----when write request than executes
          trans.PWDATA = vif.monitor_cb.PWDATA;
       	  trans.PSLVERR = vif.monitor_cb.PSLVERR;
	  trans.PADDR = vif.monitor_cb.PADDR;
	  trans.PWRITE = vif.monitor_cb.PWRITE;
	  mon2scb.put(trans);
	  count_m++;
	  $display("[mon] : [%0t] : [count_m] = {%0d},|| [PSEL = %0h],[PENABLE = %0h],[PREADY = %0h],[PWRITE = %0h],[PADDR = %0h],[PWDATA = %0h],[PSLVERR = %0h] ||",$time,count_m,vif.monitor_cb.PSEL,vif.monitor_cb.PENABLE,vif.monitor_cb.PREADY,trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSLVERR);

	end
         
	//when read request then it sample below signals
	else if(!vif.monitor_cb.PWRITE && vif.monitor_cb.PSEL && vif.monitor_cb.PENABLE && vif.monitor_cb.PREADY) begin  //----when read request than executes
       	  trans.PSLVERR = vif.monitor_cb.PSLVERR;
	  trans.PADDR = vif.monitor_cb.PADDR; 
	  trans.PRDATA = vif.monitor_cb.PRDATA;
	  trans.PWRITE = vif.monitor_cb.PWRITE;
	  mon2scb.put(trans);
	  count_m++;
	  $display("[mon] : [%0t] : [count_m] = {%0d}, || [PSEL = %0h],[PENABLE = %0h],[PREADY = %0h],[PWRITE = %0h],[PADDR = %0h],[PRDATA = %0h],[PSLVERR = %0h] ||",$time,count_m,vif.monitor_cb.PSEL,vif.monitor_cb.PENABLE,vif.monitor_cb.PREADY,trans.PWRITE,trans.PADDR,trans.PRDATA,trans.PSLVERR);

	end

	// for raed request,the requester must drive all bits of PSTRB low
	// PSTRB must not be active during read transfer
	
        //----	checkers ----//
	if(!trans.PWRITE) begin
	  if(trans.PSTRB != 0)
	     $error("invalid PSTRB");
	end

	//PSEL is asserted means that PADDR,PWRITE,PWDATA must be valid
	if(vif.monitor_cb.PSEL) begin
	  if($isunknown(trans.PADDR) || $isunknown(trans.PWRITE) || $isunknown(trans.PWDATA))
	    $error("invalid inputs");
        end

	//checker for PENABLE signal
	if(vif.monitor_cb.PENABLE && !vif.monitor_cb.PSEL)
	  $error("PENABLE asserted without PSEL");

        //chcker for PRDATA signal
	if(vif.monitor_cb.PSEL && vif.monitor_cb.PENABLE && vif.monitor_cb.PREADY) begin
	  if($isunknown(trans.PRDATA))
	    $error("read data is invalid");
        end

	//checker for PREADY signal
	if(vif.monitor_cb.PSEL && vif.monitor_cb.PENABLE)
	  if($isunknown(vif.monitor_cb.PREADY))
	    $error("invalid PREADY signal");
      end
    endtask
endclass

//driving means putting values on an interface
//sampling means taking values from an interface
