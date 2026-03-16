module barrel_shifter (
    input  logic [1:0]  mode,
    input  logic [4:0]  shamt, 
    input  logic [31:0] Src,       //  operand1 always comes from rs1
    output logic [31:0] Result
);


    always_comb begin
        case (mode)
            2'b10: Result = Src << shamt;                                 //  sll                                                 
            2'b11: Result = Src >> shamt;                                 //  srl                                                 
            2'b00: Result = $signed(Src) >>> shamt;                       //  sra                                                
            default: Result = 'x;                                              //  none
        endcase
    end


/*

 

*/






    
endmodule