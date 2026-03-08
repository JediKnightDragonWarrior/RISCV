# files
RTL = rtl/*.sv
TB  = tb/datapath_tb.sv

# output files
OUT = simv
WAVE = wave.vcd

# compile
compile:
	iverilog -g2012 $(TB) $(RTL) -o $(OUT)

# run simulation
run: compile
	vvp $(OUT)

# open waveform
wave: run
	gtkwave $(WAVE)

# clean generated files
clean:
	rm -f $(OUT) $(WAVE)