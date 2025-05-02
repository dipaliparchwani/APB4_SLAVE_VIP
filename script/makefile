pkg_files = ../SV/sv_package.sv ../testcases/my_pkg.sv ../SVE/test_pkg.sv
path = ../top/tb.sv
sim = ../sim/
log += *.vcd
log += transcript
log += *.wlf

override seed ?= 123;
override testcase ?= sanity
override wait_state ?= 0;
override no_of_wait_cycles ?= 5;

all: compile simulate_wave

compile:
	@echo "compiling"
	@vlog $(pkg_files) $(path)

simulate: 
	@echo "simulating with seed = $(seed) and testcase = $(testcase)"
	@vopt work.tb -o tb_opt +acc=arn
	@vsim -assertdebug -msgmode both work.tb_opt $(testcase) $(seed) -do "run -all"
	@mv $(log) $(sim)


simulate_wave:
	@echo "simulating with seed = $(seed) and testcase = $(testcase)"
	@vopt work.tb -o tb_opt +acc=arn
	@vsim -assertdebug -msgmode both work.tb_opt  $(testcase) -sv_seed $(seed) $(wait_state) $(no_of_wait_cycles) -do "add wave -r /*; run -all"
	@mv $(log) $(sim)

clean:
	rm -rf work
clean_all:
	rm -rf work
	rm -rf $(sim)

