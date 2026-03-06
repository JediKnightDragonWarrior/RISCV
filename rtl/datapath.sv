module datapath (
    input  logic        clk,
    input  logic        reset,
    
    // Şimdilik dışarıdan (Kontrol Birimi ve ALU'dan) geldiğini varsaydığımız sinyaller:
    input  logic        zero,      // ALU'dan gelir: "Sayılar eşit mi?"
    input  logic        branch,    // Kontrol Biriminden gelir: "Bu bir BEQ komutu mu?"
    input  logic        jump,      // Kontrol Biriminden gelir: "Bu bir JAL komutu mu?"
    input  logic [31:0] immext,    // SignExtend modülünden gelir: Uzatılmış sayı
    
    // Instruction Memory'e (Komut Hafızasına) gidecek olan adres çıkışı:
    output logic [31:0] pc         
);

    // --- İÇ KABLOLAR (WIRES) ---
    logic [31:0] pc_next;
    logic [31:0] pc_plus_4;
    logic [31:0] pc_target;
    logic        pc_src;

    // --- 1. PC YAZMACI (HAFIZA) ---
    // Daha önce yazdığımız pc_reg modülünü buraya çağırıp kablolarını bağlıyoruz.
    pc_reg pcreg_inst (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next), // Aşağıda hesapladığımız değeri PC'nin girişine veriyoruz
        .pc(pc)            // PC'nin içinden çıkan güncel adresi alıyoruz
    );

    // --- 2. HESAPLAYICILAR (ADDERS) ---
    // Standart ilerleme: Her komut 4 byte olduğu için PC sürekli 4 artar
    assign pc_plus_4 = pc + 32'd4;

    // Atlama/Dallanma hedefi: Anlık adres ile uzatılmış sayıyı (offset) topla
    assign pc_target = pc + immext;

    // --- 3. KARAR VE YÖNLENDİRME (MUX) ---
    // Eğer (Jump ise) VEYA (Branch komutuysa VE ALU "eşit" dediyse) pc_src 1 olur.
    assign pc_src = jump | (branch & zero);

    // MUX: pc_src 1 ise hedefe atla, 0 ise 4 fazlasına normal devam et.
    assign pc_next = pc_src ? pc_target : pc_plus_4;

    // İLERİDE BURAYA NELER EKLENECEK?
    // - ALU modülünü buraya çağıracağız
    // - Register File modülünü buraya çağıracağız
    // - Sign Extend modülünü buraya çağıracağız ve aralarındaki kabloları bağlayacağız.

endmodule