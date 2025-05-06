//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//----apb_slave_driver.sv : it drive the PREADY PRDATA and PSLVERR on the
//----interface
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
class apb_slave_driver;
  apb_slave_config drvc;
  typedef enum logic [1:0]{IDLE,SETUP,ACCESS}slave_state;
  slave_state ps,ns;

  virtual apb_slave_if.slave vif; //taking interface handle as virtual because class is dynamic and interface is static to bind static with dynamic

  function new(virtual apb_slave_if.slave vif,apb_slave_config drvc);
    this.vif = vif;
    this.drvc = drvc;
    ps = IDLE;
  endfunction



  task run();
    $display("[wait_state] : %0d,no.of_wait_cycles : %0d",drvc.wait_state,drvc.no_of_wait_cycles);
    forever begin
      @(posedge vif.slave_cb);
      if(!vif.PRESETn)begin
	vif.slave_cb.PREADY <= 0;
        vif.slave_cb.PRDATA <= 0;
	vif.slave_cb.PSLVERR <= 0;
	ps <= IDLE;
      end
      else begin
	case(ps)
	  IDLE : begin
           // vif.PREADY <= $urandom;
	    if(vif.slave_cb.PSEL)
	      ps <= SETUP;
            else
	      ps <= IDLE;
            
            $display("[drv_IDLE] : [%0t] : PSEL = %0h,PENABLE = %0h,PREADY = %0h,PWRITE = %0h,PADDR = %0h,PWDATA = %0h,PRDATA = %0h,PSLVERR = %0h",$time,vif.slave_cb.PSEL,vif.slave_cb.PENABLE,vif.slave_cb.PREADY,vif.slave_cb.PWRITE,vif.slave_cb.PADDR,vif.slave_cb.PWDATA,vif.slave_cb.PRDATA,vif.slave_cb.PSLVERR);
          end

	  SETUP : begin
           // vif.PREADY <= $urandom;
	    if(vif.slave_cb.PSEL && vif.slave_cb.PENABLE)
	      ps <= ACCESS;
            else if(vif.slave_cb.PSEL && !vif.slave_cb.PENABLE)
	      ps <= SETUP;
            $display("[drv_SETUP] : [%0t] : PSEL = %0h,PENABLE = %0h,PREADY = %0h,PWRITE = %0h,PADDR = %0h,PWDATA = %0h,PRDATA = %0h,PSLVERR = %0h",$time,vif.slave_cb.PSEL,vif.slave_cb.PENABLE,vif.slave_cb.PREADY,vif.slave_cb.PWRITE,vif.slave_cb.PADDR,vif.slave_cb.PWDATA,vif.slave_cb.PRDATA,vif.slave_cb.PSLVERR);
          end

	  ACCESS : begin
	    if(vif.slave_cb.PSEL && vif.slave_cb.PENABLE)begin
	      if(drvc.wait_state)begin         //---if wait state introduced than this block executes otherwise in access phase directly PREADY become high
		vif.slave_cb.PREADY <= 0;
		repeat(drvc.no_of_wait_cycles)
		  @(posedge vif.slave_cb);
	      end
	      vif.slave_cb.PREADY <= 1'b1;

	      if(vif.slave_cb.PADDR>`depth)       //----this block check for the PSLVERR
		vif.slave_cb.PSLVERR <= 1'b1;
	      else
		vif.slave_cb.PSLVERR <= 1'b0;
	      if(vif.slave_cb.PWRITE == 1'b1) begin         //----if write request high than it write in memory
		drvc.memory[vif.slave_cb.PADDR] <= vif.slave_cb.PWDATA;
                $display("[drv_ACCESS_WR] : [%0t] : PSEL = %0h,PENABLE = %0h,PREADY = %0h,PWRITE = %0h,PADDR = %0h,PWDATA = %0h,PSLVERR = %0h",$time,vif.slave_cb.PSEL,vif.slave_cb.PENABLE,vif.slave_cb.PREADY,vif.slave_cb.PWRITE,vif.slave_cb.PADDR,drvc.memory[vif.slave_cb.PADDR],vif.slave_cb.PSLVERR);
	      end

	      else begin                  //----if read request high than it read from memory
		vif.slave_cb.PRDATA <= drvc.memory[vif.slave_cb.PADDR];
                $display("[drv_ACCESS_RD] : [%0t] : PSEL = %0h,PENABLE = %0h,PREADY = %0h,PWRITE = %0h,PADDR = %0h,PRDATA = %0h,PSLVERR = %0h",$time,vif.slave_cb.PSEL,vif.slave_cb.PENABLE,vif.slave_cb.PREADY,vif.slave_cb.PWRITE,vif.slave_cb.PADDR,drvc.memory[vif.slave_cb.PADDR],vif.slave_cb.PSLVERR);
	      end
	      #1;
	      vif.slave_cb.PREADY <= 0;
	      
	    end
	    else if(vif.slave_cb.PSEL && !vif.slave_cb.PENABLE)
	      ps <= SETUP;
            else
	      ps <= IDLE;
          
            $display("[drv_ACCESS] : [%0t] : PSEL = %0h,PENABLE = %0h,PREADY = %0h,PWRITE = %0h,PADDR = %0h,PWDATA = %0h,PRDATA = %0h,PSLVERR = %0h",$time,vif.slave_cb.PSEL,vif.slave_cb.PENABLE,vif.slave_cb.PREADY,vif.slave_cb.PWRITE,vif.slave_cb.PADDR,vif.slave_cb.PWDATA,vif.slave_cb.PRDATA,vif.slave_cb.PSLVERR);
	    
	  end

	endcase
      end
    end
  endtask
endclass

 

         




	    
	    


