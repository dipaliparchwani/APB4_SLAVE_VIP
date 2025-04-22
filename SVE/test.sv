`include "environment.sv"
program test(apb_slave_if vif);
	environment env;
	initial begin
		env = new(vif);
		env.main();
	end
endprogram


