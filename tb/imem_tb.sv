`timescale 1ns / 1ps

module imem_tb;

    logic        clk;
    logic [31:0] pc;
    logic [31:0] ins;
    
    // Instantiate DUT
    imem dut (
        .a(pc),
        .rd(ins)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    always_ff @(posedge clk) begin
        pc <= pc + 32'd4;
    end

    // Test sequence
    initial begin
        #10;
        pc  = 0;

        #1;

        repeat(12) begin
            $display("I :pc: %d , instruction : %b ",pc,ins);
            @(posedge clk) 
            #1;

        end


        $display("=== Test Complete ===");
        $finish;
    end

endmodule


