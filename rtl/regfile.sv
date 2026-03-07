module regfile (
    input  logic        clk,   // Saat sinyali
    input  logic        WE3,   // Write Enable (Yazma İzni - Kontrol biriminden gelir)
    input  logic [4:0]  A1,    // rs1 adresi (5 bit, çünkü 2^5 = 32 yazmaç var)
    input  logic [4:0]  A2,    // rs2 adresi
    input  logic [4:0]  A3,    // rd adresi (Yazılacak yazmacın adresi)
    input  logic [31:0] WD3,   // Write Data (Yazılacak 32-bitlik veri)
    output logic [31:0] RD1,   // Read Data 1 (rs1'den okunan veri)
    output logic [31:0] RD2    // Read Data 2 (rs2'den okunan veri)
);

    // İşlemcinin hafıza dizisini (array) tanımlıyoruz: 32 adet, 32-bitlik değişken
    logic [31:0] rf [31:0];

    // --- SENKRON YAZMA (Saat vuruşu ile) ---
    // always_ff, SystemVerilog'a "Burada fiziksel Flip-Flop'lar üret" emrini verir.
    always_ff @(posedge clk) begin
        if (WE3) begin
            // x0'ı mühürlüyoruz: Sadece adres 0'dan farklıysa yazmaya izin ver!
            if (A3 != 5'b00000) begin
                rf[A3] <= WD3;
            end
        end
    end

    // --- ASENKRON OKUMA (Anında) ---
    // Adres geldiği gibi (clock beklemeden) veriyi çıkışa bas.
    // Eğer okunan adres 0 ise (x0), donanımsal olarak her zaman 0 ver.
    assign RD1 = (A1 != 5'b00000) ? rf[A1] : 32'b0;
    assign RD2 = (A2 != 5'b00000) ? rf[A2] : 32'b0;

endmodule