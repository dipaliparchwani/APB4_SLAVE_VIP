import file_pkg::*;
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//----testcase1.sv : sanity testcase
//----it basically check normal read and write operation on same address to
//----verify protocol is work perfect or not
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
class base_test;
  virtual apb_slave_if.master vif;
  typedef enum logic [1:0]{IDLE,SETUP,ACCESS}state;
  state ps = IDLE;

  function new(virtual apb_slave_if.master vif);
    this.vif = vif;
  endfunction



  task drive_run(bit PWRITE,bit[`addr_width-1:0]PADDR,bit[`data_width-1:0]PWDATA,bit transfer);
    forever begin
      @(posedge vif.master_cb);
      if(!vif.PRESETn) begin
        vif.master_cb.PSEL <= 0;
        vif.master_cb.PENABLE <= 0;
        vif.master_cb.PADDR <= 0;
        vif.master_cb.PWDATA <= 0;
        vif.master_cb.PWRITE <= 0;
        ps <= IDLE;
      end
      else begin
        case(ps)
          IDLE : begin
            vif.master_cb.PSEL <= 0;
	    vif.master_cb.PENABLE <= 0;
	    ps <= SETUP;
	    $display("[IDLE_t] :psel = %0h,penable = %0h,pready = %0h, at %0t",vif.master_cb.PSEL,vif.master_cb.PENABLE,vif.master_cb.PREADY,$time);
	  end

          SETUP : begin
	    vif.master_cb.PSEL <= 1'b1;
	    vif.master_cb.PENABLE <= 0;
	    vif.master_cb.PWRITE <= PWRITE;
	    if(PWRITE == 1'b1)
	      vif.master_cb.PWDATA <= PWDATA;
	    vif.master_cb.PADDR <= PADDR;
	    ps <= ACCESS;
	    $display("[SETUP_t] :psel = %0h,penable = %0h,pready = %0h, at %0t",vif.master_cb.PSEL,vif.master_cb.PENABLE,vif.master_cb.PREADY,$time); 
	  end

	  ACCESS : begin
	    vif.master_cb.PENABLE <= 1'b1;
	    wait(vif.master_cb.PREADY == 1'b1); //begin
	    //@(posedge vif.master_cb);
	    vif.master_cb.PENABLE <= 0;
	    $display("[access_t]  :psel = %0h,penable = %0h,pready = %0h, at %0t",vif.master_cb.PSEL,vif.master_cb.PENABLE,vif.master_cb.PREADY,$time);
	    if(transfer == 1'b1)begin
	      //vif.PENABLE <= 0;
	      ps <= SETUP;
	    end
	    else begin
                //vif.PENABLE <= 0;
	      vif.master_cb.PSEL <= 0;
	      ps <= IDLE;
	    end
	    break;

	    //end
	    $display("[ACCESS_end_t]  :psel = %0h,penable = %0h,pready = %0h, at %0t",vif.master_cb.PSEL,vif.master_cb.PENABLE,vif.master_cb.PREADY,$time);
           // break;
            
	  end
        endcase
      end
    end
    endtask
endclass

class sanity_test extends base_test;
  apb_slave_transaction trans;
  function new(virtual apb_slave_if.master vif);
    super.new(vif);
  endfunction


  task sanity_run();
    trans = new();
    $display("write task start");
    trans.randomize() with {PADDR == 8; PWRITE == 1;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,1'b0);
    $display("read task start");
    trans.randomize() with {PADDR == 8; PWRITE == 0;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,1'b0);
  endtask
endclass
