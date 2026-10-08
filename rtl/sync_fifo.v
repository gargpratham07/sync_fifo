// sync_fifo.v
// Top module of the Synchronous FIFO.
// Read and write both use the same clock.
//
// Hierarchy:
//   sync_fifo
//     |-- write_pointer  (u_wr_ptr)
//     |-- read_pointer   (u_rd_ptr)
//     |-- fifo_status    (u_status)
//     |-- fifo_memory    (u_mem)
//
// Note: DEPTH should be a power of 2 (4, 8, 16, 32 ...)

module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16,
    parameter ADDR_WIDTH = 4     // log2(DEPTH)
)(
    input                   clk,
    input                   rst,       // active high reset
    input                   wr_en,
    input                   rd_en,
    input  [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out,
    output                  full,
    output                  empty
);

    wire [ADDR_WIDTH:0] wr_ptr;
    wire [ADDR_WIDTH:0] rd_ptr;

    // write pointer
    write_pointer #(.ADDR_WIDTH(ADDR_WIDTH)) u_wr_ptr (
        .clk    (clk),
        .rst    (rst),
        .wr_en  (wr_en),
        .full   (full),
        .wr_ptr (wr_ptr)
    );

    // read pointer
    read_pointer #(.ADDR_WIDTH(ADDR_WIDTH)) u_rd_ptr (
        .clk    (clk),
        .rst    (rst),
        .rd_en  (rd_en),
        .empty  (empty),
        .rd_ptr (rd_ptr)
    );

    // full / empty flags
    fifo_status #(.ADDR_WIDTH(ADDR_WIDTH)) u_status (
        .wr_ptr (wr_ptr),
        .rd_ptr (rd_ptr),
        .full   (full),
        .empty  (empty)
    );

    // memory
    fifo_memory #(
        .DATA_WIDTH (DATA_WIDTH),
        .DEPTH      (DEPTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_mem (
        .clk      (clk),
        .wr_en    (wr_en && !full),
        .wr_addr  (wr_ptr[ADDR_WIDTH-1:0]),
        .data_in  (data_in),
        .rd_en    (rd_en && !empty),
        .rd_addr  (rd_ptr[ADDR_WIDTH-1:0]),
        .data_out (data_out)
    );

endmodule
