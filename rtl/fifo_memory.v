// fifo_memory.v
// Memory block of the FIFO.
// Data is written when wr_en = 1 and read out when rd_en = 1.

module fifo_memory #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16,
    parameter ADDR_WIDTH = 4
)(
    input                       clk,
    input                       wr_en,
    input      [ADDR_WIDTH-1:0] wr_addr,
    input      [DATA_WIDTH-1:0] data_in,
    input                       rd_en,
    input      [ADDR_WIDTH-1:0] rd_addr,
    output reg [DATA_WIDTH-1:0] data_out
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // write
    always @(posedge clk) begin
        if (wr_en)
            mem[wr_addr] <= data_in;
    end

    // read
    always @(posedge clk) begin
        if (rd_en)
            data_out <= mem[rd_addr];
    end

endmodule
