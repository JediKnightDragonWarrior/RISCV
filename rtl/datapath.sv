module datapath 
/**
    module where all parts except controller are joined
**/
(
    // --- External Connections ---
    input  logic        clk,
    input  logic        reset,
    
    // --- Connections with Memories ---
    output logic [31:0] PC,            // goes to InstrMem
    input  logic [31:0] Instr,         
    output logic [31:0] ALUResult,     // goes to { RegFile WD3 as result of operation , Data Mem as Adress for sw operation }     
    output logic [31:0] WriteData,     // rd2 -> WD of DataMem 
    input  logic [31:0] ReadData,      // ED of DataMem -> WD3 of RegFile
    
    // --- Connections with Controller ---
    input  logic        PCSrc,         //   decides "pc_next" [0:pc+4 , 1:branch] 
    input  logic [1:0]  ResultSrc,     //   which data is to be written register file (0->alu,1->datamem,2->pc+4)
    input  logic        ALUSrc,        
    input  logic [2:0]  ImmSrc,        //   goes to signext , many instructions have different immediate value arrangement 
    input  logic        RegWrite,      //   enables write to register file
    input  logic [2:0]  ALUControl,    
    output logic        Zero           
);

    // --- Internal Wires ---
    logic [31:0] PCNext;        // combinational value for the next cycle state of pc 
    logic [31:0] PCPlus4;       // normal execution , next instruction , +4 
    logic [31:0] PCTarget;      // beq , jal . pc + immediate 
    logic [31:0] ImmExt;        // from signext
    logic [31:0] SrcA, SrcB;    // operands of ALU . SrcB either rd2 or imm.  
    logic [31:0] Result;        // to RegFile[A3] <= WD3(Result)


    // ------------------------------------------
    // 1.           PC 
    // ------------------------------------------
    assign PCPlus4 = PC + 32'd4;
    assign PCTarget = PC + ImmExt;
    assign PCNext = PCSrc ? PCTarget : PCPlus4; 

    pc_reg pc(
        .clk(clk),
        .reset(reset),
        .PCNext(PCNext),
        .pc(PC)
    );

    // ------------------------------------------
    // 2. Modules and Datapath Network
    // ------------------------------------------
    
    // Immediate Generator , Sign Extender
    signextend se(
        .Instr(Instr[31:0]),           
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );

    // Register File
    regfile rf(
        .clk(clk),
        .WE3(RegWrite),
        .A1(Instr[19:15]),
        .A2(Instr[24:20]),
        .A3(Instr[11:7]),
        .WD3(Result),            
        .RD1(SrcA),              
        .RD2(WriteData)          
    );

    // ALU MUX 
    assign SrcB = ALUSrc ? ImmExt : WriteData;

    // ALU
    alu alu_inst(
        .ALUControl(ALUControl),
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALUResult(ALUResult),      // Şemadaki ALUResult kablosu
        .Zero(Zero)              // Şemadaki Zero (Control Unit'e giden kablo)
    );

    // Result MUX 
    always_comb 
        case(ResultSrc)
            2'b00:      Result = ALUResult;
            2'b01:      Result = ReadData;
            2'b10:      Result = PCPlus4;
            default:    Result = '0;
        endcase

endmodule