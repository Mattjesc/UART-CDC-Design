`timescale 1ns / 1ps

module uart_tb;

    // Testbench signals
    reg tx_clk = 0;       // Transmitter clock signal
    reg rx_clk = 0;       // Receiver clock signal
    reg start = 0;        // Start signal to initiate transmission
    reg [7:0] txin;       // 8-bit data input for transmission
    wire [7:0] rxout;     // 8-bit data output for received data
    wire rxdone, txdone;  // Signals indicating reception and transmission completion
    wire txrx;            // Serial line for TX and RX (loopback)

    // Internal wires for bitDone signals
    wire bitDone_tx;
    wire bitDone_rx;

    // FIFO signals
    wire tx_fifo_full, tx_fifo_empty, tx_fifo_wr_en, tx_fifo_rd_en;
    wire rx_fifo_full, rx_fifo_empty, rx_fifo_wr_en, rx_fifo_rd_en;

    // Instantiate the UART module with FIFO
    uart dut (
        .tx_clk(tx_clk),
        .rx_clk(rx_clk),
        .start(start),
        .txin(txin),
        .tx(txrx),
        .rx(txrx),
        .rxout(rxout),
        .rxdone(rxdone),
        .txdone(txdone),
        .bitDone_tx(bitDone_tx),
        .bitDone_rx(bitDone_rx),
        .tx_fifo_full(tx_fifo_full),
        .tx_fifo_empty(tx_fifo_empty),
        .tx_fifo_wr_en(tx_fifo_wr_en),
        .tx_fifo_rd_en(tx_fifo_rd_en),
        .rx_fifo_full(rx_fifo_full),
        .rx_fifo_empty(rx_fifo_empty),
        .rx_fifo_wr_en(rx_fifo_wr_en),
        .rx_fifo_rd_en(rx_fifo_rd_en)
    );

    // Clock generation for TX (100MHz)
    always #5 tx_clk = ~tx_clk; // Toggle the TX clock every 5 ns to achieve a 100 MHz frequency

    // Clock generation for RX (100MHz, slightly phase shifted)
    always #7 rx_clk = ~rx_clk; // Toggle the RX clock every 7 ns to achieve a 100 MHz frequency with a phase shift

    integer i;

    // Monitor all relevant signals continuously
    initial begin
        $monitor("Time: %0t | TX_CLK: %b | RX_CLK: %b | START: %b | TXIN: %0h | TX: %b | RX: %b | RXOUT: %0h | TXDONE: %b | RXDONE: %b | bitDone_tx: %b | bitDone_rx: %b | TX_FIFO_FULL: %b | TX_FIFO_EMPTY: %b | TX_FIFO_WR_EN: %b | TX_FIFO_RD_EN: %b | RX_FIFO_FULL: %b | RX_FIFO_EMPTY: %b | RX_FIFO_WR_EN: %b | RX_FIFO_RD_EN: %b", 
                 $time, tx_clk, rx_clk, start, txin, txrx, txrx, rxout, txdone, rxdone, bitDone_tx, bitDone_rx, tx_fifo_full, tx_fifo_empty, tx_fifo_wr_en, tx_fifo_rd_en, rx_fifo_full, rx_fifo_empty, rx_fifo_wr_en, rx_fifo_rd_en);
    end

    initial begin
        start = 0;
        txin = 0;

        // Wait for some time before starting the test
        #100; // Wait for 100 ns to ensure the clocks are stable and the system is ready

        for (i = 0; i < 10; i = i + 1) begin
            txin = $urandom_range(10, 200); // Generate random data to transmit
            start = 1; // Start transmission
            $display("Starting transmission of data: %0h at time %0t", txin, $time); // Debugging information
            @(posedge txdone); // Wait for transmission to complete
            $display("Transmission completed at time %0t", $time); // Debugging information
            start = 0;
            @(posedge rxdone); // Wait for reception to complete
            $display("Received data: %0h at time %0t", rxout, $time); // Debugging information
        end

        // Introduce a burst of data
        for (i = 0; i < 50; i = i + 1) begin
            txin = $urandom_range(10, 200); // Generate random data to transmit
            start = 1; // Start transmission
            #1; // Small delay to introduce rapid data
            start = 0; // Stop transmission
        end

        $stop; // Stop the simulation after all transmissions are completed
    end

endmodule