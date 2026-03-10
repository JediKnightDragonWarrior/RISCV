module aludec(
    // first three inputs are instruction info
    input  logic [1:0] ALUOp,       // category of alu operation
    input  logic       opb5,
    input  logic [2:0] funct3,
    input  logic       funct7b5,

    output logic [2:0] ALUControl   // specific operation of alu 
);

/** 
ALUOp table 
    00  :   lw,sw,jal
    01  :   beq
    10  :   aritmetic logic operations (R,I)
    11  :

ALUControl table
    000 :   addition
    001 :   subtraction
    010 :   and
    011 :   or
    100 :   xor
    101 :   slt
    110 :   
    111 :   
**/


always_comb
    case (ALUOp)
        2'b00:                          ALUControl = 3'b000;             // lw,sw,jal    ->  addition
        2'b01:                          ALUControl = 3'b001;             // beq      ->  subtraction
        2'b10: 
            case (funct3) // R-type or I-type ALU
                3'b000: 
                    if      (~opb5)      ALUControl = 3'b000; // addi   -> addition
                    else if (funct7b5)  ALUControl = 3'b001; // sub    -> subtraction
                    else                ALUControl = 3'b000; // add    -> addition
                3'b010:                 ALUControl = 3'b101; // slt     -> signed comparison
                3'b100:                 ALUControl = 3'b100; // xor     -> xor                   
                3'b110:                 ALUControl = 3'b011; // or      -> or  
                3'b111:                 ALUControl = 3'b010; // and     -> and  
                default:                ALUControl = 32'bx;  
            endcase
        default:                        ALUControl = 32'bx;       
    endcase

endmodule