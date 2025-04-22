class scoreboard;
	transaction t1;
	mailbox mbxmon2scb;
	int count,i,j;
	bit [7:0] golden_memory [1024];
	byte expected,actual;


	function new(mailbox mbxmon2scb);
		this.mbxmon2scb = mbxmon2scb;
		count = 0;
	endfunction

	task run();
		forever begin
			mbxmon2scb.get(t1);
			count++;
			$display("[scb] : data received from monitor at %0t count = %0d",$time,count);
			t1.display();
			$display("________________________________");
			if(t1.PSEL && t1.PENABLE && t1.PWRITE && t1.PREADY) begin
				j = 0;
				foreach(t1.PSTRB[i]) begin
					if(t1.PSTRB[i]) begin
						golden_memory[t1.PADDR+j] = t1.PWDATA[(8*i)+7 -: 8];
                                                expected = t1.PWDATA[(8*i)+7 -: 8];
                                                actual   = golden_memory[t1.PADDR + j];

						if (expected !== actual) 
							$error("[scb] write mismatch at addr %0d: expected = %0d, found = %0d",t1.PADDR+j,expected,actual);
						else
							$display("[scb] match at addr %0d: expected = %0d,found = %0d",t1.PADDR+j,expected,actual);
						j++;
					end
				end
			end
			$display("***********************************************************");
		end


	
	endtask






endclass
