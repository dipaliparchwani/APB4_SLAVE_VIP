path = /home/intern/Documents/APB5_slave_project/tb/tb.sv
sim = /home/intern/Documents/APB5_slave_project/sim
vcd = $(sim)/*.vcd
transcript = $(sim)/transcript
wlf = $(sim)/*.wlf

all: compile simulate 
compile:
	@echo $@ compiling
	 vlog $(path)
simulate:
	@echo $@ simulating
	 vopt work.$(path)_top_module -o tb_opt +acc=arn
	 vsim -asertdebug -msgmode both work.tb_opt
clean:
	rm -f $(sim)

