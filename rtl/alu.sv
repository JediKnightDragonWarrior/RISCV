module alu (
    input  logic [31:0] SrcA,          // 1. İşlenen (Operand 1)
    input  logic [31:0] SrcB,          // 2. İşlenen (Operand 2)
    input  logic [2:0]  ALUControl,    // Ne yapılacağını söyleyen 3-bitlik kontrol sinyali
    output logic [31:0] ALUResult,     // 32-bit Hesaplama Sonucu
    output logic        Zero           // BEQ (Branch if Equal) için kritik bayrak
);

    // ALU kombinasyonel bir devredir. Bu yüzden always_comb kullanıyoruz.
    always_comb begin
        case (ALUControl)
            3'b000: ALUResult = SrcA + SrcB;                           // ADD
            3'b001: ALUResult = SrcA - SrcB;                           // SUB
            3'b010: ALUResult = SrcA & SrcB;                           // AND
            3'b011: ALUResult = SrcA | SrcB;                           // OR
            3'b100: ALUResult = SrcA ^ SrcB;                           // XOR
            3'b101: begin 
                // SLT (Signed Less Than - İşaretli Küçüktür) Arka Plan Mantığı:
                // 1. Durum: İşaretler (MSB, 31. bitler) farklıysa: Negatif olan sayı her zaman daha küçüktür. 
                //           Yani 'SrcA' negatif (1) ise sonuç 1 olur.
                // 2. Durum: İşaretler aynıysa: (SrcA - SrcB) işlemi yapılır. Taşma (overflow) ihtimali olmadığı için 
                //           çıkan sonucun 31. bitine (işaretine) bakılır. Eğer sonuç negatifse(1) 'SrcA < SrcB' doğrudur.
                if (SrcA[31] != SrcB[31]) begin
                    ALUResult = SrcA[31] ? 32'd1 : 32'd0;
                end else begin
                    ALUResult = (SrcA - SrcB)[31] ? 32'd1 : 32'd0;
                end
            end
            3'b110: ALUResult = (SrcA < SrcB) ? 32'd1 : 32'd0;                   // SLTU (Unsigned Less Than)
            default: ALUResult = 32'b0;                          // Güvenlik için default durum
        endcase
    end

    // Zero bayrağı: Sonuç tamamen sıfırsa 1 olur.
    // İşlemci "BEQ" (eşitse dallan) komutunu gördüğünde ALU'ya çıkarma (SUB) yaptırır. 
    // Eğer SrcA ve SrcB eşitse sonuç 0 çıkar, Zero bayrağı 1 olur ve işlemci dallanır!
    assign Zero = (ALUResult == 32'b0);

endmodule