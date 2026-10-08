// fifo_status.v
// Generates the full and empty flags by comparing the two pointers.
//
// empty : both pointers are exactly equal
// full  : address bits are equal but the extra MSB is different
//         (write pointer has wrapped around once more than read pointer)

module fifo_status #(
    parameter ADDR_WIDTH = 4
)(
    input  [ADDR_WIDTH:0] wr_ptr,
    input  [ADDR_WIDTH:0] rd_ptr,
    output                full,
    output                empty
);

    assign empty = (wr_ptr == rd_ptr);

    assign full  = (wr_ptr[ADDR_WIDTH]     != rd_ptr[ADDR_WIDTH]) &&
                   (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);

endmodule
