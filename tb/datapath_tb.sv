`timescale 1ns/1ps

module datapath_tb();
    
    logic        clk;
    logic        reset;
    logic [31:0] Instr;
    logic        PCSrc;
    logic [1:0]  ResultSrc;
    logic        ALUSrc;
    logic [2:0]  ImmSrc;
    logic        RegWrite;
    logic [3:0]  ALUControl;
    logic [31:0] ReadData;
    
    // Datapath outputs
    logic [31:0] PC;
    logic [31:0] ALUResult;
    logic [31:0] WriteData;
    logic        Zero;

    // Datapath module
    datapath dut (
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .Instr(Instr),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .ReadData(ReadData),
        .PCSrc(PCSrc),
        .ResultSrc(ResultSrc),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl),
        .Zero(Zero)
    );

    // Clock generation
    initial begin
        clk <= 0;
        forever #5 clk <= ~clk;  // 10ns period
    end

    // Test sequence
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, datapath_tb);

        $display("=== Datapath Testbench ===\n");
        
        // Initialize signals
        reset       <= '1;
        Instr       <= '0;
        ReadData    <= '0;
        PCSrc       <= '0;
        ResultSrc   <= '0;
        ALUSrc      <= '0;
        ImmSrc      <= '0;
        RegWrite    <= '0;
        ALUControl  <= '0;
        #10;
        reset <= '0;
        #1;

        // Test 1: addi x5, x0, 5 (I-Type)
        // opcode = 0010011 , funct3 = 000
        Instr       <= 32'b000000001010_00000_000_00101_0010011;  // addi x5, x0, 5
        PCSrc       <= 1'b0;
        ResultSrc   <= 2'b00;
        ALUSrc      <= 1'b1;
        ImmSrc      <= 3'b000;
        RegWrite    <= 1'b1;
        ALUControl  <= 4'b0000;
        @(posedge clk);
        #1;
        $display("Test 1 : addi x5, x0, 5 (I-Type)");
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d", ALUResult);
        $display("  Zero:       %b", Zero);
        $display("  WriteData:  %d\n", WriteData);
        #1;    


        
        // Test 2: addi x7, x0, 7 (I-Type)
        // opcode = 0010011 , funct3 = 000
        Instr       <= 32'b111111111001_00101_000_00111_0010011;  // addi x7, x0, 7
        PCSrc       <= 1'b0;
        ResultSrc   <= 2'b00;
        ALUSrc      <= 1'b1;
        ImmSrc      <= 3'b000;
        RegWrite    <= 1'b1;
        ALUControl  <= 4'b0000;
        @(posedge clk);
        #1;
        $display("Test 2 : addi x7, x0, 7 (I-Type)");
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d", ALUResult);
        $display("  Zero:       %b", Zero);
        $display("  WriteData:  %d\n", WriteData);
        #1;

        // Test 3: add x12, x5, x7 (R-Type)
        // opcode = 0110011 , funct3 = 000
        Instr       <= 32'b0000000_00111_00101_000_01100_0110011;  // add x12, x5, x7
        PCSrc       <= 1'b0;
        ResultSrc   <= 2'b00;
        ALUSrc      <= 1'b0;
        ImmSrc      <= 3'bxxx;
        RegWrite    <= 1'b1;
        ALUControl  <= 4'b0000;
        @(posedge clk);
        #1;
        $display("Test 3 : add x12, x5, x7 (R-Type)");
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d (5 + 7 = 12)", ALUResult);
        $display("  Zero:       %b", Zero);
        $display("  WriteData:  %d\n", WriteData);
        #1;

        // Test 4: beq x5, x7, offset (B-Type)
        // opcode = 1100011 , funct3 = 000
        // rs1 = x5, rs2 = x7, offset = 8
        Instr       <= 32'b0000000_00111_00101_000_00100_1100011;  // beq x5, x7, 8
        PCSrc       <= 1'b0;
        ResultSrc   <= 2'bxx;
        ALUSrc      <= 1'b0;
        ImmSrc      <= 3'b010;
        RegWrite    <= 1'b0;
        ALUControl  <= 4'b0001;
        @(posedge clk);
        #1;
        $display("Test 4 : beq x5, x7, offset (B-Type, no branch)");
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d (5 - 7 = -2)", ALUResult);
        $display("  Zero:       %b (not equal, PCSrc = 0)", Zero);
        $display("  WriteData:  %d\n", WriteData);
        #1;

        // Test 5: beq x5, x5, offset (B-Type)
        // opcode = 1100011 , funct3 = 000
        // rs1 = x5, rs2 = x5, offset = 8
        Instr       <= 32'b0000000_00101_00101_000_01000_1100011;  // beq x5, x5, 8
        PCSrc       <= 1'b1;
        ResultSrc   <= 2'bxx;
        ALUSrc      <= 1'b0;
        ImmSrc      <= 3'b010;
        RegWrite    <= 1'b0;
        ALUControl  <= 4'b0001;
        @(posedge clk);
        #1;
        $display("Test 5 : beq x5, x5, offset (B-Type, branch taken)");
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d (5 - 5 = 0)", ALUResult);
        $display("  Zero:       %b (equal, PCSrc = 1)", Zero);
        $display("  WriteData:  %d\n", WriteData);
        #1;


        // Test 6: jal x1, offset (J-Type)
        // opcode = 1101111
        //  rd = pc+4 ; pc += imm ( +12 )
        Instr       <= 32'b00000000110000000000_00001_1101111;  // jal x1, 64
        PCSrc       <= 1'b1;
        ResultSrc   <= 2'b10;
        ALUSrc      <= 1'bx;
        ImmSrc      <= 3'b011;
        RegWrite    <= 1'b1;
        ALUControl  <= 4'bxxxx;
        @(posedge clk);
        #1;
        $display("Test 6 : jal x1, offset (J-Type)");
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d", ALUResult);
        $display("  ResultSrc:  %b (link register = PC+4)", ResultSrc);
        $display("  PCSrc:      %b (jump taken)", PCSrc);
        $display("  Zero:       %b", Zero);
        $display("  WriteData:  %d\n", WriteData);
        #1;

/*


        // Test 4: sw x12, 0(x0) (S-Type)
        // opcode = 0100011 , funct3 = 010
        // rs1 = x0, rs2 = x12, offset = 0
        Instr       <= 32'b0000000_01100_00000_010_00000_0100011;  // sw x12, 0(x0)
        PCSrc       <= 1'b0;
        ResultSrc   <= 2'bxx;
        ALUSrc      <= 1'b1;
        ImmSrc      <= 3'b001;
        RegWrite    <= 1'b0;
        ALUControl  <= 4'b0000;
        @(posedge clk);
        #1;
        $display("Test 4 : sw x12, 0(x0) (S-Type)");
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d (address)", ALUResult);
        $display("  Zero:       %b", Zero);
        $display("  WriteData:  %d (x12 = 12)\n", WriteData);
        #10;

        // Test 5: lw x10, 0(x0) (I-Type)
        // opcode = 0000011 , funct3 = 010
        Instr       <= 32'b000000000000_00000_010_01010_0000011;  // lw x10, 0(x0)
        ReadData    <= 32'd12;  // Read back the value we stored
        PCSrc       <= 1'b0;
        ResultSrc   <= 2'b01;
        ALUSrc      <= 1'b1;
        ImmSrc      <= 3'b000;
        RegWrite    <= 1'b1;
        ALUControl  <= 4'b0000;
        @(posedge clk);
        #1;
        $display("Test 5 : lw x10, 0(x0) (I-Type)");
        $display("  PC:         %d", PC);
        $display("  Instr:      %b", Instr);
        $display("  ALUResult:  %d (address)", ALUResult);
        $display("  ReadData:   %d (loaded value)", ReadData);
        $display("  Zero:       %b", Zero);
        $display("  WriteData:  %d\n", WriteData);
        #10;
*/

        $display("=== Test Complete ===\n");
        $finish;
    end
    
endmodule