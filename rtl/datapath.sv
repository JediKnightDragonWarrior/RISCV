module datapath (
    input  logic        clk,
    input  logic        reset,
    
    // --- DIŞARIYLA (HAFIZA) OLAN BAĞLANTILAR ---
    output logic [31:0] PC,            // Program Counter çıkışı (IMEM 'A' girişine gider)
    input  logic [31:0] Instr,         // Komut (IMEM 'RD' çıkışından gelir)
    output logic [31:0] ALUResult,     // ALU hesaplama sonucu (DMEM 'A' Adres girişine gider)
    output logic [31:0] WriteData,     // Veri hafızasına yazılacak değer (DMEM 'WD' girişine gider)
    input  logic [31:0] ReadData,      // Veri hafızasından okunan değer (DMEM 'RD' çıkışından gelir)
    
    // --- KONTROL BİRİMİ İLE OLAN BAĞLANTILAR ---
    input  logic        PCSrc,         // PC Seçici (0: PC+4, 1: PCTarget)
    input  logic [1:0]  ResultSrc,     // Result MUX Seçici (0: ALUResult, 1: ReadData)
    input  logic        ALUSrc,        // ALU MUX Seçici (0: rs2, 1: ImmExt)
    input  logic [2:0]  ImmSrc,        // Sayı Uzatıcı Tipi 
    input  logic        RegWrite,      // Register File yazma izni (WE3)
    input  logic [2:0]  ALUControl,    // ALU işlem kontrolü
    output logic        Zero           // ALU'nun Zero bayrağı (Control Unit'e geri gider)
);

    // --- İÇ KABLOLAR ---
    logic [31:0] PCNext, PCPlus4, PCTarget;
    logic [31:0] ImmExt;
    logic [31:0] SrcA, SrcB;     
    logic [31:0] Result;         

    // ------------------------------------------
    // 1. PC ve Adres Hesaplamaları (Sol Kısım)
    // ------------------------------------------
    pc_reg pcreg_inst (
        .clk(clk),
        .reset(reset),
        .pc_next(PCNext),
        .pc(PC)
    );

    // Şemadaki alttaki toplayıcı (PCPlus4)
    assign PCPlus4 = PC + 32'd4;
    
    // Şemadaki sağ ortadaki toplayıcı (PCTarget)
    assign PCTarget = PC + ImmExt;

    // Şemadaki en soldaki PC MUX
    assign PCNext = PCSrc ? PCTarget : PCPlus4; 


    // ------------------------------------------
    // 2. Modüller ve Veri Yolu Ağı (Sağ Kısım)
    // ------------------------------------------
    
    // Extend (İşaret Uzatıcı)
    signextend signext_inst (
        .instr(Instr),           // Aslında şemadaki gibi [31:7] gönderilebilir ama modül içinden kırpıldı
        .immsrc(ImmSrc),
        .immext(ImmExt)
    );

    // Register File
    regfile rf_inst (
        .clk(clk),
        .we3(RegWrite),
        .a1(Instr[19:15]),
        .a2(Instr[24:20]),
        .a3(Instr[11:7]),
        .wd3(Result),            // En sağdaki MUX'tan dönen Result kablosu
        .rd1(SrcA),              // Şemadaki SrcA kablosu
        .rd2(WriteData)          // Şemadaki WriteData kablosu
    );

    // ALU MUX (Şemadaki ortadaki MUX)
    // 0: RD2 (WriteData), 1: ImmExt
    assign SrcB = ALUSrc ? ImmExt : WriteData;

    // ALU
    alu alu_inst (
        .a(SrcA),
        .b(SrcB),
        .alucontrol(ALUControl),
        .result(ALUResult),      // Şemadaki ALUResult kablosu
        .zero(Zero)              // Şemadaki Zero (Control Unit'e giden kablo)
    );

    // Result MUX (Şemadaki en sağdaki MUX)
    // 00: ALUResult, 01: ReadData, 10: PCPlus4 
    always_comb begin
        case(ResultSrc)
            2'b00: Result = ALUResult;
            2'b01: Result = ReadData;
            2'b10: Result = PCPlus4;
            default: Result = 32'b0;
        endcase
    end 

endmodule