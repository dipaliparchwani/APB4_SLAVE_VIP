pkg_files = ../SV/sv_package.sv ../testcases/my_pkg.sv ../SVE/test_pkg.sv
path = ../top/tb.sv
sim = ../sim
log_files = *.vcd transcript *.wlf

override wave ?= 0
override seed ?= 123
override testcase ?= sanity
override wait_state ?= 0
override no_of_wait_cycles ?= 3
override freq ?= 50

log_dir = $(sim)/$(seed)_$(testcase)_$(wait_state)_$(no_of_wait_cycles)

all: compile simulate

compile:
	@echo "Compiling..."
	@vlib work
	@vlog $(pkg_files) $(path) +acc +cover

simulate: run_sim

ifeq ($(wave),1)
run_sim:
	@echo "Simulating with waves (seed = $(seed), testcase = $(testcase))"
	@vopt work.tb -o tb_opt +acc=rn
	@mkdir -p $(log_dir)
	@vsim -c -assertdebug -fsmdebug -coverage -msgmode both work.tb_opt +$(testcase) -sv_seed $(seed) +wait_state=$(wait_state) +no_of_wait_cycles=$(no_of_wait_cycles) +freq=$(freq) -do "add wave -r /*; run -all"
	@mv $(log_files) $(log_dir) 
else
run_sim:
	@echo "Simulating without waves (seed = $(seed), testcase = $(testcase))"
	@vopt work.tb -o tb_opt +acc=rn
	@mkdir -p $(log_dir)
	@vsim -c -assertdebug -msgmode both work.tb_opt +$(testcase) -sv_seed $(seed) +wait_state=$(wait_state) +no_of_wait_cycles=$(no_of_wait_cycles) +freq=$(freq)  -do "run -all"
	@mv $(log_files) $(log_dir) 
endif

clean:
	rm -rf work

clean_all:
	rm -rf work
	rm -rf $(sim)

