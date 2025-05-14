//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//########################################  ASSERTIONS  ########################################
//----File Name   : apb_slave_assertion.sv
//----Description : Assertions are primarily used to validate the behavior of a design
//----------------- if the specs are violated then we can see failure in waveform
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

checker apb_slave_assertion;//#(parameter int addr_width = 32,data_width = 32,depth = 1023);
  //APB protocol signals
  logic PSEL;
  logic PWRITE;
  logic PENABLE;
  logic [31:0] PADDR;
  logic [31:0] PWDATA;
  logic [3:0] PSTRB;
  logic [31:0] PRDATA;
  logic PREADY;
  logic PSLVERR;
  logic PCLK;
  logic PRESETn;
  
  //this assertion stop if at posedge of clock value of PRESETn become low
  //this assertion check if at posedge of clock PSEL high then in next posedge PSEL & PENABLE both should be high
  property p1;
    @(posedge PCLK)
    disable iff (!PRESETn) PSEL |=> (PENABLE && PSEL);  //using property because using non overlapping operator 
  endproperty
  a1: assert property(p1) $info("assertion passed");

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
    (!PENABLE && !PREADY);
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
    disable iff (!PRESETn) (PENABLE && !PREADY) |-> ($stable(PADDR) && $stable(PWRITE) && $stable(PWDATA) && $stable(PSEL) && $stable(PENABLE) && $stable(PSTRB));
  endproperty
  a9: assert property(p9) $info("assertion passed");

endchecker

