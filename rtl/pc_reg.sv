module pc_reg (
    input  logic        clk,      // Saat sinyali (İşlemcinin kalp atışı)
    input  logic        reset,    // Asenkron Sıfırlama (1 olduğunda PC 0'a döner)
    input  logic [31:0] PCNext,   // Gelecek saat vuruşunda gidilecek yeni adres
    output logic [31:0] PC        // İşlemcinin ŞU AN bulunduğu adres
);

    // Asenkron resetli 32-bit D-Flip-Flop yapısı
    // Sadece saatin yükselen kenarında VEYA reset pini 1 olduğunda tetiklenir.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 32'h00000000;   // Reset gelirse adresi sıfırla (Boot adresi)
        end
        else begin
            PC <= PCNext;         // Gelmezse hesaplanan yeni adresi içine al
        end
    end

endmodule