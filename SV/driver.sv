`include "configure.sv"
class driver;

	configure c1;
	int i,j = 0,count;
	virtual apb_slave_if vif;

	function new(virtual apb_slave_if vif);
		this.vif = vif;
		count = 0;
		c1 = new();
	endfunction

	task run();
		forever begin
			@(negedge vif.PCLK) begin
			
				// this logic for if we receive random values
				// from master
			/*	if(vif.PRESETn) begin
				vif.PSEL <= 0;
				vif.PENABLE <= 0;
				vif.PWDATA <= 0;
				vif.PWRITE <= 0;
				vif.PADDR <= 0;
				end*/
				
				if(!(vif.PSEL && vif.PENABLE)) begin
					vif.PREADY <= 0;
					vif.PSLVERR <= 0;
				end

			wait(vif.PSEL == 1'b1);
			wait(vif.PENABLE == 1'b1);
			vif.PREADY <= 1'b1;

			if(vif.PWRITE) begin
				foreach(vif.PSTRB[i]) begin
					
					if(vif.PSTRB[i] == 1'b1) begin

						c1.memory[vif.PADDR+j] <= vif.PWDATA[(8*i)+7 -: 8];
						j++;
					end
				end
			end
			else
				vif.PRDATA <= c1.memory[vif.PADDR];
			if(vif.PADDR >1023) vif.PSLVERR <= 1'b1;
			else vif.PSLVERR <= 1'b0;
		
			$display("[drv] : data send to interface %0t",$time);
			count++;
			$display("PSEL =%b,PWRITE = %b, PENABLE = %b, PADDR = %b, PWDATA = %b, PSTRB = %b, PRDATA = %b, PREADY = %b, PSLVERR = %b,count = %0d",vif.PSEL,vif.PWRITE,vif.PENABLE,vif.PADDR,vif.PWDATA,vif.PSTRB,vif.PRDATA,vif.PREADY,vif.PSLVERR,count);
		//	$display(memory = %p",c1.memory);

	

		end
	end
	endtask
endclass	
        		
                                                   
        
