`timescale 1ns / 1ps

module alu_tb;

    // Girişler
    reg [31:0] a;
    reg [31:0] b;
    reg [2:0]  alucontrol;

    // Çıkışlar
    wire [31:0] result;
    wire        zero;

    // ALU modülünü instantiate et
    alu dut (
        .a(a),
        .b(b),
        .alucontrol(alucontrol),
        .result(result),
        .zero(zero)
    );

    initial begin
        $display("ALU Testbench Başlatılıyor...");

        // Test 1: ADD (10 + 5 = 15)
        a = 32'd10;
        b = 32'd5;
        alucontrol = 3'b000;
        #10; // Kısa bekleme
        $display("ADD: a=%d, b=%d, result=%d, zero=%b (Beklenen: 15, 0)", a, b, result, zero);

        // Test 2: SUB (10 - 5 = 5)
        a = 32'd10;
        b = 32'd5;
        alucontrol = 3'b001;
        #10;
        $display("SUB: a=%d, b=%d, result=%d, zero=%b (Beklenen: 5, 0)", a, b, result, zero);

        // Test 3: AND (10 & 5 = 0)
        a = 32'd10; // 1010
        b = 32'd5;  // 0101
        alucontrol = 3'b010;
        #10;
        $display("AND: a=%d, b=%d, result=%d, zero=%b (Beklenen: 0, 1)", a, b, result, zero);

        // Test 4: OR (10 | 5 = 15)
        a = 32'd10;
        b = 32'd5;
        alucontrol = 3'b011;
        #10;
        $display("OR: a=%d, b=%d, result=%d, zero=%b (Beklenen: 15, 0)", a, b, result, zero);

        // Test 5: XOR (10 ^ 5 = 15)
        a = 32'd10;
        b = 32'd5;
        alucontrol = 3'b100;
        #10;
        $display("XOR: a=%d, b=%d, result=%d, zero=%b (Beklenen: 15, 0)", a, b, result, zero);

        // Test 6: SLT (Signed Less Than) (-5 < 10 = 1)
        a = -32'd5;
        b = 32'd10;
        alucontrol = 3'b101;
        #10;
        $display("SLT: a=%d, b=%d, result=%d, zero=%b (Beklenen: 1, 0)", a, b, result, zero);

        // Test 7: SLTU (Unsigned Less Than) (-5 < 10 = 0)
        a = -32'd5;
        b = 32'd10;
        alucontrol = 3'b110;
        #10;
        $display("SLTU: a=%d, b=%d, result=%d, zero=%b (Beklenen: 0, 1)", a, b, result, zero);

        // Test 8: Zero Flag Test (10 - 10 = 0, zero=1)
        a = 32'd10;
        b = 32'd10;
        alucontrol = 3'b001;
        #10;
        $display("ZERO: a=%d, b=%d, result=%d, zero=%b (Beklenen: 0, 1)", a, b, result, zero);

        // Test 9: Default case (alucontrol=111)
        a = 32'd10;
        b = 32'd5;
        alucontrol = 3'b111;
        #10;
        $display("DEFAULT: a=%d, b=%d, result=%d, zero=%b (Beklenen: 0, 1)", a, b, result, zero);

        $display("ALU Testbench Tamamlandı.");
        $finish;
    end

endmodule