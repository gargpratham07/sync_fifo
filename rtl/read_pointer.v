// read_pointer.v
// Read pointer of the FIFO.
// Increments by 1 on every read, but only if the FIFO is not empty.
// The pointer has one extra bit (MSB) used to detect full / empty.

module read_pointer #(
    parameter ADDR_WIDTH = 4
)(
    input                     clk,
    input                     rst,
    input                     rd_en,
    input                     empty,
    output reg [ADDR_WIDTH:0] rd_ptr
);

    always @(posedge clk) begin
        if (rst)
            rd_ptr <= 0;
        else if (rd_en && !empty)
            rd_ptr <= rd_ptr + 1;
    end

endmodule
