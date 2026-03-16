`timescale 1ns/1ps

module controller_tb();
    
    logic   [31:0]  instruction;

    logic           Zero;
    logic   [1:0]   ResultSrc;
    logic           MemWrite;
    logic           PCSrc;
    logic           ALUSrc;
    logic           RegWrite;
    logic   [2:0]   ImmSrc;
    logic   [3:0]   ALUControl;


    controller dut (
        .op(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7b5(instruction[29]),
        .Zero(Zero),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .PCSrc(PCSrc),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl)
    );

    
    // Test sequence
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, controller_tb);

        $display("=== Controller Testbench ===");
        
        // Initialize signals
        instruction <= '0;
        Zero        <= '0;
        #10;

        // xor instruction test 
        // R-Type : [31 funct7 25]_[24 rs2 20 _[19 rs1 15]_[14 funct3 12]_[11 rd 7]_[6 opcode 0] 
        // opcode = 0110011 , funct3 = 100  
        instruction <= 32'bxxxxxxxxxxxx_xxx_100_xxxxx_0110011;
        Zero    <= 1'b0;
        #1;
        $display("Test 1 : xor");
        $display("  instruction: %b , Zero: %b", instruction, Zero);
        $display("  ResultSrc:   %b (expected: %b) - alu res", ResultSrc, 2'b00);
        $display("  MemWrite:    %b (expected: %b) - no DataMem write", MemWrite, 1'b0);
        $display("  PCSrc:       %b (expected: %b) - +4", PCSrc, 1'b0);
        $display("  ALUSrc:      %b (expected: %b) - rd2", ALUSrc, 1'b0);
        $display("  RegWrite:    %b (expected: %b) - write enabled", RegWrite, 1'b1);
        $display("  ImmSrc:      %b (expected: %b) - R-type, no imm", ImmSrc, 3'bxxx);
        $display("  ALUControl:  %b (expected: %b) - xor\n", ALUControl, 4'b0100);
        #10;

        // andi instruction test 
        // I-Type : [31 imm 20]_[19 rs1 15]_[14 funct3 12]_[11 rd 7]_[6 opcode 0] 
        // opcode = 0010011 , funct3 = 111  
        instruction <= 32'bxxxxxxxxxxxx_xxx_111_xxxxx_0010011;
        Zero    <= 1'b0;
        #1;
        $display("Test 2 : andi");
        $display("  instruction: %b , Zero: %b", instruction, Zero);
        $display("  ResultSrc:   %b (expected: %b) - alu res", ResultSrc, 2'b00);
        $display("  MemWrite:    %b (expected: %b) - no DataMem write", MemWrite, 1'b0);
        $display("  PCSrc:       %b (expected: %b) - +4", PCSrc, 1'b0);
        $display("  ALUSrc:      %b (expected: %b) - imm", ALUSrc, 1'b1);
        $display("  RegWrite:    %b (expected: %b) - reg write enabled", RegWrite, 1'b1);
        $display("  ImmSrc:      %b (expected: %b) - I-type", ImmSrc, 3'b000);
        $display("  ALUControl:  %b (expected: %b) - and\n", ALUControl, 4'b0010);
        #10;

        // jal instruction test 
        // J-Type : [31 imm 12]_[11 rd 7]_[6 opcode 0] 
        // opcode = 1101111 ,  no funct3 since only J-Type instruction
        instruction <= 32'bxxxxxxxxxxxxxxx000_xxxxx_1101111;
        Zero    <= 1'b0; 
        #1;
        $display("Test 3 : jal, zero = 0");
        $display("  instruction: %b , Zero: %b", instruction, Zero);
        $display("  ResultSrc:   %b (expected: %b) - link pc+4", ResultSrc, 2'b10);
        $display("  MemWrite:    %b (expected: %b) - no DataMem write", MemWrite, 1'b0);
        $display("  PCSrc:       %b (expected: %b) - unconditional branch", PCSrc, 1'b1);
        $display("  ALUSrc:      %b (expected: %b) - alu not used", ALUSrc, 1'bx);
        $display("  RegWrite:    %b (expected: %b) - link written to rd", RegWrite, 1'b1);
        $display("  ImmSrc:      %b (expected: %b) - B-type", ImmSrc, 3'b011);
        $display("  ALUControl:  %b (expected: %b) - alu not used\n", ALUControl, 4'bxxxx);
        #10;

        // lw instruction test 
        // I-Type : [31 imm 20]_[19 rs1 15]_[14 funct3 12]_[11 rd 7]_[6 opcode 0] 
        // opcode = 0000011 , funct3 = 010  
        instruction <= 32'bxxxxxxxxxxxx_xxx_010_xxxxx_0000011;
        Zero    <= 1'b0;
        #1;
        $display("Test 4 : lw");
        $display("  instruction: %b , Zero: %b", instruction, Zero);
        $display("  ResultSrc:   %b (expected: %b) - DataMem Read", ResultSrc, 2'b01);
        $display("  MemWrite:    %b (expected: %b) - no DataMem write", MemWrite, 1'b0);
        $display("  PCSrc:       %b (expected: %b) - +4", PCSrc, 1'b0);
        $display("  ALUSrc:      %b (expected: %b) - imm", ALUSrc, 1'b1);
        $display("  RegWrite:    %b (expected: %b) - write enabled", RegWrite, 1'b1);
        $display("  ImmSrc:      %b (expected: %b) - I-type", ImmSrc, 3'b000);
        $display("  ALUControl:  %b (expected: %b) - addition\n", ALUControl, 4'b0000);
        #10;

        // beq instruction test 
        // B-Type : [31 imm 25]_[24 rs2 20]_[19 rs1 15]_[14 funct3 12]_[11 rd 7]_[6 opcode 0] 
        // opcode = 1100011 , funct3 = 000  
        instruction <= 32'bxxxxxxx_xxxxx_xxx_000_xxxxx_1100011;
        Zero    <= 1'b0; 
        #1;
        $display("Test 5 : beq, zero = 0");
        $display("  instruction: %b , Zero: %b", instruction, Zero);
        $display("  ResultSrc:   %b (expected: %b) - not used", ResultSrc, 2'bxx);
        $display("  MemWrite:    %b (expected: %b) - no DataMem write", MemWrite, 1'b0);
        $display("  PCSrc:       %b (expected: %b) - normal +4, since zero = 0", PCSrc, 1'b0);
        $display("  ALUSrc:      %b (expected: %b) - rd1 == rd2", ALUSrc, 1'b0);
        $display("  RegWrite:    %b (expected: %b) - no write to reg", RegWrite, 1'b0);
        $display("  ImmSrc:      %b (expected: %b) - B-type", ImmSrc, 3'b010);
        $display("  ALUControl:  %b (expected: %b) - rd1 - rd2 sub\n", ALUControl, 4'b0001);
        #10;

        // beq instruction test 
        // B-Type : [31 imm 25]_[24 rs2 20]_[19 rs1 15]_[14 funct3 12]_[11 rd 7]_[6 opcode 0] 
        // opcode = 1100011 , funct3 = 000  
        instruction <= 32'bxxxxxxx_xxxxx_xxx_000_xxxxx_1100011;
        Zero    <= 1'b1; 
        #1;
        $display("Test 6 : beq, zero = 1");
        $display("  instruction: %b , Zero: %b", instruction, Zero);
        $display("  ResultSrc:   %b (expected: %b) - not used", ResultSrc, 2'bxx);
        $display("  MemWrite:    %b (expected: %b) - no DataMem write", MemWrite, 1'b0);
        $display("  PCSrc:       %b (expected: %b) - branching, since zero = 1", PCSrc, 1'b1);
        $display("  ALUSrc:      %b (expected: %b) - rd1 == rd2", ALUSrc, 1'b0);
        $display("  RegWrite:    %b (expected: %b) - no write to reg", RegWrite, 1'b0);
        $display("  ImmSrc:      %b (expected: %b) - B-type", ImmSrc, 3'b010);
        $display("  ALUControl:  %b (expected: %b) - rd1 - rd2 sub\n", ALUControl, 4'b0001);
        #10;

        // sw instruction test 
        // S-Type : [31 imm 25]_[24 rs2 20]_[19 rs1 15]_[14 funct3 12]_[11 imm 7]_[6 opcode 0] 
        // opcode = 0100011 , funct3 = 010  
        instruction <= 32'bxxxxxxx_xxxxx_xxx_010_xxxxx_0100011;
        Zero    <= 1'b0;
        #1;
        $display("Test 7 : sw");
        $display("  instruction: %b , Zero: %b", instruction, Zero);
        $display("  ResultSrc:   %b (expected: %b) - not used", ResultSrc, 2'bxx);
        $display("  MemWrite:    %b (expected: %b) - DataMem write enabled", MemWrite, 1'b1);
        $display("  PCSrc:       %b (expected: %b) - +4", PCSrc, 1'b0);
        $display("  ALUSrc:      %b (expected: %b) - imm", ALUSrc, 1'b1);
        $display("  RegWrite:    %b (expected: %b) - no reg write", RegWrite, 1'b0);
        $display("  ImmSrc:      %b (expected: %b) - S-type", ImmSrc, 3'b001);
        $display("  ALUControl:  %b (expected: %b) - addition\n", ALUControl, 4'b0000);
        #10;

        $display("=== Test Complete ===\n");
        $finish;
    end
    
endmodule