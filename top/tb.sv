`include "../SV/interface.sv"
import file_pkg::*;
`include "../SVE/test.sv"

module tb;
logic PCLK;
logic PRESETn;
apb_slave_if vif(.PCLK(PCLK),.PRESETn(PRESETn));
test tst(vif);
initial begin
	PCLK = 0;
end

initial begin
	PRESETn = 0;
	#30 PRESETn = 1;
end
always #10 PCLK  = ~PCLK;
initial begin
	$dumpfile("slave.vcd");
	$dumpvars;
	#200 $finish;
end
endmodule

