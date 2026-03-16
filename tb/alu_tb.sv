`timescale 1ns / 1ps

module alu_tb;

    // Girişler
    reg [31:0] a;
    reg [31:0] b;
    reg [3:0]  alucontrol;

    // Çıkışlar
    wire [31:0] result;
    wire        zero;

    // ALU modülünü instantiate et
    alu dut (
        .SrcA(a),
        .SrcB(b),
        .ALUControl(alucontrol),
        .ALUResult(result),
        .Zero(zero)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, alu_tb);

        $display("ALU Testbench Başlatılıyor...");

        // Test 1: ADD (10 - 1 = 9)
        a = 32'd10;
        b = -32'd1;
        alucontrol = 4'b0000;
        #10; // Kısa bekleme
        $display("ADD: a=%d, b=%d, result=%0d, zero=%b (Beklenen: 15, 0)", a, b, $signed(result), zero);

        // Test 2: SUB (-10 - 5 = -15)
        a = -32'd10;
        b = 32'd5;
        alucontrol = 4'b0001;
        #10;
        $display("SUB: a=%d, b=%d, result=%0d, zero=%b (Beklenen: -15, 0)", a, b, $signed(result), zero);

        // Test 3: AND (10 & 5 = 0)
        a = 32'd10; // 1010
        b = 32'd5;  // 0101
        alucontrol = 4'b0010;
        #10;
        $display("AND: a=%d, b=%d, result=%0d, zero=%b (Beklenen: 0, 1)", a, b, $signed(result), zero);

        // Test 4: OR (10 | 5 = 15)
        a = 32'd10;
        b = 32'd5;
        alucontrol = 4'b0011;
        #10;
        $display("OR: a=%d, b=%d, result=%0d, zero=%b (Beklenen: 15, 0)", a, b, $signed(result), zero);

        // Test 5: XOR (10 ^ 5 = 15)
        a = 32'd10;
        b = 32'd5;
        alucontrol = 4'b0100;
        #10;
        $display("XOR: a=%d, b=%d, result=%0d, zero=%b (Beklenen: 15, 0)", a, b, $signed(result), zero);

        // Test 6: SLT (Signed Less Than) (-5 < 10 = 1)
        a = -32'd5;
        b = 32'd10;
        alucontrol = 4'b0101;
        #10;
        $display("SLT: a=%d, b=%d, result=%0d, zero=%b (Beklenen: 1, 0)", a, b, $signed(result), zero);

        // Test 7: SLL (Shift Left Logical) (7 << 3 = 56)
        a = 32'd7;
        b = 32'd3;
        alucontrol = 4'b0110;
        #10;
        $display("SLL: a=%d, b=%d, result=%0d, zero=%b (Beklenen: 56, 0)", a, b, $signed(result), zero);
        
        
        // Test 8: SRL (Shift Right Logical) (-12 >> 2 = 1)
        // 11111111111111111111111111110100 >> 00111111111111111111111111111101 = 1073741821
        a = -32'd12;
        b = 32'd2;
        alucontrol = 4'b0111;
        #10;
        $display("SRL: a=%d, b=%d, result=%0d, zero=%b (Beklenen: 1073741821, 0)", a, b, $signed(result), zero);
        
        // Test 9: SRA (Shift Right Arithmetic) (-12 >> 2 = -3) 
        // 11111111111111111111111111110100 >>> 11111111111111111111111111111101 = -3
        a = -32'd12;
        b = 32'd2;
        alucontrol = 4'b1000;
        #10;
        $display("SRA: a=%d, b=%d, result=%0d, zero=%b (Beklenen: -3, 0)", a, b, $signed(result), zero);

        // Test 10: Zero Flag Test (10 - 10 = 0, zero=1)
        a = 32'd10;
        b = 32'd10;
        alucontrol = 4'b0001;
        #10;
        $display("ZERO: a=%d, b=%d, result=%0d, zero=%b (Beklenen: 0, 1)", a, b, $signed(result), zero);

        // Test 11: Default case (alucontrol=1001)
        a = 32'd10;
        b = 32'd5;
        alucontrol = 4'b1001; // default operation will return xxxxx
        #10;

        $display("DEFAULT: a=%d, b=%d, result=%0d, zero=%b (Beklenen: x, x)", a, b, $signed(result), zero);

        $display("ALU Testbench Tamamlandı.");
        $finish;
    end

endmodule