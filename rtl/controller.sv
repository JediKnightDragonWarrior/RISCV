module controller
/**
    connects two parts of controller [maindec] + [aludec] => controller
    determines " pc source "
**/
(
    // first three inputs are instruction info
    input  logic [6:0] op,              // opcode
    input  logic [2:0] funct3,          // funct3
    input  logic       funct7b5,        // 5th bit of funct7

    input  logic       Zero,            //  alu zero flag for beq : A - B =? 0 
    output logic [1:0] ResultSrc,       
    output logic       MemWrite,               
    output logic       PCSrc,           
    output logic       ALUSrc,          
    output logic       RegWrite,        
    output logic [2:0] ImmSrc,          
    output logic [3:0] ALUControl       
);

    // intermediate signals comes from maindec
    logic [1:0] ALUOp;          //  goes to aludec       
    logic       Branch,Jump;    //  decides PCSrc 
    
    assign PCSrc = (Branch & Zero) | Jump;

    maindec md (
        .op(op),
        .ALUOp(ALUOp),
        .ResultSrc(ResultSrc),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .Branch(Branch),
        .Jump(Jump),
        .MemWrite(MemWrite),
        .RegWrite(RegWrite)
    );

    aludec ad (
        .opb5(op[5]),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .ALUOp(ALUOp),
        .ALUControl(ALUControl)
    );


endmodule