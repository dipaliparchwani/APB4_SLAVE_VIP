import file_pkg::*;
/*----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	*****  *****   ****  *****   ****   ***    ****  *****   ****
	  *    *      *        *    *      *   *  *      *      *    
	  *    *****   ***     *    *      *****   ***   *****   *** 
	  *    *          *    *    *      *   *      *  *          *
	  *    *****  ****     *     ****  *   *  ****   *****  **** 	
//----FILE NAME   : test_lib.SV
//----Description : this file containts base test and various tests whic are
//----              extended from base test 
//----Objective   : main objective is to verify APB4 Slave VIP with help of
//----              various scenarios
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */

//it is base test class which is designed based on FSM to drive Master signals
class base_test;
  int count_t;   //test count
  virtual apb_slave_if.master vif; //virtual interface master clocking block used
  typedef enum logic [1:0]{IDLE,SETUP,ACCESS}state;  //enum for design FSM
  state ps = IDLE;   //initially state is IDLE

  function new(virtual apb_slave_if.master vif);  //this is new constructor of base test
    this.vif = vif;
  endfunction

  //in fsm when we use clk than we use non blocking assignment
  //it is common method for driving master signals
  task drive_run(bit PWRITE,bit[`addr_width-1:0]PADDR,bit[`data_width-1:0]PWDATA,bit[(`data_width/8)-1:0]PSTRB,bit transfer);
    forever begin
      @(posedge vif.master_cb);
      //when reset come then this block executes
      if(!vif.PRESETn) begin
	vif.master_cb.PSEL <= 0;
	vif.master_cb.PENABLE <= 0;
	vif.master_cb.PADDR <= 0;
	vif.master_cb.PWDATA <= 0;
	vif.master_cb.PWRITE <= 0;
	vif.master_cb.PSTRB <= 0;
        ps <= IDLE;
      end

      //when active low reset is high then ths block executes
      else begin
	//case statement check the state on each posedge and update states and executes code of corresponding state
        case(ps)
	  //in IDLE state it drive PSEL low
          IDLE : begin
            vif.master_cb.PSEL <= 0;
	    vif.master_cb.PENABLE <= 0;
	    ps <= SETUP;
	    $display("[IDLE_t] :|| [psel = %0h],[penable = %0h],[pready = %0h] ||, at %0t",vif.master_cb.PSEL,vif.master_cb.PENABLE,vif.master_cb.PREADY,$time);
	  end

          //in SETUP state it drive PSEL high and other signals which are inputs for slave
          SETUP : begin
	    vif.master_cb.PSEL <= 1'b1;
	    vif.master_cb.PENABLE <= 0;
	    vif.master_cb.PWRITE <= PWRITE;
	    if(PWRITE == 1'b1)
	      vif.master_cb.PWDATA <= PWDATA;
	    vif.master_cb.PADDR <= PADDR;
	    vif.master_cb.PSTRB <= PSTRB;
	    ps <= ACCESS;
	    $display("[SETUP_t] : || [psel = %0h],[penable = %0h],[pready = %0h],[PSTRB = %0h] ||, at %0t",vif.master_cb.PSEL,vif.master_cb.PENABLE,vif.master_cb.PREADY,vif.master_cb.PSTRB,$time); 
	  end
          
          //in ACCESS state it drive PENABLE high
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
            end while(vif.master_cb.PREADY == 0); // loop rotate until condition is true means until PREADY value is low
	    //when PREADY become high in next clock it drive PENABLE low because it use NBA 
	    vif.master_cb.PENABLE <= 0;
	    $display("[access_t]  : || [psel = %0h],[penable = %0h],[pready = %0h] ||, at %0t",vif.master_cb.PSEL,vif.master_cb.PENABLE,vif.master_cb.PREADY,$time);

	    //if next transfer then it move to SETUP state in next clock
	    if(transfer == 1'b1)begin
	      ps <= SETUP;
	    end
	    //if no transfer then it moves to IDLE state and drive PENABLE low in next clock because NBA
	    else begin
	      vif.master_cb.PSEL <= 0;
	      ps <= IDLE;
	    end
	    //loop rotate forever hence after complete ACCESS state to stop loop
	    break;

	    $display("[ACCESS_end_t]  : || [psel = %0h],[penable = %0h],[pready = %0h] ||, at %0t",vif.master_cb.PSEL,vif.master_cb.PENABLE,vif.master_cb.PREADY,$time);
            
	  end
        endcase
        $display("----------------------------------------------------------------------------------------------------------");
      end
    end
    endtask
endclass

//#########################################################################################################################
//it is basic test which perform write and read operation on same address to check data integrity 
//follows state like idle-setup-access-idle-setup-access
//inheritance is used to use property and methods of base test
//#########################################################################################################################
class sanity_test extends base_test;
  apb_slave_transaction trans;  //transaction class handle
  function new(virtual apb_slave_if.master vif);  //new constructor
    super.new(vif);
  endfunction
  //this testcase main logic
  task sanity_run();
    count_t = 0;  //initialize test count 0 at start
    trans = new();
    $display("write task start");
    trans.randomize() with {PADDR == 8; PWRITE == 1; PSTRB == 4'hf;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b0);
    count_t++;  //after calling drive_run method increse the count
    $display("read task start");
    trans.randomize() with {PADDR == 8; PWRITE == 0; PSTRB == 0;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b0);
    count_t++;
  endtask
endclass

//##########################################################################################################################
//it is basic test which perform write and read operation on same address to check data integrity with PSTRB feature 
//follows state like idle-setup-access-idle-setup-access
//inheritance is used to use property and methods of base test
//##########################################################################################################################

class sanity_test_strb extends base_test;
  apb_slave_transaction trans;  // transaction class handle
  function new(virtual apb_slave_if.master vif); //new constructor
    super.new(vif);  //callng parent class new method
  endfunction
  //this testcase main logic
  task sanity_strb_run();
    count_t = 0;  //initialize test count 0 at start
    trans = new();
    $display("write task start");
    trans.randomize() with {PADDR == 20; PWRITE == 1; PSTRB == 4'ha;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b0);
    count_t++;  //after calling drive_run method increse the count
    $display("read task start");
    trans.randomize() with {PADDR == 20; PWRITE == 0; PSTRB == 0;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b0);
    count_t++;
  endtask
endclass

//#########################################################################################################################
//it is basic test which performm write and read operation on same address to check data integrity
//follows state like idle-setup-access-setup-access
//inheritance is used to use property and methods of base test
//########################################################################################################################

class sanity_pro_test extends base_test;
  apb_slave_transaction trans;  //transaction class handle
  function new(virtual apb_slave_if.master vif);  //new constructor
    super.new(vif);  //calling parent class new method
  endfunction
  //this testcase main logic 
  task sanity_pro_run();
    count_t = 0;  //initialize test count 0 at start
    trans = new();
    $display("write task start");
    trans.randomize() with {PADDR == 10; PWRITE == 1; PSTRB == 4'hf;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
    count_t++;  //after calling drive_run method increse the count
    $display("read task start");
    trans.randomize() with {PADDR == 10; PWRITE == 0; PSTRB == 0;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b0);
    count_t++;
  endtask
endclass

//#########################################################################################################################
//it is basic test which performm write and read operation on same address to check data integrity with PSTRB feature
//follows state like idle-setup-access-setup-access
//inheritance is used to use property and methods of base test
//########################################################################################################################

class sanity_pro_strb_test extends base_test;
  apb_slave_transaction trans;  //transaction class handle
  function new(virtual apb_slave_if.master vif); //new constructor
    super.new(vif);  //calling parent class new method
  endfunction
  //this testcase main logic 
  task sanity_pro_strb_run();
    count_t = 0;  //initialize test count 0 at start
    trans = new();
    $display("write task start");
    trans.randomize() with {PADDR == 10; PWRITE == 1; PSTRB == 4'hb;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
    count_t++;  //after calling drive_run method increse the count
    $display("read task start");
    trans.randomize() with {PADDR == 10; PWRITE == 0; PSTRB == 0;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b0);
    count_t++;
  endtask
endclass

//#########################################################################################################################
//this is basic directed testcase which done back to back write and read operation 
//this testcase perform 5 pairs of write and read
//inheritance is used to use property and methods of base test
//########################################################################################################################

class directed_basic extends base_test;
  apb_slave_transaction trans;  //transaction class handle
  function new(virtual apb_slave_if.master vif);  //new constructor
    super.new(vif);  //calling parent class new method
  endfunction
  //this testcase main logic 
  task directed_basic_run();
    count_t = 0;  //initialize test count 0 at start
    trans = new();
    repeat(5) begin
      trans.rand_mode(1);
      trans.randomize() with {PWRITE == 1; PSTRB == 4'hf;};
      drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
      count_t++;  //after calling drive_run method increase the count
      trans.rand_mode(0);
      trans.PWRITE = 0; 
      trans.PSTRB = 4'h0;
      drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
      count_t++;
    end
  endtask
endclass

//#########################################################################################################################
//this is basic directed testcase which done back to back write and read operation with PSTRB feature
//this testcase perform 5 pairs of write and read
//inheritance is used to use property and methods of base test
//#########################################################################################################################

class directed_basic_strb extends base_test;
  apb_slave_transaction trans;  //transaction class handle
  function new(virtual apb_slave_if.master vif);  //new constructor 
    super.new(vif);  //calling parent class new method
  endfunction
  //this testcase main logic 
  task directed_basic_strb_run();
    count_t = 0;  //initialize test count 0 at start
    trans = new();
    repeat(5) begin
      trans.rand_mode(1);
      trans.randomize() with {PWRITE == 1;};
      drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
      count_t++;  //after calling drive_run method increase the count
      trans.rand_mode(0);
      trans.PWRITE = 0; 
      trans.PSTRB = 4'h0;
      drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
      count_t++;
    end
  endtask
endclass

//#########################################################################################################################
//this testcase check the PSLVERR feature by giving out of bound address range for read and write by disable constraint
//this is basic directed testcase which verify PSLVERR feature
//inheritance is used to use property and methods of base test
//#########################################################################################################################

class error_check extends base_test;
  apb_slave_transaction trans;  //transaction class handle
  function new(virtual apb_slave_if.master vif);  //new constructor 
    super.new(vif);  //calling parent class new method
  endfunction
  //this testcase main logic
  task error_check_run();
    count_t = 0;  //initialize test count 0 at start
    trans = new();
    trans.addr_control.constraint_mode(0);
    trans.randomize() with {PADDR == 2056; PWRITE == 1;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,4'hf,1'b0);
    count_t++;  //after calling drive_run method increase the count
    trans.randomize() with {PADDR == 2056; PWRITE == 0;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,4'h0,1'b0);
    count_t++;
  endtask
endclass

//###############################################################################################################################################
//this directed testcase first done write operation 20 times in given address range and then done read operation 20 times in given address range
//inheritance is used to use property and methods of base test
//###############################################################################################################################################

class directed_simultaneous extends base_test;
  apb_slave_transaction trans;  //transaction class handle
  function new(virtual apb_slave_if.master vif);  //new constructor
    super.new(vif);  //calling parent class new method
  endfunction
  //this testcase main logic
  task directed_simultaneous_run();
    count_t = 0;  //initialize test count 0 at start

    trans = new();
    //write operation
    repeat(20) begin
      trans.randomize() with {PWRITE == 1; PADDR>10; PADDR<40; PSTRB == 4'hf;};
      drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
      count_t++;  //after calling drive_run method increase the count
    end
    //read operation
    repeat(20) begin
      trans.randomize() with {PWRITE == 0; PADDR>10; PADDR<40;};
      drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
      count_t++;
    end
  endtask
endclass

//###############################################################################################################################################
//this directed testcase first done write operation 20 times in given address range and then done read operation 20 times in given address range
//it support the PSTRB feature
//inheritance is used to use property and methods of base test
//###############################################################################################################################################

class directed_simultaneous_strb extends base_test;
  apb_slave_transaction trans;  //transaction class handle
  function new(virtual apb_slave_if.master vif);  //new constructor
    super.new(vif);  //calling parent class new method
  endfunction
  //this testcase main logic
  task directed_simultaneous_strb_run();
    count_t = 0;   //initialize test count 0 at start
    trans = new();
    //write operation
    repeat(20) begin
      trans.randomize() with {PWRITE == 1; PADDR>10; PADDR<40;};
      drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
      count_t++;  //after calling drive_run method increase the count
    end
    //read operation
    repeat(20) begin
      trans.randomize() with {PWRITE == 0; PADDR>10; PADDR<40;};
      drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
      count_t++;
    end
  endtask
endclass

//#########################################################################################################################
//this directed testcase perform write operation 5 times on same address and then perform read operaton on that address
//this is verify by reading on that address we get which data is it last written data or not 
//inheritance is used to use property and methods of base test
//#########################################################################################################################

class directed_last_check extends base_test;
  apb_slave_transaction trans;  //transaction class handle
  function new(virtual apb_slave_if.master vif);  //new constructor
    super.new(vif);  //calling parent class new method
  endfunction
  //this testcase main logic
  task directed_last_check_run();
    count_t = 0;  //initialize test count 0 at start
    trans = new();
     //write operation
    repeat(5) begin
      trans.randomize() with {PWRITE == 1; PADDR == 19; PSTRB == 4'hf;};
      drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
      count_t++;  //after calling drive_run method increase the count
    end
     //read operation
    trans.randomize() with {PWRITE == 0; PADDR == 19;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
    count_t++;
  endtask
endclass

//#########################################################################################################################
//this directed testcase perform write operation 5 times on same address and then perform read operaton on that address
//this is verify by reading on that address we get which data is it last written data or not including PSTRB feature
////inheritance is used to use property and methods of base test
//#########################################################################################################################

class directed_last_check_strb extends base_test;
  apb_slave_transaction trans;   //transaction class handle
  function new(virtual apb_slave_if.master vif);   //new constructor
    super.new(vif);  //calling parent class new method
  endfunction
  //this testcase main logic
  task directed_last_check_strb_run();
    count_t = 0;  //initialize test count 0 at start
    trans = new();
    //write operation
    repeat(5) begin
      trans.randomize() with {PWRITE == 1; PADDR == 19;};
      drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
      count_t++;  //after calling drive_run method increase the count
    end
    //read operation
    trans.randomize() with {PWRITE == 0; PADDR == 19;};
    drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
    count_t++;
  endtask
endclass

//#########################################################################################################################
//this testcase first done write operation 20 times in given address range and then apply reset for some time and then done read operation 20 times in given address range
//to verify that in read operation after reset we get 0 data or not
//inheritance is used to use property and methods of base test
//#########################################################################################################################

class reset_on_fly extends base_test;
   apb_slave_transaction trans;  //transaction class handle
  function new(virtual apb_slave_if.master vif);  //new constructor
    super.new(vif);  //calling parent class new method
  endfunction
    //this testcase main logic
  task reset_on_fly_run();
    count_t = 0;  //initialize test count 0 at start
    trans = new();
    //write operation
    repeat(20) begin
      trans.randomize() with {PWRITE == 1; PADDR>10; PADDR<40;};
      drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
      count_t++;  //after calling drive_run method increase the count
    end
    //reset
    /*vif.PRESETn <= 1'b0;
    #20;
    vif.PRESETn = 1'b1;*/
    $display("check PRESETn = %0d",vif.PRESETn);
   //read operation
    repeat(20) begin
      trans.randomize() with {PWRITE == 0; PADDR>10; PADDR<40;};
      drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
      count_t++;
      $display("check PRESETn = %0d",vif.PRESETn);
    end
  endtask
endclass

//#########################################################################################################################
//this testcaseis a random testcase all things in this testcase are random it perform tootal 50 random operations
//inheritance is used to use property and methods of base test
//#########################################################################################################################

class random_test extends base_test;
  apb_slave_transaction trans;  //transaction class handle
  function new(virtual apb_slave_if.master vif);   //new constructor
    super.new(vif);  //calling parent class new method
  endfunction
   //this testcase main logic
  task random_test_run();
    count_t = 0;  //initialize test count 0 at start
    trans = new();
    repeat(50) begin
      trans.randomize();
      drive_run(trans.PWRITE,trans.PADDR,trans.PWDATA,trans.PSTRB,1'b1);
      count_t++;  //after calling drive_run method increase the count
    end
  endtask

endclass
