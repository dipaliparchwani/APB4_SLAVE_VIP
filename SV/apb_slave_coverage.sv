//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//#########################################  COVERAGE  #########################################
//----File Name   : apb_slave_coverage.sv
//----Description : measure the completeness and progress of verification process
//----------------- it measure how well all functionalities cover by testbench
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class apb_slave_coverage;
  apb_slave_transaction tr;
  function new(apb_slave_transaction tr);
    this.tr = tr;
    tr = new();
  endfunction

  covergroup cg_apb_slave;
    cp1: coverpoint tr.PADDR {bins b1 = {8,10,12,14};
                           bins b2 = {[0:500]};
			   bins b3 = {501,32'hffffffff};
                          }
    cp2: coverpoint tr.PWDATA {bins b1 = {0,[1:1900]};
                            bins b2 = {[2000:200000]};
			    bins b3 = {200000,32'hffffffff};
			   }
    cp3: coverpoint tr.PRDATA {bins b1 = {0,[1:1900]};
                            bins b2 = {[2000:200000]};
			    bins b3 = {200000,32'hffffffff};
			   }
    cp4: coverpoint tr.PSTRB {bins b1 = {0,15};
	                   bins b2[3] = {[1:7]};
			   bins b3[2] = {[8:14]};
			  }
    cp5: coverpoint tr.PWRITE {bins b1 = (1=>0);
                               bins b2 = (0=>1);}
    cp6: coverpoint tr.PSLVERR;
  endgroup : cg_apb_slave

  /*task samplecov(apb_slave_transaction tr);
	  this.tr= tr;
	  cg_apb_slave.sample();
  endtask*/


endclass
