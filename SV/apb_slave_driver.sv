//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//#####################################  DRIVER CLASS  #####################################
//----File Name   : apb_slave_driver.sv 
//----Description : it drives the PREADY PRDATA and PSLVERR on the interface as per FSM
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
class apb_slave_driver;
  apb_slave_config drvc;  //config class handle
  virtual apb_slave_if.slave vif;  //taking interface handle as virtual because class is dynamic and interface is static to bind static with dynamic
  //new constructor
  function new(virtual apb_slave_if.slave vif,apb_slave_config drvc);
    this.vif = vif;
    this.drvc = drvc;
  endfunction
  //run task of driver
  task run();
    $display("[wait_state] : %0d,no.of_wait_cycles : %0d",drvc.wait_state,drvc.no_of_wait_cycles);
    forever begin
      @(posedge vif.slave_cb or negedge vif.PRESETn);
      //when reset come then this block executes
      if(!vif.PRESETn)begin
	vif.slave_cb.PREADY <= 0;
        vif.slave_cb.PRDATA <= 0;
	vif.slave_cb.PSLVERR <= 0;
	foreach (drvc.memory[i]) begin
          drvc.memory[i] = '0;
        end
      end

      else begin
	//start when PSEL high
	if(vif.slave_cb.PSEL == 1'b1) begin
	  if(drvc.wait_state)begin         //---if wait state introduced than this block executes otherwise in access phase directly PREADY become high
	    vif.slave_cb.PREADY <= 0;
	    repeat(drvc.no_of_wait_cycles)
	      @(posedge vif.slave_cb);
	  end
	      //it drive PREADY high
	  vif.slave_cb.PREADY <= 1'b1;
	  if(vif.slave_cb.PADDR>`depth) begin       //----this block check for the PSLVERR
            vif.slave_cb.PSLVERR <= 1'b1;
	  end
	  else begin
	    vif.slave_cb.PSLVERR <= 1'b0;
	  end

	  //when PWRITE high perform write operation
	  if(vif.slave_cb.PWRITE == 1'b1) begin //----if write request high than it write in memory
            //as per PSTRB it write in memory
	    foreach(vif.slave_cb.PSTRB[i]) begin
	      if(vif.slave_cb.PSTRB[i])
		drvc.memory[vif.slave_cb.PADDR][8*i +: 8] <= vif.slave_cb.PWDATA[8*i +: 8];
	    end
            $display("[drv_ACCESS_WR] : [%0t] : || [PSEL = %0h],[PENABLE = %0h],[PREADY = %0h],[PWRITE = %0h],[PADDR = %0h],[PWDATA = %0h],[PSLVERR = %0h] ||",$time,vif.slave_cb.PSEL,vif.slave_cb.PENABLE,vif.slave_cb.PREADY,vif.slave_cb.PWRITE,vif.slave_cb.PADDR,drvc.memory[vif.slave_cb.PADDR],vif.slave_cb.PSLVERR);
	  end
              //when PWRITE low it perform read operation
	  else begin                  //----if read request high than it read from memory
	    vif.slave_cb.PRDATA <= drvc.memory[vif.slave_cb.PADDR];
              $display("[drv_ACCESS_RD] : [%0t] : || [PSEL = %0h],[PENABLE = %0h],[PREADY = %0h],[PWRITE = %0h],[PADDR = %0h],[PRDATA = %0h],[PSLVERR = %0h] ||",$time,vif.slave_cb.PSEL,vif.slave_cb.PENABLE,vif.slave_cb.PREADY,vif.slave_cb.PWRITE,vif.slave_cb.PADDR,drvc.memory[vif.slave_cb.PADDR],vif.slave_cb.PSLVERR);
	  end

	      //it is mandatory as per spec after completion of transfer drive PREADY low at posedge of clock
	  @(posedge vif.slave_cb);
	  vif.slave_cb.PREADY <= 0;
	end
      end
    end

  endtask
endclass

 

         




	    
	    


