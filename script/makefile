#pkg_files = ../SV/interface.sv ../SV/sv_package.sv ../SVE/sve_package.sv
path = ../top/tb.sv
sim = ../sim/
log += *.vcd
log += transcript
log += *.wlf

all: compile simulate 
compile:
	@echo "compiling"
	@vlog $(path)
simulate:
	@echo "simulating"
	@vopt work.tb -o tb_opt +acc=arn
	@vsim -assertdebug -msgmode both work.tb_opt -do "add wave -r /*; run -all"
	@mv $(log) $(sim)
clean:
	rm -rf $(sim)

