`timescale 1ns/1ps

module riscvsingle_tb();
    
    logic        clk;
    logic        reset;
    logic [31:0] Instr;
    logic [31:0] ReadData;
    
    // Riscvsingle outputs
    logic [31:0] PC;
    logic        MemWrite;
    logic [31:0] ALUResult;
    logic [31:0] WriteData;

    // Riscvsingle module
    riscvsingle dut (
        .clk(clk),
        .reset(reset),
        .Instr(Instr),
        .ReadData(ReadData),
        .PC(PC),
        .MemWrite(MemWrite),
        .ALUResult(ALUResult),
        .WriteData(WriteData)
    );

    // Clock generation
    initial begin
        clk <= 0;
        forever #5 clk <= ~clk;  // 10ns period
    end

    // Test sequence
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, riscvsingle_tb);

        $display("=== RISC-V Single Cycle Processor Testbench ===\n");
        
        // Initialize signals
        reset    <= 1;
        Instr    <= '0;
        ReadData <= '0;
        #10;
        reset <= 0;
        #1;

        // Test 1: addi x5, x0, 5 (I-Type)
        // opcode = 0010011 , funct3 = 000
        $display("Current PC: %d", PC);
        Instr <= 32'b000000000101_00000_000_00101_0010011;  // addi x5, x0, 5
        @(posedge clk);
        #1;
        $display("Test 1 : addi x5, x0, 5 (I-Type)");
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d", ALUResult);
        $display("  MemWrite:   %b", MemWrite);
        $display("  WriteData:  %d\n", WriteData);
        #1;

        // Test 2: addi x7, x0, 7 (I-Type)
        // opcode = 0010011 , funct3 = 000
        $display("Current PC: %d", PC);
        Instr <= 32'b000000000111_00000_000_00111_0010011;  // addi x7, x0, 7
        @(posedge clk);
        #1;
        $display("Test 2 : addi x7, x0, 7 (I-Type)");
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d", ALUResult);
        $display("  MemWrite:   %b", MemWrite);
        $display("  WriteData:  %d\n", WriteData);
        #1;

        // Test 3: add x12, x5, x7 (R-Type)
        // opcode = 0110011 , funct3 = 000
        $display("Current PC: %d", PC);
        Instr <= 32'b0000000_00111_00101_000_01100_0110011;  // add x12, x5, x7
        @(posedge clk);
        #1;
        $display("Test 3 : add x12, x5, x7 (R-Type)");
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d (5 + 7 = 12)", ALUResult);
        $display("  MemWrite:   %b", MemWrite);
        $display("  WriteData:  %d\n", WriteData);
        #1;

        // Test 4: beq x5, x7, offset (B-Type, no branch)
        // opcode = 1100011 , funct3 = 000
        $display("Current PC: %d", PC);
        Instr <= 32'b0000000_00111_00101_000_00100_1100011;  // beq x5, x7, 8
        @(posedge clk);
        #1;
        $display("Test 4 : beq x5, x7, offset: %d (B-Type, no branch)", 32'd8);
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d (5 - 7 = -2)", ALUResult);
        $display("  MemWrite:   %b", MemWrite);
        $display("  WriteData:  %d\n", WriteData);
        #1;

        // Test 5: beq x5, x5, offset (B-Type, branch taken)
        // opcode = 1100011 , funct3 = 000
        $display("Current PC: %d", PC);
        Instr <= 32'b0000000_00101_00101_000_01000_1100011;  // beq x5, x5, 8
        @(posedge clk);
        #1;
        $display("Test 5 : beq x5, x5, offset: %d  (B-Type, branch taken)", 32'd8);
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d (5 - 5 = 0)", ALUResult);
        $display("  MemWrite:   %b", MemWrite);
        $display("  WriteData:  %d\n", WriteData);
        #1;

        // Test 6: jal x1, offset (J-Type)
        // opcode = 1101111
        $display("Current PC: %d", PC);
        Instr <= 32'b00000000110000000000_00001_1101111;  // jal x1, 64
        @(posedge clk);
        #1;
        $display("Test 6 : jal x1, , offset: %d (J-Type)", 32'd12);
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d", ALUResult);
        $display("  MemWrite:   %b", MemWrite);
        $display("  WriteData:  %d\n", WriteData);
        #1;

/*

        // Test 7: sw x12, 0(x0) (S-Type)
        // opcode = 0100011 , funct3 = 010
        Instr <= 32'b0000000_01100_00000_010_00000_0100011;  // sw x12, 0(x0)
        @(posedge clk);
        #1;
        $display("Test 7 : sw x12, 0(x0) (S-Type)");
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d (address)", ALUResult);
        $display("  MemWrite:   %b (write enabled)", MemWrite);
        $display("  WriteData:  %d (x12 = 12)\n", WriteData);
        #1;

        // Test 8: lw x10, 0(x0) (I-Type)
        // opcode = 0000011 , funct3 = 010
        Instr <= 32'b000000000000_00000_010_01010_0000011;  // lw x10, 0(x0)
        ReadData <= 32'd12;  // Read back the value we stored
        @(posedge clk);
        #1;
        $display("Test 8 : lw x10, 0(x0) (I-Type)");
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d (address)", ALUResult);
        $display("  ReadData:   %d (loaded value)", ReadData);
        $display("  MemWrite:   %b", MemWrite);
        $display("  WriteData:  %d\n", WriteData);
        #1;
*/

        $display("=== Test Complete ===\n");
        $finish;
    end
    
endmodule