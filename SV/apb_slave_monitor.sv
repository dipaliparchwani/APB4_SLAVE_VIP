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
  virtual apb_slave_if vif;  //if we not declared as virtual then we get syntax error like if it is interface declared as virtual 
  apb_slave_transaction trans;
  function new(virtual apb_slave_if vif,mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
    trans = new();
  endfunctioni
    task run();
      forever begin
	@(posedge vif.PCLK);
	if(vif.PWRITE && vif.PSEL && vif.PENABLE && vif.PREADY) begin //----when write request than executes
          trans.PWDATA = vif.PWDATA;
       	  trans.PSLVERR = vif.PSLVERR;
	  trans.PSTRB = vif.PSTRB;
	  trans.PADDR = vif.PADDR;
	  trans.PWRITE = vif.PWRITE;
	  $display("[mon] : [%0t] : PSEL = %0h,PENABLE = %0h,PREADY = %0h,PWRITE = %0h,PADDR = %0h,PWDATA = %0h,PSLVERR = %0h",$time,vif.PSEL,vif.PENABLE,vif.PREADY,trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSLVERR);
	  mon2scb.put(trans);

	end

	else if(!vif.PWRITE && vif.PSEL && vif.PENABLE && vif.PREADY) begin  //----when read request than executes
       	  trans.PSLVERR = vif.PSLVERR;
	  trans.PADDR = vif.PADDR; 
	  trans.PRDATA = vif.PRDATA;
	  trans.PWRITE = vif.PWRITE;
	  $display("[mon] : [%0t] : PSEL = %0h,PENABLE = %0h,PREADY = %0h,PWRITE = %0h,PADDR = %0h,PRDATA = %0h,PSLVERR = %0h",$time,vif.PSEL,vif.PENABLE,vif.PREADY,trans.PWRITE,trans.PADDR,trans.PRDATA,trans.PSLVERR);
	  mon2scb.put(trans);

	end

	// for raed request,the requester must drive all bits of PSTRB low
	// PSTRB must not be active during read transfer
	
        //----	checkers ----//
	if(!trans.PWRITE) begin
	  if(trans.PSTRB == 0) $display("valid PSTRB");
	  else $error("invalid PSTRB");
	end

	//PSEL is asserted means that PADDR,PWRITE,PWDATA must be valid
	if(vif.PSEL) begin
	  if($isunknown(trans.PADDR) || $isunknown(trans.PWRITE) || $isunknown(trans.PWDATA))
	    $error("invalid inputs");
        end

	//checker for PENABLE signal
	if(vif.PENABLE && !vif.PSEL)
	  $error("PENABLE asserted without PSEL");

        //chcker for PRDATA signal
	if(vif.PSEL && vif.PENABLE && vif.PREADY) begin
	  if($isunknown(trans.PRDATA))
	    $error("read data is invalid");
        end

	//checker for PREADY signal
	if(vif.PSEL && vif.PENABLE)
	  if($isunknown(vif.PREADY))
	    $error("invalid PREADY signal");
      end
    endtask
endclass

