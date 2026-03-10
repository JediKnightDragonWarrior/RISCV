module dmem 
//  represents RAM
//  sync write , asych read
//  byte addressing used
//  current just allow word acces 32 bit access(read and write)
(
    input  logic        clk,   
    input  logic        WE,   // write enable (active in sw) 

    // RD <=RAM[A]
    //RAM[A] <= WD

    input  logic [31:0] A,    // byte address is used     
    input  logic [31:0] WD,   
    output logic [31:0] RD
);

    logic [1:0] bit_type;      // lb:00 , lh:01 , lw:10
    assign bit_type = 2'b10;   // only lw supported yet

    logic [31:0] word;
    assign word = RAM[A[31:2]];

    // 4KB RAM , 2^12 bytes
    // word aligned addressing 
    logic [31:0] RAM [2**10-1:0];    
//    assign word = RAM[A[31:2]]; initializin RAM to 0 state



    always_ff @(posedge clk) 
        if (WE) 
            case (bit_type)
                2'b00 :  
                    case (A[1:0])
                        2'b00:  RAM[A[31:2]][7:0]   <= WD[7:0]; 
                        2'b01:  RAM[A[31:2]][15:8]  <= WD[7:0]; 
                        2'b10:  RAM[A[31:2]][23:16] <= WD[7:0]; 
                        2'b11:  RAM[A[31:2]][31:24] <= WD[7:0]; 
                        default: RAM[A[31:2]][7:0]   <= WD[7:0];
                    endcase
                2'b01 : 
                    if(A[1])    RAM[A[31:2]][31:16] <= WD[15:0]; 
                    else        RAM[A[31:2]][15:0]  <= WD[15:0];        
                2'b10 :         RAM[A[31:2]]        <= WD; 
                default:        RAM[A[31:2]]        <= RAM[A[31:2]];
            endcase        
                    

    always @(*)  
        case (bit_type)
            2'b00 : 
                case (A[1:0])
                    2'b00:  RD = {{24{word[7]}},word[7:0]};
                    2'b01:  RD = {{24{word[15]}},word[15:8]};
                    2'b10:  RD = {{24{word[23]}},word[23:16]};
                    2'b11:  RD = {{24{word[31]}},word[31:24]};
                    default:RD = {{24{word[7]}},word[7:0]};
                endcase
            2'b01 :         RD = A[1] ? {{16{word[31]}},word[31:16]} : {{16{word[15]}},word[15:0]};
            2'b10 :         RD = word; 
            default:        RD = word;
        endcase        

endmodule