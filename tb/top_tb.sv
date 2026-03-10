`timescale 1ns/1ps

module top_tb();

logic        clk;
logic        reset;
logic [31:0] WriteData, DataAdr,PC;
logic        MemWrite;

// instantiate device to be tested
top dut(clk, reset, WriteData, DataAdr,PC, MemWrite);

// initialize test
initial
begin
    $monitor("pc: %d, alures: %d, WriteData: %d, MemWrite: %b", PC, DataAdr, WriteData, MemWrite);
    reset <= 1; # 22;
    reset <= 0;
    #300;
    $finish;
end
// generate clock to sequence tests
initial begin
    clk <= 1;
    forever  #5 clk <= ~clk;
end

// check results
always @(negedge clk)
begin
    /*
    if(MemWrite) begin
        if(DataAdr === 100 & WriteData === 25) begin
            $display("Simulation succeeded");
            #1;
            $finish;
        end
        else if (DataAdr !== 96) begin
            $display("Simulation failed");
            $finish;
        end
    end
    */
end





endmodule