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

//in fsm when we use clk than we use non blocking assignment
//it is common method for driving master signals
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
	    // here we use do while loop instead of wait because it is easy
	    // for debug purpose
	    // suppose master drive psel at posedge clk and than same clk
	    // negedge pready become high than next posedge clk master drive
	    // penable low 
	    // in spec it is mandatory all things done at posedge clk
	    do begin
	      @(posedge vif.master_cb);
            end while(vif.master_cb.PREADY == 0); // loop rotate until condition is true
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

//it is basic test which perform write and read operation on same address 
//follows state like idle-setup-access-idle-setup-access
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

//it is basic test which performm write and read operation on same address
//follows state like idle-setup-access-setup-access

class sanity_pro_test extends base_test;
  apb_slave_transaction trans;
  function new(virtual apb_slave_if.master vif);
    super.new(vif);
  endfunction

  task sanity_pro_run();
    trans = new();
    $display("write task start");
    trans.randomize() with {PADDR == 10; PWRITE == 1;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,1'b1);
    $display("read task start");
    trans.randomize() with {PADDR == 10; PWRITE == 0;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,1'b0);
  endtask
endclass
