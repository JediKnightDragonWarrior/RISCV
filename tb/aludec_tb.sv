module aludec_tb();

    // Inputs to the DUT (Device Under Test)
    logic [1:0] ALUOp;
    logic       opb5;
    logic [2:0] funct3;
    logic       funct7b5;

    // Output from the DUT
    logic [3:0] ALUControl;

    // Instantiate the Unit Under Test (UUT)
    aludec dut (
        .ALUOp(ALUOp),
        .opb5(opb5),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .ALUControl(ALUControl)
    );

    initial begin
        // Format the output display for readability
        $display("Time\t ALUOp\t opb5\t f3\t f7b5\t | ALUControl\t Comment");
        $display("-----------------------------------------------------------------------");

        // --- Test 1: Load/Store (Addition) ---
        ALUOp = 2'b00; opb5 = 0; funct3 = 3'b000; funct7b5 = 0;
        #10; $display("%0t\t %b\t %b\t %b\t %b\t | %b\t\t lw/sw/jal (ADD)", $time, ALUOp, opb5, funct3, funct7b5, ALUControl);

        // --- Test 2: Branch Equal (Subtraction) ---
        ALUOp = 2'b01; opb5 = 0; funct3 = 3'b000; funct7b5 = 0;
        #10; $display("%0t\t %b\t %b\t %b\t %b\t | %b\t\t beq (SUB)", $time, ALUOp, opb5, funct3, funct7b5, ALUControl);

        // --- Test 3: R-type ADD ---
        ALUOp = 2'b10; opb5 = 0; funct3 = 3'b000; funct7b5 = 0;
        #10; $display("%0t\t %b\t %b\t %b\t %b\t | %b\t\t add (ADD)", $time, ALUOp, opb5, funct3, funct7b5, ALUControl);

        // --- Test 4: R-type SUB ---
        ALUOp = 2'b10; opb5 = 0; funct3 = 3'b000; funct7b5 = 1;
        #10; $display("%0t\t %b\t %b\t %b\t %b\t | %b\t\t sub (SUB)", $time, ALUOp, opb5, funct3, funct7b5, ALUControl);

        // --- Test 5: I-type ADDI ---
        // Note: opb5 is bit 5 of opcode. For I-type it is 0, for R-type it is 1.
        ALUOp = 2'b10; opb5 = 1; funct3 = 3'b000; funct7b5 = 0;
        #10; $display("%0t\t %b\t %b\t %b\t %b\t | %b\t\t addi (ADD)", $time, ALUOp, opb5, funct3, funct7b5, ALUControl);

        // --- Test 6: Logical AND ---
        ALUOp = 2'b10; opb5 = 0; funct3 = 3'b111; funct7b5 = 0;
        #10; $display("%0t\t %b\t %b\t %b\t %b\t | %b\t\t and (AND)", $time, ALUOp, opb5, funct3, funct7b5, ALUControl);

        // --- Test 7: SLT (Set Less Than) ---
        ALUOp = 2'b10; opb5 = 0; funct3 = 3'b010; funct7b5 = 0;
        #10; $display("%0t\t %b\t %b\t %b\t %b\t | %b\t\t slt (SLT)", $time, ALUOp, opb5, funct3, funct7b5, ALUControl);

        // --- Test 8: Logical XOR  ---
        ALUOp = 2'b10; opb5 = 0; funct3 = 3'b100; funct7b5 = 0;
        #10; $display("%0t\t %b\t %b\t %b\t %b\t | %b\t\t xor (xor)", $time, ALUOp, opb5, funct3, funct7b5, ALUControl);

        // --- Test 9: Logical OR ---
        ALUOp = 2'b10; opb5 = 0; funct3 = 3'b110; funct7b5 = 0;
        #10; $display("%0t\t %b\t %b\t %b\t %b\t | %b\t\t or (or)", $time, ALUOp, opb5, funct3, funct7b5, ALUControl);

        $finish;
    end
endmodule