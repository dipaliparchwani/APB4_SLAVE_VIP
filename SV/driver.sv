`include "configure.sv" //import package to include config file
//`include "transaction.sv" //import package to include transaction file import at test and tb
class driver;
  configure c1;
 // transaction t1;
 // mailbox gen2drv;
  typedef enum logic [1:0]{IDLE,SETUP,ACCESS}slave_state;
  slave_state ps;

  virtual apb_slave_if vif; //taking interface handle as virtual because class is dynamic and interface is static to bind static with dynamic

  function new(virtual apb_slave_if vif,mailbox gen2drv);
    this.vif = vif;
    this.gen2drv = gen2drv;
    c1 = new();
    t1 = new();
    ps = IDLE;
  endfunction



  task run();
   // wait(vif.PRESETn == 1'b1);
   // ps = IDLE;
    forever begin
      @(posedge vif.PCLK);
     // gen2drv.get(t1);
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
            $display("[%0t] : vif.PSEL = %0h,vif.PENABLE = %0h,vif.PREADY = %0h",$time,vif.PSEL,vif.PENABLE,vif.PREADY);
            t1.display();

          end

	  SETUP : begin
            vif.PREADY <= $urandom;
	    if(vif.PSEL && vif.PENABLE)
	      ps <= ACCESS;
            else if(vif.PSEL && !vif.PENABLE)
	      ps <= SETUP;
            else
	      ps <= IDLE;
            $display("[%0t] : vif.PSEL = %0h,vif.PENABLE = %0h,vif.PREADY = %0h",$time,vif.PSEL,vif.PENABLE,vif.PREADY);
            t1.display();

          end

	  ACCESS : begin
	    if(vif.PSEL && vif.PENABLE)begin
	      if(c1.wait_state)begin
		vif.PREADY <= 0;
		repeat(c1.no_of_wait_cycles);
	      end
	      vif.PREADY <= 1'b1;

	      if(vif.PADDR>c1.depth)
		vif.PSLVERR <= 1'b1;
	      else
		vif.PSLVERR <= 1'b0;
	      if(vif.PWRITE)begin
		c1.memory[vif.PADDR] <= vif.PWDATA;
		if(vif.PSEL)
		  ps <= SETUP;
	        else
	          ps <= IDLE;
	      end
	      else begin
		vif.PRDATA <= c1.memory[vif.PADDR];
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
	    
	    $display("[%0t] : vif.PSEL = %0h,vif.PENABLE = %0h,vif.PREADY = %0h",$time,vif.PSEL,vif.PENABLE,vif.PREADY);
            t1.display();

	  end

	endcase
      end
      $display("[%0t] : vif.PSEL = %0h,vif.PENABLE = %0h,vif.PREADY = %0h",$time,vif.PSEL,vif.PENABLE,vif.PREADY);
      t1.display();
    end
  endtask
endclass

 

         




	    
	    


