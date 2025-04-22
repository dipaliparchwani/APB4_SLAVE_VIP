class transaction #(parameter int addr_width = 32,data_width = 32);
	randc bit PSEL;
	randc bit PWRITE;
	randc bit PENABLE;
	rand bit [addr_width-1:0] PADDR;
	rand bit [data_width-1:0] PWDATA;
	randc bit [data_width/8] PSTRB;
	bit [data_width-1:0]PRDATA;
	bit PREADY;
	bit PSLVERR;
	constraint addr_control {PADDR inside {[0:1023]};}
	//constraint 
	function void display();
		$display("PSEL =%b,PWRITE = %b, PENABLE = %b, PADDR = %b, PWDATA = %b, PSTRB = %b, PRDATA = %b, PREADY = %b, PSLVERR = %b",PSEL,PWRITE,PENABLE,PADDR,PWDATA,PSTRB,PRDATA,PREADY,PSLVERR,$time);
	endfunction
	constraint c1 {PSEL == 1'b1; PENABLE == 1'b1; 
        PWRITE == 0 -> PSTRB == 0;
	}


endclass
