`timescale 1ns/1ps

module tb();
    // Common values for bit and address length
    parameter DATA_WIDTH = 32;

    // Variables for top-level DUT
    logic        clk;
    logic        reset;
    logic        WR;
    logic        RD;
    logic [31:0] WD2;
    logic [31:0] RD1Out;
    logic        F;
    logic        E;

    // Variables to track program execution
    integer                trace_file;
    integer                scan_result;
    logic [DATA_WIDTH-1:0] ReadOut;
    logic [DATA_WIDTH-1:0] ExpectedRead;
    logic [DATA_WIDTH-1:0] WriteVal;
    integer                instr_count = 0;

    logic [DATA_WIDTH-1:0] queue [$];

    // Initialize top-level module
    top dut (
        .clk,
        .reset,
        .WR,
        .RD,
        .WD2,
        .RD1Out,
        .F,
        .E
    );

    task write(input logic [DATA_WIDTH-1:0] d);
        if (!F)
            queue.push_back(d);
        else
            $display("\n[%0t] WARNING: WRITING TO FULL QUEUE", $time);

        WR = 1;
        WD2 = d;
    
        @(posedge clk)
        #1;

        WR = 0;
    endtask

    task read();
        if (!E)
            ExpectedRead = queue.pop_front();
        else
            $display("\n[%0t] WARNING: READING FROM EMPTY QUEUE", $time);

        RD = 1;
        
        @(posedge clk)
        #1;

        RD = 0;
        ReadOut = RD1Out;

        if (ReadOut !== ExpectedRead) begin
            $display("\n[%0t] ERROR: Expected %h, received %h", $time, ExpectedRead, ReadOut);
            $stop;\
        end
        else
            $display("[%0t] PASS: Passed %h to the output", $time, ExpectedRead);
    endtask

    task readLine();
        scan_result = $fscanf(trace_file, "%h", WriteVal);
    endtask

    // Generate clock
    always begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end

    // Setup and reset
    initial begin
        trace_file = $fopen("data/wr_data.txt", "r");
        if (trace_file == 0) begin
            $display("\n[%0t] ERROR: Could not open trace file", $time);
            $stop;
        end

        reset = 1;
        #20;
        reset = 0;
    end

    initial begin
        $display("\n[%0t] Starting FIFO Directed Tests... ", $time);

        wait(reset == 0);
        @(posedge clk);

        // TEST 1: Basic read and write
        $display("\n-----TEST 1: Basic read and write-----");
        readLine();
        write(WriteVal);
        readLine();
        write(WriteVal);

        read();
        read();

        // TEST 2: Fill FIFO
        $display("\n-----TEST 2: Fill FIFO-----");
        for (int i = 0; i < 64; i++) begin
            readLine();
            write(WriteVal);
        end

        if (F !== 1) begin
            $display("\n[%0t] ERROR: FIFO DID NOT FILL", $time);
            $stop;
        end

        // TEST 3: Overfill FIFO
        $display("\n-----TEST 3: Overfill FIFO-----");
        for (int j = 0; j < 3; j++) begin
            readLine();
            write(WriteVal);
        end

        // TEST 4: Empty FIFO
        $display("\n-----TEST 4: Empty FIFO-----");
        for (int k = 0; k < 64; k++)
            read();

        if (E !== 1) begin
            $display("\n[%0t] ERROR: FIFO DID NOT EMPTY", $time);
            $stop;
        end

        // TEST 5: Underfill FIFO
        $display("\n-----TEST 5: Underfill FIFO-----");
        for (int l = 0; l < 3; l++)
            read();

        // TEST 6: Simultaneous reads and writes
        $display("\n-----TEST 6: Simultaneous reads and writes");
        for (int m = 0; m < 3; m++) begin
            readLine();
            write(WriteVal);
        end

        @(posedge clk)
        WR = 1;
        readLine();
        WD2 = WriteVal;
        RD = 1;

        queue.push_back(WriteVal);
        ExpectedRead = queue.pop_front();

        @(posedge clk)
        WR = 0;
        RD = 0;

        if (RD1Out !== ExpectedRead) begin
            $display("\nERROR: SIMULTANEOUS READ AND WRITE FAILED");
            $stop;
        end

        // Successful execution of all tests
        $display("\n\nSUCCESS: ALL TESTS PASSED");
        $finish;
    end
endmodule
