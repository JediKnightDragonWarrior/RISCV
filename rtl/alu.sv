module alu (
    input  logic [3:0]  ALUControl, //  specific operation of alu    
    input  logic [31:0] SrcA,       //  operand1 always comes from rs1
    input  logic [31:0] SrcB,       //  operand2 from rs2 or Imm   

    output logic [31:0] ALUResult,     
    output logic        Zero        //  if ALUResult is zero , used for beq            
);
    
    assign Zero = (ALUResult == 32'b0);

    always_comb begin
        case (ALUControl)
            4'b0000: ALUResult = SrcA + SrcB;                                       //  ADD
            4'b0001: ALUResult = SrcA - SrcB;                                       //  SUB
            4'b0010: ALUResult = SrcA & SrcB;                                       //  AND
            4'b0011: ALUResult = SrcA | SrcB;                                       //  OR
            4'b0100: ALUResult = SrcA ^ SrcB;                                       //  XOR
            4'b0101: ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 32'd1 : 32'd0;   //  slt                                                 
            4'b0110: ALUResult = shift_out;                                         //  sll                                                 
            4'b0111: ALUResult = shift_out;                                         //  srl                                                 
            4'b1000: ALUResult = shift_out;                                         //  sra                                                 
            default: ALUResult = 'x;                                                //  none
        endcase
    end

    logic   [1:0]   shamt;
    logic   [31:0]  shift_out;


    barrel_shifter sh(
        .mode(ALUControl[1:0]),
        .shamt(SrcB[4:0]),
        .Src(SrcA),
        .Result(shift_out)
    );







    


endmodule