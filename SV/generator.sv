//`include "transaction.sv"
class generator;
	transaction t1;
	virtual apb_slave_if vif;
	function new(virtual apb_slave_if vif);
		this.vif = vif;
	endfunction


	task run();
		repeat(10) begin
			@(posedge vif.PCLK);
			t1 = new();
			t1.randomize();	
			vif.PENABLE <= t1.PENABLE;
			vif.PSEL <= t1.PSEL;
			vif.PWRITE <= t1.PWRITE;
			vif.PWDATA <= t1.PWDATA;
			vif.PADDR <= t1.PADDR;
			vif.PSTRB <= t1.PSTRB;
			$display("[gen] : data send %0t ",$time);
			t1.display();

		end
	endtask
endclass
