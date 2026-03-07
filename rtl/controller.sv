module controller (
    input  logic [6:0] op,         // Komutun 6:0 bitleri (Opcode)
    input  logic [2:0] funct3,     // Komutun 14:12 bitleri
    input  logic       funct7b5,   // Komutun 30. biti (ADD/SUB veya SRA/SRL vb. ayrımı için)
    
    // Datapath ve Hafıza İçin Kontrol Sinyalleri
    output logic       regwrite,   // Register File yazma izni (we3)
    output logic [2:0] immsrc,     // Sign Extend tipi (000:I, 001:S, 010:B, 011:J, 100:U)
    output logic       alusrc,     // ALU'nun B girişini seçer (0: rd2, 1: immext)
    output logic       memwrite,   // Data Memory (Veri Hafızası) yazma izni
    output logic [1:0] resultsrc,  // Register File'a hangi veri yazılacak? (00: ALU, 01: DataMem, 10: PC+4, 11: ImmExt)
    output logic       branch,     // Bu bir BEQ/B-Type komutu mu?
    output logic       jump,       // Bu bir JAL komutu mu?
    
    // ALU İçin Kontrol Sinyali
    output logic [2:0] alucontrol
);

    logic [1:0] aluop; // Main Decoder'dan ALU Decoder'a giden iç sinyal

    // ---------------------------------------------------------------- //
    // 1. ANA ÇÖZÜCÜ (MAIN DECODER)                                     //
    // Opcode'a bakarak temel yönlendirmeleri yapar.                    //
    // ---------------------------------------------------------------- //
    always_comb begin
        case (op)
            // R-Type (ADD, SUB, AND, OR, SLT vb.)
            7'b0110011: begin 
                regwrite  = 1;
                immsrc    = 3'bxxx; // R-tipinde Immediate(Sabit) sayı kullanılmaz!
                alusrc    = 0;      // rs2'den oku
                memwrite  = 0;
                resultsrc = 2'b00;  // ALU sonucunu yazmacına yaz
                branch    = 0;
                jump      = 0;
                aluop     = 2'b10;  // ALU, funct3 ve funct7'ye göre karar verecek
            end

            // I-Type ALU (ADDI, SLTI, ANDI vb.)
            7'b0010011: begin
                regwrite  = 1;
                immsrc    = 3'b000; // I-Type işaret uzatması
                alusrc    = 1;      // Immediate veriyi ALU'ya gönder
                memwrite  = 0;
                resultsrc = 2'b00;  // ALU sonucunu yazmacına yaz
                branch    = 0;
                jump      = 0;
                aluop     = 2'b10;  // R-Type gibi funct3'e göre işlem yap
            end

            // I-Type Load Word (LW)
            7'b0000011: begin
                regwrite  = 1;
                immsrc    = 3'b000;
                alusrc    = 1;      // Adres hesabı için (rs1 + imm)
                memwrite  = 0;
                resultsrc = 2'b01;  // RAM'den okunan veriyi yazmacına yaz
                branch    = 0;
                jump      = 0;
                aluop     = 2'b00;  // Toplama (ADD) yap
            end

            // S-Type Store Word (SW)
            7'b0100011: begin
                regwrite  = 0;      // Yazmaca (RegFile) geri yazma yok, çünkü RAM'e yazıyoruz
                immsrc    = 3'b001; // S-Type işaret uzatması
                alusrc    = 1;      // Adres hesabı için (rs1 + imm)
                memwrite  = 1;      // Data Memory'ye YAZ!
                resultsrc = 2'bxx;  // Önemsiz
                branch    = 0;
                jump      = 0;
                aluop     = 2'b00;  // Toplama (ADD) yap
            end

            // B-Type (BEQ vb.)
            7'b1100011: begin
                regwrite  = 0;
                immsrc    = 3'b010; // B-Type işaret uzatması
                alusrc    = 0;      // rs1 ve rs2 ALU'da karşılaştırılacak
                memwrite  = 0;
                resultsrc = 2'bxx;  // Önemsiz
                branch    = 1;      // Branch sinyali DataPath için 1
                jump      = 0;
                aluop     = 2'b01;  // Çıkarma (SUB) yap, eğer çıkan sonuç 0 ise "zero=1"
            end

            // J-Type Jump and Link (JAL)
            7'b1101111: begin
                regwrite  = 1;      // Geri dönebilmek için (ra yazmacına) yazma yap
                immsrc    = 3'b011; // J-Type uzatma
                alusrc    = 1'bx;   // ALU burada adres hesabı yapmadığı için önemsiz (DataPath kendi topluyor)
                memwrite  = 0;
                resultsrc = 2'b10;  // Dönüş adresini (PC+4) yazmacına yaz
                branch    = 0;
                jump      = 1;      // Jump sinyali DataPath için 1
                aluop     = 2'bxx;  // ALU önemsiz
            end

            // U-Type Load Upper Immediate (LUI)
            7'b0110111: begin
                regwrite  = 1;
                immsrc    = 3'b100; // U-Type Uzatma (12 sıfır)
                alusrc    = 1'bx;   // ALU kullanılmıyor
                memwrite  = 0;
                resultsrc = 2'b11;  // İstemciden gelen Uzatılmış Sayıyı Doğrudan Yaz (ImmExt -> RegFile)
                branch    = 0;
                jump      = 0;
                aluop     = 2'bxx;
            end

            // Default (Hatalı/Bilinmeyen Komut Güvenliği)
            default: begin
                regwrite  = 0;
                immsrc    = 3'b000;
                alusrc    = 0;
                memwrite  = 0;
                resultsrc = 2'b00;
                branch    = 0;
                jump      = 0;
                aluop     = 2'b00;
            end
        endcase
    end

    // ---------------------------------------------------------------- //
    // 2. ALU ÇÖZÜCÜ (ALU DECODER)                                      //
    // Main Decoder'dan gelen 'aluop', komutun funct3 ve funct7'sine    //
    // bakarak ALU'nun tam olarak ne yapacağına karar verir.            //
    // ---------------------------------------------------------------- //
    
    // Senin alu.sv dosyanın kontrol tablosuna göre:
    // 000: ADD, 001: SUB, 010: AND, 011: OR, 100: XOR, 101: SLT, 110: SLTU

    always_comb begin
        case (aluop)
            2'b00: alucontrol = 3'b000; // LW / SW: Her zaman Toplama (ADD)
            2'b01: alucontrol = 3'b001; // BEQ: Her zaman Çıkarma (SUB)
            2'b10: begin                // R-Type veya I-Type İşlemler (funct3'e bak)
                case (funct3)
                    3'b000: begin
                        // ADD mi yoksa SUB mu?
                        // op[5] bitinin 1 olması komutun R-tipi(0110011) olduğunu garantiye alır ve funct7b5 (30. bit) 1 ise çıkartmadır
                        if (op[5] & funct7b5) 
                            alucontrol = 3'b001; // Sadece R-Type SUB işlemi
                        else 
                            alucontrol = 3'b000; // I-Type ADDI veya R-Type ADD
                    end
                    3'b010: alucontrol = 3'b101; // SLT / SLTI
                    3'b011: alucontrol = 3'b110; // SLTU / SLTIU
                    3'b100: alucontrol = 3'b100; // XOR / XORI
                    3'b110: alucontrol = 3'b011; // OR / ORI
                    3'b111: alucontrol = 3'b010; // AND / ANDI
                    default: alucontrol = 3'b000; // Güvenlik durumu
                endcase
            end
            default: alucontrol = 3'b000;
        endcase
    end

endmodule
