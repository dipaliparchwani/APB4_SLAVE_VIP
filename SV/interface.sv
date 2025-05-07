import file_pkg::*;
interface apb_slave_if #(parameter int addr_width = 32, data_width = 32)(input logic PCLK,PRESETn);
  logic PSEL;
  logic PWRITE;
  logic PENABLE;
  logic [addr_width-1:0] PADDR;
  logic [data_width-1:0] PWDATA;
  logic [data_width/8] PSTRB;
  logic [data_width-1:0] PRDATA;
  logic PREADY;
  logic PSLVERR;
  typedef enum logic [1:0]{IDLE,SETUP,ACCESS}state_t;
  state_t ps;

  clocking slave_cb @(posedge PCLK);
//if we write #0 or #1 in both case we get ynchronization
//but i think #0 is good because we can check values on posedge or negedge
//if we not use default line then it act as #0 delay

    //default input #0 output #0;
    input PADDR,PSEL,PENABLE,PWRITE,PWDATA;
    output PRDATA,PREADY,PSLVERR;
  endclocking:slave_cb

  clocking monitor_cb @(posedge PCLK);
    //default input #0;
    input PENABLE,PWRITE,PSEL,PWDATA,PADDR,PREADY,PRDATA,PSLVERR;
  endclocking:monitor_cb

  clocking master_cb @(posedge PCLK);
    //default input #0 output #0;
    input PRDATA,PREADY,PSLVERR;
    output PSEL,PENABLE,PWRITE,PWDATA,PADDR;
  endclocking


	modport slave (clocking slave_cb,input PCLK,PRESETn,output ps);
        modport master(clocking master_cb,input PCLK,PRESETn);
	modport monitor (clocking monitor_cb,input PCLK,PRESETn);

endinterface
