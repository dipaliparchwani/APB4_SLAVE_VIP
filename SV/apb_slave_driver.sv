//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//----apb_slave_driver.sv : it drive the PREADY PRDATA and PSLVERR on the
//----interface
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
class apb_slave_driver;
  apb_slave_config c1;
  typedef enum logic [1:0]{IDLE,SETUP,ACCESS}slave_state;
  slave_state ps;

  virtual apb_slave_if vif; //taking interface handle as virtual because class is dynamic and interface is static to bind static with dynamic

  function new(virtual apb_slave_if vif);
    this.vif = vif;
    c1 = new();
    ps = IDLE;
  endfunction



  task run();
    forever begin
      @(posedge vif.PCLK);
      if(!vif.PRESETn)begin
	vif.PREADY <= 0;
        vif.PRDATA <= 0;
	vif.PSLVERR <= 0;
	ps = IDLE;
      end
      else begin
	case(ps)
	  IDLE : begin
            vif.PREADY <= $urandom;
	    if(vif.PSEL)
	      ps <= SETUP;
            else
	      ps <= IDLE;
          end

	  SETUP : begin
            vif.PREADY <= $urandom;
	    if(vif.PSEL && vif.PENABLE)
	      ps <= ACCESS;
            else if(vif.PSEL && !vif.PENABLE)
	      ps <= SETUP;
            else
	      ps <= IDLE;
          end

	  ACCESS : begin
	    if(vif.PSEL && vif.PENABLE)begin
	      if(c1.wait_state)begin         //---if wait state introduced than this block executes otherwise in access phase directly PREADY become high
		vif.PREADY <= 0;
		repeat(c1.no_of_wait_cycles)
		  @(posedge vif.PCLK);
	      end
	      vif.PREADY <= 1'b1;

	      if(vif.PADDR>c1.depth)       //----this block check for the PSLVERR
		vif.PSLVERR <= 1'b1;
	      else
		vif.PSLVERR <= 1'b0;
	      if(vif.PWRITE)begin          //----if write request high than it write in memory
		c1.memory[vif.PADDR] <= vif.PWDATA;
		@(posedge vif.PCLK);
		if(vif.PSEL)
		  ps <= SETUP;
	        else
	          ps <= IDLE;
	      end
	      else begin                   //----if read request high than it read from memory
		vif.PRDATA <= c1.memory[vif.PADDR];
		@(posedge vif.PCLK);
		if(vif.PSEL)
		  ps <= SETUP;
	        else
		  ps <= IDLE;
	      end
	    end
	    else if(vif.PSEL && !vif.PENABLE)
	      ps <= SETUP;
            else
	      ps <= IDLE;
          
          $display("[drv] : [%0t] : PSEL = %0h,PENABLE = %0h,PREADY = %0h,PWRITE = %0h,PADDR = %0h,PWDATA = %0h,PRDATA = %0h,PSLVERR = %0h",$time,vif.PSEL,vif.PENABLE,vif.PREADY,vif.PWRITE,vif.PADDR,vif.PWDATA,vif.PRDATA,vif.PSLVERR);
	  end

	endcase
      end
    end
  endtask
endclass

 

         




	    
	    


