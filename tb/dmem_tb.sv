`timescale 1ns / 1ps

module dmem_tb;

    logic        clk;
    logic        WE;
    logic [31:0] A;
    logic [31:0] WD;
    logic [31:0] RD;
    
    // Instantiate DUT
    dmem dut (
        .clk(clk),
        .WE(WE),
        .A(A),
        .WD(WD),
        .RD(RD)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        WE = 0;
        A = 32'b0;
        WD = 32'b0;

        $display("=== Data Memory Testbench ===");
        
        @(posedge clk) 
        $display("I :address : %d , data_write : %d,  data_read : %d , WE : %d ",A,WD,RD,WE);
        
        
        #1
        WD = 32'd75 ;
        A = 32'd75 ; // to 72 
        WE = 1;
        #1;
        //$display("S :address : %d , data_write : %d,  data_read : %d , WE : %d ",A,WD,RD,WE);
        @(posedge clk) 
        $display("R :address : %d , data_write : %d,  data_read : %d , WE : %d ",A,WD,RD,WE);


        #1
        WD = 32'd75 ;
        A = 32'd75 ; // to 72 
        WE = 0;
        #1;
        //$display("S :address : %d , data_write : %d,  data_read : %d , WE : %d ",A,WD,RD,WE);
        @(posedge clk) // second negedge
        $display("R :address : %d , data_write : %d,  data_read : %d , WE : %d ",A,WD,RD,WE);

        #1
        WD = 32'd80 ;
        A = 32'd75 ; // to 72 
        WE = 1;
        #1;
        //$display("S :address : %d , data_write : %d,  data_read : %d , WE : %d ",A,WD,RD,WE);
        @(posedge clk) // second negedge
        $display("R :address : %d , data_write : %d,  data_read : %d , WE : %d ",A,WD,RD,WE);

        #1
        WD = 32'd80 ;
        A = 32'd75 ; // to 72 
        WE = 0;
        #1;
        //$display("S :address : %d , data_write : %d,  data_read : %d , WE : %d ",A,WD,RD,WE);
        @(posedge clk) // second negedge
        $display("R :address : %d , data_write : %d,  data_read : %d , WE : %d ",A,WD,RD,WE);




        $display("=== Test Complete ===");
        $finish;
    end

endmodule