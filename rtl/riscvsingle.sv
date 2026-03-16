module riscvsingle
//    connects two parts of processor [controller] + [datapath] => processor
(
    input  logic        clk, reset,
    input  logic [31:0] Instr,      //  IntructionMemory[PC]
    input  logic [31:0] ReadData,   

    output logic [31:0] PC,
    output logic        MemWrite,    //  enables write to data memory 
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData
);
    // signals between controller and datapath
    logic         PCSrc;
    logic [1:0]   ResultSrc;
    logic [3:0]   ALUControl;
    logic         ALUSrc;               //  decides "srcB" (second operand of alu) [0:rd2 , 1:Immediate]             
    logic [2:0]   ImmSrc;
    logic         RegWrite;             
    logic         Zero;                  

    controller c (
        .op(Instr[6:0]),
        .funct3(Instr[14:12]),
        .funct7b5(Instr[30]),
        .Zero(Zero),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .PCSrc(PCSrc),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl)
    );
    
    datapath d (
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .Instr(Instr),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .ReadData(ReadData),
        .PCSrc(PCSrc),
        .ResultSrc(ResultSrc),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl),
        .Zero(Zero)
    );

endmodule