//`include "transaction.sv"
class monitor;
	mailbox mbxmon2scb;
	virtual apb_slave_if vif;
	transaction trans;
	
	function new(virtual apb_slave_if vif,mailbox mbxmon2scb);
		this.vif = vif;
		this.mbxmon2scb = mbxmon2scb;
	endfunction

	task run();
		forever begin
			trans = new();

			@(negedge vif.PCLK);
			trans.PREADY = vif.PREADY;
			trans.PRDATA = vif.PRDATA;
			trans.PSLVERR = vif.PSLVERR;
			trans.PENABLE = vif.PENABLE;
			trans.PSEL = vif.PSEL;
			trans.PADDR = vif.PADDR;
			trans.PWRITE = vif.PWRITE;
			trans.PWDATA = vif.PWDATA;
			trans.PSTRB = vif.PSTRB;
			$display("[mon] : data received from interface at %0t",$time);
			trans.display();
//For read transfers, the Requester must drive all bits of PSTRB LOW.
//pstrb must not be active during read transfer
			if(!trans.PWRITE)begin
				if(trans.PSTRB == 0) $display("valid PSTRB");
				else $error("invalid PSTRB");
			end

//, PSEL, is asserted, which means that PADDR, PWRITE and PWDATA must be valid.
                        if(trans.PSEL)
			begin
				if($isunknown(trans.PADDR) || $isunknown(trans.PWRITE) || $isunknown(trans.PWDATA))
					$error("invalid inputs");
			end
			//checker for PENABLE signal
			if(trans.PENABLE && !trans.PSEL)
				$error("PENABLE asserted without PSEL");

                       // checker for PRDATA signal
			if(trans.PSEL && trans.PENABLE && trans.PREADY)begin
				if($isunknown(trans.PRDATA))
					$error("read data is invalid");
			end

			//checker for PREADY signal
			if(trans.PENABLE && trans.PSEL) 
				if($isunknown(trans.PREADY))
					$error("invalid PREADY signal");

			mbxmon2scb.put(trans);
		end
	endtask





endclass

