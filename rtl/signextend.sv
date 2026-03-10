module signextend 
//  extends immediate values in instruction to 32-bit (why ? : alu uses 32 bits operands)
(
    input  logic [31:0] Instr,   // from IntrMEM[PC] 
    input  logic [2:0]  ImmSrc,  
    output logic [31:0] ImmExt   // goes to srcB if ALUSrc == 1 (if instruction uses immediate in alu) 
);

    always_comb
        case (ImmSrc)
            3'b000:  ImmExt = { {20{Instr[31]}}, Instr[31:20] };                                 // I-Type (ADDI, LW vb.)
            3'b001:  ImmExt = { {20{Instr[31]}}, Instr[31:25], Instr[11:7] };                    // S-Type (SW - Store Word)
            3'b010:  ImmExt = { {20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0 };    // B-Type (BEQ - Branch)
            3'b011:  ImmExt = { {12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0 };  // J-Type (JAL - Jump)
            3'b100:  ImmExt = { Instr[31:12], 12'b0 };                                           // U-Type (LUI - Load Upper Immediate)
            default: ImmExt = 'x;
        endcase

endmodule