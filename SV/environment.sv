`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"


class environment;
	generator gen;
	driver drv;
	monitor mon;
	scoreboard scb;
	virtual apb_slave_if vif;
	mailbox mbxmon2scb;

	function new(virtual apb_slave_if vif);
		this.vif = vif;
		mbxmon2scb = new();
		drv = new(vif);
		mon = new(vif,mbxmon2scb);
		gen = new(vif);
		scb = new(mbxmon2scb);
	endfunction
	task main();
		fork
			gen.run();
			drv.run();
			mon.run();
			scb.run();
		join

	endtask

endclass

