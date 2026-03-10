module top
(
    input logic clk, reset,

    // Below output ports for observing data memory in testbench
    output logic [31:0] WriteData, DataAdr,PC,
    output logic MemWrite
);

logic [31:0]  Instr, ReadData;

// instantiate processor and memories
riscvsingle rvsingle(
    .clk(clk),
    .reset(reset),
    .PC(PC),
    .Instr(Instr),
    .MemWrite(MemWrite),
    .ALUResult(DataAdr),
    .WriteData(WriteData),
    .ReadData(ReadData)
);

imem imem(
    .a(PC),
    .rd(Instr)
);

dmem dmem(
    .clk(clk),
    .WE(MemWrite),
    .A(DataAdr),
    .WD(WriteData),
    .RD(ReadData)
);

endmodule