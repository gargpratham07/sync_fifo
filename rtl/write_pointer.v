// write_pointer.v
// Write pointer of the FIFO.
// Increments by 1 on every write, but only if the FIFO is not full.
// The pointer has one extra bit (MSB) used to detect full / empty.

module write_pointer #(
    parameter ADDR_WIDTH = 4
)(
    input                     clk,
    input                     rst,
    input                     wr_en,
    input                     full,
    output reg [ADDR_WIDTH:0] wr_ptr
);

    always @(posedge clk) begin
        if (rst)
            wr_ptr <= 0;
        else if (wr_en && !full)
            wr_ptr <= wr_ptr + 1;
    end

endmodule
