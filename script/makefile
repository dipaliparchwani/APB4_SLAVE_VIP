pkg_files = ../SV/sv_package.sv
path = ../top/tb.sv
sim = ../sim/
log += *.vcd
log += transcript
log += *.wlf

override seed ?= 123;
override testcase ?= sanity

all: compile simulate_wave

compile:
	@echo "compiling"
	@vlog $(pkg_files) $(path)

simulate: 
	@echo "simulating with seed = $(seed) and testcase = $(testcase)"
	@vopt work.tb -o tb_opt +acc=arn
	@vsim -assertdebug -msgmode both work.tb_opt -do "run -all"
	@mv $(log) $(sim)


simulate_wave:
	@echo "simulating with seed = $(seed) and testcase = $(testcase)"
	@vopt work.tb -o tb_opt +acc=arn
	@vsim -assertdebug -msgmode both work.tb_opt  $(testcase) $(seed) -do "add wave -r /*; run -all"
	@mv $(log) $(sim)

clean:
	rm -rf work
	rm -rf $(sim)

