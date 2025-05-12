#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
################################  MAKEFILE  ##############################################
#----File Name   : makefile
#----Description : makefile is used to automate tasks like compile,simulate etc
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Define SystemVerilog package and testbench files
pkg_files = ../SV/sv_package.sv ../testcases/my_pkg.sv ../SVE/test_pkg.sv
path = ../top/tb.sv
sim = ../sim
log_files = *.vcd transcript *.wlf
# Default simulation parameters, can be overridden from command line
override wave ?= 0
override seed ?= 123
override testcase ?= sanity
override wait_state ?= 0
override no_of_wait_cycles ?= 3
override freq ?= 50   
# Directory to save logs, named using simulation parameters
log_dir = $(sim)/testcase$(testcase)_waitstate$(wait_state)_waitcycles$(no_of_wait_cycles)_seed$(seed) 
# Default target
all: compile simulate
# Compilation step
compile:
	@echo "Compiling..."
	@vlib work
	@vlog $(pkg_files) $(path) 
# Simulation step with or without waveform based on 'wave' variable
simulate: run_sim

ifeq ($(wave),1)
run_sim:
	@echo "Simulating with waves (seed = $(seed), testcase = $(testcase))"
	@vopt work.tb -o tb_opt +acc=rn
	@mkdir -p $(log_dir)
	@vsim -c -assertdebug -fsmdebug -coverage -msgmode both work.tb_opt \
		+$(testcase) +sv_seed=$(seed) +wait_state=$(wait_state) +no_of_wait_cycles=$(no_of_wait_cycles) \
		+freq=$(freq) -do "add wave -r /*; run -all"
	@mv $(log_files) $(log_dir) 
else
run_sim:
	@echo "Simulating without waves (seed = $(seed), testcase = $(testcase))"
	@vopt work.tb -o tb_opt +acc=rn
	@mkdir -p $(log_dir)
	@vsim -c -assertdebug -msgmode both work.tb_opt \
		+$(testcase) +sv_seed=$(seed) +wait_state=$(wait_state) +no_of_wait_cycles=$(no_of_wait_cycles) \
		+freq=$(freq) -do "run -all"
	@mv $(log_files) $(log_dir) 
endif
# Clean only the compiled library
clean:
	rm -rf work
# Clean compiled library and simulation output
clean_all:
	rm -rf work
	rm -rf $(sim)

