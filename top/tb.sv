`include "interface.sv"
`include "test.sv"

module tb;
logic PCLK;
logic PSEL;
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
	$dumpvars(0,tb.vif);
	#200 $finish;
end
endmodule

