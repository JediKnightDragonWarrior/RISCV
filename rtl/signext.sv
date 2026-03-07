module signextend (
    input  logic [31:0] Instr,   // 32-bit Ham Komut (Instruction Memory'den gelen)
    input  logic [2:0]  ImmSrc,  // Kontrol biriminden gelen "Bu hangi tip komut?" sinyali
    output logic [31:0] ImmExt   // 32-bite uzatılmış, ALU'ya gitmeye hazır sayı
);

    // SystemVerilog'da {{N{bit}}} yapısı, o 'bit'i N kere kopyala (çoğalt) demektir.
    // Instr[31] her zaman işaret bitidir. Onu kopyalayarak sayıyı uzatıyoruz (Sign Extension).

    always_comb begin
        case (ImmSrc)
            // 000: I-Type (ADDI, LW vb.)
            // imm[11:0] kısımları 31 ile 20. bitler arasındadır.
            3'b000: ImmExt = { {20{Instr[31]}}, Instr[31:20] };

            // 001: S-Type (SW - Store Word)
            // imm ikiye bölünmüştür: Üst 7 bit (31:25) ve Alt 5 bit (11:7)
            3'b001: ImmExt = { {20{Instr[31]}}, Instr[31:25], Instr[11:7] };

            // 010: B-Type (BEQ - Branch)
            // Dallanma adresleri her zaman çift sayı olduğu için en alt bit her zaman 0'dır (1'b0).
            // Bitler performansı artırmak için karışıktır.
            3'b010: ImmExt = { {20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0 };

            // 011: J-Type (JAL - Jump)
            // Tıpkı B-Type gibi son bit 0'dır ama 20 bitlik devasa bir atlama menzili vardır.
            3'b011: ImmExt = { {12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0 };

            // 100: U-Type (LUI - Load Upper Immediate)
            // İşaret uzatması yapılmaz! 20 bitlik sayı doğrudan 32 bitin ÜST kısmına (31:12) yerleştirilir.
            // Alt 12 bit sıfırlarla doldurulur (12'b0).
            3'b100: ImmExt = { Instr[31:12], 12'b0 };

            // Güvenlik: Beklenmeyen bir durumda 0 ver
            default: ImmExt = 32'b0;
        endcase
    end

endmodule