//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//######################################  INTERFACE  ######################################
//----File Name   : interface.sv
//----Description : interface can be re-used for other projects Also it becomes easier to connect with the DUT and other verification components.
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
interface apb_slave_if #(parameter int addr_width = 32, data_width = 32)(input logic PCLK,PRESETn);
  //APB protocol signals
  logic PSEL;
  logic PWRITE;
  logic PENABLE;
  logic [addr_width-1:0] PADDR;
  logic [data_width-1:0] PWDATA;
  logic [(data_width/8)-1:0] PSTRB;
  logic [data_width-1:0] PRDATA;
  logic PREADY;
  logic PSLVERR;
  //enum to design FSM
  typedef enum logic [1:0]{IDLE,SETUP,ACCESS}state_t;
  state_t ps;

  //State switch logic
  assign ps = (PSEL == 1'b1) ? (PENABLE == 1'b1) ? ACCESS : SETUP : IDLE;

//if we write #0 or #1 in both case we get ynchronization
//but i think #0 is good because we can check values on posedge or negedge
//if we not use default line then it act as #0 delay for output and #1 step for input

  //clocking block for slave
  clocking slave_cb @(posedge PCLK);
    default input #0 output #0;
    input PADDR,PSEL,PENABLE,PWRITE,PWDATA,PSTRB;
    output PRDATA,PREADY,PSLVERR;
  endclocking:slave_cb
 
  //clocking block for monitor
	    // here we use do while loop instead of wait because it is easy
	    // for debug purpose
	    // suppose master drive psel at posedge clk and than same clk
	    // negedge pready become high than next
  clocking monitor_cb @(posedge PCLK);
    default input #0;
    input PENABLE,PWRITE,PSEL,PWDATA,PADDR,PREADY,PRDATA,PSLVERR,PSTRB;
  endclocking:monitor_cb

  //clocking block for master
  clocking master_cb @(posedge PCLK);
    default input #0 output #0;
    input PRDATA,PREADY,PSLVERR;
    output PSEL,PENABLE,PWRITE,PWDATA,PADDR,PSTRB;
  endclocking

  //modports for slave,monitor and master
  modport slave (clocking slave_cb,input PCLK,PRESETn,output ps);
  modport master(clocking master_cb,input PCLK, PRESETn);
  modport monitor (clocking monitor_cb,input PCLK,PRESETn);

   //this assertion stop if at posedge of clock value of PRESETn become low
  //this assertion check if at posedge of clock PSEL high then in next posedge PSEL & PENABLE both should be high
 /* property p1;
    @(posedge PCLK)
    disable iff (!PRESETn) PSEL |=> (PENABLE && PSEL);  //using property because using non overlapping operator 
  endproperty
  a1: assert property(p1) $info("assertion passed");*/

  //this assertion stop if at posedge of clock value of PRESETn become low
  //this assertion check if at posedge of clock PWRITE is low then in same posedge of clock PSTRB must be zero
  property p2;
    @(posedge PCLK)
    disable iff (!PRESETn) !PWRITE |-> PSTRB == 0;
  endproperty
  a2: assert property(p2) $info("assertion passed");
  
  //this assertion stop if at posedge of clock value of PRESETn become low
  //this assertion check if at posedge of clock PSEL,PENABLE and PREADY high then in next posedge of clock PENABLE and PREADY must be low
  sequence seq_1;
    (PSEL && PENABLE && PREADY);
  endsequence
  sequence seq_2;
    (!PENABLE);
  endsequence
  property p3;
    disable iff (!PRESETn) @(posedge PCLK) seq_1 |=> seq_2;
  endproperty
  a3: assert property(p3) $info("assertion passed");
  
  //this assertion check when PSEL is low then PENABLE must be low irrespective of clock and reset 
  property p4;
    @(posedge PCLK)
    !PSEL |-> !PENABLE;
  endproperty
  a4: assert property(p4) $info("assertion passed");
  
   
  //this assertion stop if at posedge of clock value of PRESETn become low
  //this assertion check if at posedge of clock PSEL asserted then PADDR, PWRITE and PWDATA must be valid
  property p5;
    @(posedge PCLK)
    disable iff (!PRESETn) PSEL |-> ($isunknown(PADDR) || $isunknown(PWRITE) || $isunknown(PWDATA)) == 0;
  endproperty
  a5: assert property(p5) $info("assertion passed");

   
  //this assertion stop if at posedge of clock value of PRESETn become low
  //this assertion check if at posedge of clock PSEL and PENABLE high then PREADY must be valid
  property p6;
    disable iff (!PRESETn) @(posedge PCLK) (PSEL && PENABLE) |-> $isunknown(PREADY) == 0;
  endproperty
  a6: assert property(p6) $info("assertion passed");

  //this assertion stop if at posedge of clock value of PRESETn become low
  //this assertion check if at posedge of clock PSEL,PENABLE and PREADY high then PRDATA must be valid
  property p7;
    disable iff (!PRESETn) @(posedge PCLK) (PSEL && PENABLE && PREADY) |-> $isunknown(PRDATA) == 0;
  endproperty
  a7: assert property(p7) $info("assertion passed");

  //this assertion stop if at posedge of clock value of PRESETn become low
  //this assertion check in access state if PADDR out of bound then PSLVERR must be high
  property p8;
    @(posedge PCLK)
    disable iff (!PRESETn) (PSEL && PENABLE && PREADY && PADDR>1023) |-> PSLVERR;
  endproperty
  a8: assert property(p8) $info("assertion passed");

  //this assertion stop if at posedge of clock value of PRESETn become low
  //this assertion check when FSM in ACCESS state listed signals are stable
  //The following signals remain unchanged while PREADY remains LOW:
  property p9;
    @(posedge PCLK)
    disable iff (!PRESETn) (PENABLE && !PREADY) |-> ($stable(PADDR) && $stable(PWRITE) && $stable(PWDATA) && $stable(PSEL) && $stable(PSTRB));
  endproperty
  a9: assert property(p9) $info("assertion passed");





endinterface
