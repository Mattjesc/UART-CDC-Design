// TX FIFO module
module tx_fifo (
    input wire clk,
    input wire reset,
    input wire [7:0] din,     // Data input
    input wire wr_en,         // Write enable
    output wire [7:0] dout,   // Data output
    input wire rd_en,         // Read enable
    output wire empty,
    output wire full
);
    parameter FIFO_DEPTH = 16; // Define the depth of the FIFO
    reg [7:0] fifo_mem [0:FIFO_DEPTH-1]; // Memory array to store FIFO data
    reg [4:0] wr_ptr = 0; // Write pointer to track the next write location
    reg [4:0] rd_ptr = 0; // Read pointer to track the next read location
    reg [4:0] count = 0; // Counter to track the number of elements in the FIFO

    // Assign the empty signal when the FIFO is empty
    assign empty = (count == 0);
    // Assign the full signal when the FIFO is full
    assign full = (count == FIFO_DEPTH);
    // Assign the data output from the FIFO
    assign dout = fifo_mem[rd_ptr];

    // Synchronous process to handle FIFO operations
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset the FIFO pointers and count
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= 0;
        end else begin
            // Write operation
            if (wr_en && !full) begin
                fifo_mem[wr_ptr] <= din; // Write data to the FIFO
                wr_ptr <= wr_ptr + 1; // Increment the write pointer
                count <= count + 1; // Increment the count of elements in the FIFO
            end
            // Read operation
            if (rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1; // Increment the read pointer
                count <= count - 1; // Decrement the count of elements in the FIFO
            end
        end
    end
endmodule