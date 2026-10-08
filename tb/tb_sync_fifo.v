// tb_sync_fifo.v
// Testbench for the Synchronous FIFO.
//
// Tests:
//   1. Reset check
//   2. Write until FIFO is full
//   3. Try writing when FIFO is full (should be ignored)
//   4. Read until FIFO is empty and check data order
//   5. Try reading when FIFO is empty (should be ignored)
//   6. Simultaneous read and write
//   7. Random read / write
//
// A simple queue (exp_mem) stores what we expect to read back.

`timescale 1ns/1ps

module tb_sync_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 16;
    parameter ADDR_WIDTH = 4;

    reg                   clk;
    reg                   rst;
    reg                   wr_en;
    reg                   rd_en;
    reg  [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire                  full;
    wire                  empty;

    // DUT
    sync_fifo #(
        .DATA_WIDTH (DATA_WIDTH),
        .DEPTH      (DEPTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) dut (
        .clk      (clk),
        .rst      (rst),
        .wr_en    (wr_en),
        .rd_en    (rd_en),
        .data_in  (data_in),
        .data_out (data_out),
        .full     (full),
        .empty    (empty)
    );

    // 10 ns clock
    initial clk = 0;
    always #5 clk = ~clk;

    // expected data queue
    reg [DATA_WIDTH-1:0] exp_mem [0:DEPTH-1];
    integer head  = 0;
    integer tail  = 0;
    integer count = 0;

    integer errors = 0;
    integer i;

    // ---------------- tasks ----------------

    // write one word (ignored by FIFO if full)
    task write_fifo(input [DATA_WIDTH-1:0] d);
        begin
            @(negedge clk);
            wr_en = 1; rd_en = 0; data_in = d;
            if (count < DEPTH) begin
                exp_mem[tail] = d;
                tail  = (tail + 1) % DEPTH;
                count = count + 1;
            end
            @(negedge clk);
            wr_en = 0;
        end
    endtask

    // read one word and compare with expected value
    task read_fifo;
        reg [DATA_WIDTH-1:0] expected;
        reg                  was_empty;
        begin
            @(negedge clk);
            wr_en = 0; rd_en = 1;
            was_empty = (count == 0);
            if (!was_empty) begin
                expected = exp_mem[head];
                head  = (head + 1) % DEPTH;
                count = count - 1;
            end
            @(negedge clk);          // data_out updates on the clock edge
            rd_en = 0;
            if (!was_empty) begin
                if (data_out !== expected) begin
                    $display("ERROR: read %h, expected %h  (time %0t)", data_out, expected, $time);
                    errors = errors + 1;
                end
            end
        end
    endtask

    // check full / empty flags against our own count
    task check_flags;
        begin
            if (full !== (count == DEPTH)) begin
                $display("ERROR: full = %b but count = %0d  (time %0t)", full, count, $time);
                errors = errors + 1;
            end
            if (empty !== (count == 0)) begin
                $display("ERROR: empty = %b but count = %0d  (time %0t)", empty, count, $time);
                errors = errors + 1;
            end
        end
    endtask

    // ---------------- main test ----------------
    initial begin
        $dumpfile("sync_fifo.vcd");
        $dumpvars(0, tb_sync_fifo);

        wr_en = 0; rd_en = 0; data_in = 0;

        // Test 1: reset
        $display("Test 1: Reset");
        rst = 1;
        repeat (2) @(negedge clk);
        rst = 0;
        check_flags;

        // Test 2: fill FIFO
        $display("Test 2: Write until full");
        for (i = 0; i < DEPTH; i = i + 1) begin
            write_fifo(i + 8'h10);
            check_flags;
        end

        // Test 3: write when full
        $display("Test 3: Write when full");
        write_fifo(8'hFF);
        check_flags;

        // Test 4: empty FIFO and check order
        $display("Test 4: Read until empty");
        for (i = 0; i < DEPTH; i = i + 1) begin
            read_fifo;
            check_flags;
        end

        // Test 5: read when empty
        $display("Test 5: Read when empty");
        read_fifo;
        check_flags;

        // Test 6: simultaneous read and write
        $display("Test 6: Simultaneous read and write");
        write_fifo(8'hA1);
        write_fifo(8'hA2);
        @(negedge clk);
        wr_en = 1; rd_en = 1; data_in = 8'hA3;   // read A1, write A3
        exp_mem[tail] = 8'hA3; tail = (tail + 1) % DEPTH;
        head = (head + 1) % DEPTH;               // A1 removed
        @(negedge clk);
        wr_en = 0; rd_en = 0;
        if (data_out !== 8'hA1) begin
            $display("ERROR: simultaneous read gave %h, expected A1", data_out);
            errors = errors + 1;
        end
        check_flags;
        read_fifo;   // A2
        read_fifo;   // A3
        check_flags;

        // Test 7: random operations
        $display("Test 7: Random read/write (500 operations)");
        for (i = 0; i < 500; i = i + 1) begin
            if ($random % 2)
                write_fifo($random);
            else
                read_fifo;
            check_flags;
        end

        // result
        $display("----------------------------------");
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TEST FAILED with %0d errors", errors);
        $display("----------------------------------");
        $finish;
    end

endmodule
