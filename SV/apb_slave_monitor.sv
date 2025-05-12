//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//##########################  MONITOR CLASS ##############################
//----File Name   : apb_slave_monitor.sv 
//----Description : it samples the packet from an interface and send the packet to scoreboard
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
class apb_slave_monitor;
  mailbox mon2scb;  //mailbox for Packet send to scoreboard
  int count_m;      //monitor count
  virtual apb_slave_if.monitor vif;  //if we not declared as virtual then we get syntax error like if it is interface declared as virtual 
  apb_slave_transaction trans;  //transaction class handle
  apb_slave_coverage cov;
  //new constructor for monitor
  function new(virtual apb_slave_if.monitor vif,mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
    trans = new();
    cov = new(trans);
  endfunction
    //run task of monitor
    task run();
      forever begin
	@(posedge vif.monitor_cb);
	//when write request then it sample below signals
	if(vif.monitor_cb.PWRITE && vif.monitor_cb.PSEL && vif.monitor_cb.PENABLE && vif.monitor_cb.PREADY) begin //----when write request than executes
          trans.PWDATA = vif.monitor_cb.PWDATA;
       	  trans.PSLVERR = vif.monitor_cb.PSLVERR;
	  trans.PADDR = vif.monitor_cb.PADDR;
	  trans.PWRITE = vif.monitor_cb.PWRITE;
	  trans.PSTRB = vif.monitor_cb.PSTRB;
	  cov.cg_apb_slave.sample();
	  mon2scb.put(trans);
	  count_m++;  //increase the count
	  $display("[mon] : [%0t] : [count_m] = {%0d},|| [PSEL = %0h],[PENABLE = %0h],[PREADY = %0h],[PWRITE = %0h],[PADDR = %0h],[PWDATA = %0h],[PSLVERR = %0h],[PSTRB = %0h] ||",$time,count_m,vif.monitor_cb.PSEL,vif.monitor_cb.PENABLE,vif.monitor_cb.PREADY,trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSLVERR,trans.PSTRB);

	end
         
	//when read request then it sample below signals
	else if(!vif.monitor_cb.PWRITE && vif.monitor_cb.PSEL && vif.monitor_cb.PENABLE && vif.monitor_cb.PREADY) begin  //----when read request than executes
       	  trans.PSLVERR = vif.monitor_cb.PSLVERR;
	  trans.PADDR = vif.monitor_cb.PADDR; 
	  trans.PRDATA = vif.monitor_cb.PRDATA;
	  trans.PWRITE = vif.monitor_cb.PWRITE;
	  trans.PSTRB = vif.monitor_cb.PSTRB;
	  mon2scb.put(trans);
	  cov.cg_apb_slave.sample();
	  count_m++;  //increase the count
	  $display("[mon] : [%0t] : [count_m] = {%0d}, || [PSEL = %0h],[PENABLE = %0h],[PREADY = %0h],[PWRITE = %0h],[PADDR = %0h],[PRDATA = %0h],[PSLVERR = %0h],[PSTRB = %0h] ||",$time,count_m,vif.monitor_cb.PSEL,vif.monitor_cb.PENABLE,vif.monitor_cb.PREADY,trans.PWRITE,trans.PADDR,trans.PRDATA,trans.PSLVERR,trans.PSTRB);

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
	  if($isunknown(vif.monitor_cb.PADDR) || $isunknown(vif.monitor_cb.PWRITE) || $isunknown(vif.monitor_cb.PWDATA))
	    $error("invalid inputs");
        end

	//checker for PENABLE signal
	if(vif.monitor_cb.PENABLE && !vif.monitor_cb.PSEL)
	  $error("PENABLE asserted without PSEL");

        //chcker for PRDATA signal
	if(vif.monitor_cb.PSEL && vif.monitor_cb.PENABLE && vif.monitor_cb.PREADY) begin
	  if($isunknown(vif.monitor_cb.PRDATA))
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
