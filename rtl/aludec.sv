module aludec(
    // first three inputs are instruction info
    input  logic [1:0] ALUOp,       // category of alu operation
    input  logic       opb5,
    input  logic [2:0] funct3,
    input  logic       funct7b5,

    output logic [3:0] ALUControl   // specific operation of alu 
);

/** 
ALUOp table 
    00  :   lw,sw,jal
    01  :   beq
    10  :   aritmetic logic operations (R,I)
    11  :

ALUControl table
    0000 :   addition
    0001 :   subtraction
    0010 :   and
    0011 :   or
    0100 :   xor
    0101 :   slt

    0110 :   sll 
    0111 :   srl
    1000 :   sra
**/


always_comb
    case (ALUOp)
        2'b00:                          ALUControl = 4'b0000;             // lw,sw,jal    ->  addition
        2'b01:                          ALUControl = 4'b0001;             // beq      ->  subtraction
        2'b10: 
            case (funct3) // R-type or I-type ALU
                3'b000: 
                    if      (~opb5)     ALUControl = 4'b0000; // addi   -> addition
                    else if (funct7b5)  ALUControl = 4'b0001; // sub    -> subtraction
                    else                ALUControl = 4'b0000; // add    -> addition
                3'b001:                 ALUControl = 4'b0110; // sll     -> shift left logical
                3'b010:                 ALUControl = 4'b0101; // slt     -> signed comparison
                3'b100:                 ALUControl = 4'b0100; // xor     -> xor                   
                3'b101: 
                    if      (funct7b5)  ALUControl = 4'b1000; // sra     -> shift right arithmetic
                    else                ALUControl = 4'b0111; // srl     -> shift right logical                   
                3'b110:                 ALUControl = 4'b0011; // or      -> or  
                3'b111:                 ALUControl = 4'b0010; // and     -> and  
                default:                ALUControl =  'x;  
            endcase
        default:                        ALUControl =  'x;       
    endcase

endmodule