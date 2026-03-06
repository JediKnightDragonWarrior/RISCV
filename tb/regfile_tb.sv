`timescale 1ns/1ps

module regfile_tb();
    
    logic        clk;
    logic        we3;
    logic [4:0]  a1, a2, a3;
    logic [31:0] wd3;
    logic [31:0] rd1, rd2;
    
    // Instantiate the regfile module
    regfile dut (
        .clk(clk),
        .we3(we3),
        .a1(a1),
        .a2(a2),
        .a3(a3),
        .wd3(wd3),
        .rd1(rd1),
        .rd2(rd2)
    );
    
    // Clock generation
    initial begin
        clk <= 0;
        forever #5 clk <= ~clk;  // 10ns period
    end
    
    // Test sequence
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, regfile_tb);

        $display("=== Register File Testbench ===");
        
        // Initialize signals
        we3 <= 0;
        a1 <= 0;
        a2 <= 0;
        a3 <= 0;
        wd3 <= 0;
        
        @(posedge clk);
        
        // --- WRITE PHASE: Write 20, 21, 22, 23, 24 to x10-x14 ---
        $display("\n--- Writing to registers x10-x14 ---");
        
        we3 <= 1;  // Enable writes
        
        // Write 20 to x10
        $display("Cycle 1: Write x10 <= 20");
        a3 <= 5'd10;
        wd3 <= 32'd20;
        @(posedge clk);
        
        // Write 21 to x11
        $display("Cycle 2: Write x11 <= 21");
        a3 <= 5'd11;
        wd3 <= 32'd21;
        @(posedge clk);
        
        // Write 22 to x12
        $display("Cycle 3: Write x12 <= 22");
        a3 <= 5'd12;
        wd3 <= 32'd22;
        @(posedge clk);
        
        // Write 23 to x13
        $display("Cycle 4: Write x13 <= 23");
        a3 <= 5'd13;
        wd3 <= 32'd23;
        @(posedge clk);
        
        // Write 24 to x14
        $display("Cycle 5: Write x14 <= 24");
        a3 <= 5'd14;
        wd3 <= 32'd24;
        @(posedge clk);
        
        we3 <= 0;  // Disable writes
        $display("\n--- Reading from registers ---");
        
        // --- READ PHASE: Read from registers over two cycles ---
        
        // Read cycle 1: Read x10 and x11
        a1 <= 5'd10;
        a2 <= 5'd11;
        @(posedge clk);
        $display("Cycle 6: Read x10=%0d, x11=%0d (Expected: 20, 21)", rd1, rd2);
        
        // Read cycle 2: Read x12 and x13
        a1 <= 5'd12;
        a2 <= 5'd13;
        @(posedge clk);
        $display("Cycle 7: Read x12=%0d, x13=%0d (Expected: 22, 23)", rd1, rd2);
        
        // Read cycle 3: Read x14 and x10
        a1 <= 5'd14;
        a2 <= 5'd10;
        @(posedge clk);
        $display("Cycle 8: Read x14=%0d, x10=%0d (Expected: 24, 20)", rd1, rd2);
        
        $display("\n=== Test Complete ===\n");
        $finish;
    end
    
endmodule