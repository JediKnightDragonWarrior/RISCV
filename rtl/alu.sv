module alu (
    input  logic [31:0] a,          // 1. İşlenen (Operand 1)
    input  logic [31:0] b,          // 2. İşlenen (Operand 2)
    input  logic [2:0]  alucontrol, // Ne yapılacağını söyleyen 3-bitlik kontrol sinyali
    output logic [31:0] result,     // 32-bit Hesaplama Sonucu
    output logic        zero        // BEQ (Branch if Equal) için kritik bayrak
);

    // ALU kombinasyonel bir devredir. Bu yüzden always_comb kullanıyoruz.
    always_comb begin
        case (alucontrol)
            3'b000: result = a + b;                           // ADD
            3'b001: result = a - b;                           // SUB
            3'b010: result = a & b;                           // AND
            3'b011: result = a | b;                           // OR
            3'b100: result = a ^ b;                           // XOR
            3'b101: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT (Signed Less Than)
            3'b110: result = (a < b) ? 32'd1 : 32'd0;                   // SLTU (Unsigned Less Than)
            default: result = 32'b0;                          // Güvenlik için default durum
        endcase
    end

    // Zero bayrağı: Sonuç tamamen sıfırsa 1 olur.
    // İşlemci "BEQ" (eşitse dallan) komutunu gördüğünde ALU'ya çıkarma (SUB) yaptırır. 
    // Eğer A ve B eşitse sonuç 0 çıkar, Zero bayrağı 1 olur ve işlemci dallanır!
    assign zero = (result == 32'b0);

endmodule