`timescale 1ns / 1ps

// UART module with FIFO for both transmission (TX) and reception (RX)
module uart (
    input tx_clk,         // Transmitter clock signal
    input rx_clk,         // Receiver clock signal
    input start,          // Start signal to initiate transmission
    input [7:0] txin,     // 8-bit data input for transmission
    output reg tx,        // Serial output for transmitted data
    input rx,             // Serial input for received data
    output wire [7:0] rxout, // 8-bit data output for received data
    output wire rxdone,    // Signal indicating reception completion
    output wire txdone,    // Signal indicating transmission completion
    output wire bitDone_tx, // Internal bitDone signal for TX
    output wire bitDone_rx,  // Internal bitDone signal for RX
    
    // FIFO signals
    output wire tx_fifo_full,
    output wire tx_fifo_empty,
    output wire tx_fifo_wr_en,
    output wire tx_fifo_rd_en,
    output wire rx_fifo_full,
    output wire rx_fifo_empty,
    output wire rx_fifo_wr_en,
    output wire rx_fifo_rd_en,
    
    // New input for baud rate configuration
    input [15:0] baud_rate
);

    // Parameters for clock configuration
    parameter clk_value = 100_000; // Clock frequency (Hz)
    
    // Internal FIFO signals
    wire internal_tx_fifo_empty;
    wire internal_tx_fifo_full;
    wire [7:0] internal_tx_fifo_out, internal_rx_fifo_out;
    reg internal_tx_wr_en, internal_tx_rd_en, internal_rx_wr_en, internal_rx_rd_en;
    
    // Instantiate TX FIFO
    tx_fifo tx_fifo_inst (
        .clk(tx_clk),
        .reset(start),
        .din(txin),
        .wr_en(internal_tx_wr_en),
        .dout(internal_tx_fifo_out),
        .rd_en(internal_tx_rd_en),
        .empty(internal_tx_fifo_empty),
        .full(internal_tx_fifo_full)
    );

    // Instantiate RX FIFO
    rx_fifo rx_fifo_inst (
        .clk(rx_clk),
        .reset(start),
        .din(rx),
        .wr_en(internal_rx_wr_en),
        .dout(internal_rx_fifo_out),
        .rd_en(internal_rx_rd_en),
        .empty(internal_rx_fifo_empty),
        .full(internal_rx_fifo_full)
    );
    
    // Assign internal FIFO signals to output ports
    assign tx_fifo_full = internal_tx_fifo_full;
    assign tx_fifo_empty = internal_tx_fifo_empty;
    assign tx_fifo_wr_en = internal_tx_wr_en;
    assign tx_fifo_rd_en = internal_tx_rd_en;
    assign rx_fifo_full = internal_rx_fifo_full;
    assign rx_fifo_empty = internal_rx_fifo_empty;
    assign rx_fifo_wr_en = internal_rx_wr_en;
    assign rx_fifo_rd_en = internal_rx_rd_en;

    // Internal signals and registers for TX
    reg bitDone_tx_reg = 0; // Register to hold the bitDone signal for TX
    integer count_tx = 0;    // Counter for TX to track the number of clock cycles within a bit period
    reg [1:0] state_tx = 0;  // State machine for TX, manages the different states of the transmission process

    // State encoding for state machine
    localparam idle = 0, send = 1, check = 2; // States for the TX state machine

    // Internal registers for output signals
    reg [7:0] rxout_reg; // Register to hold the received data output
    reg rxdone_reg = 0;      // Register to hold the reception completion signal
    reg txdone_reg = 0;      // Register to hold the transmission completion signal

    // Calculate wait_count based on the configured baud rate
    integer wait_count;
    always @(baud_rate) begin
        wait_count = clk_value / baud_rate;
    end

    // Generate trigger for baud rate for TX
    always @(posedge tx_clk) begin
        if (state_tx == idle) begin
            count_tx <= 0; // Reset the counter when in idle state
        end else begin
            if (count_tx == wait_count) begin
                bitDone_tx_reg <= 1'b1; // Set bitDone when the counter reaches the baud rate interval
                count_tx <= 0; // Reset the counter to start a new bit period
            end else begin
                count_tx <= count_tx + 1; // Increment the counter to track the passage of time within a bit period
                bitDone_tx_reg <= 1'b0; // Clear bitDone to indicate the bit period is not yet complete
            end
        end
    end

    // TX Logic
    reg [9:0] txData; // Data to be transmitted (start bit + 8 data bits + stop bit)
    integer bitIndex = 0; // Bit index for transmission, tracks the current bit being transmitted

    // Process methodology: Mealy State Machine
    // Justification: The outputs (actions taken) depend on both the current state and the inputs (e.g., start signal for TX, rx input for RX).
    // This choice is justified by the need to react quickly to input changes and to minimize the number of states, which helps in reducing the complexity and resource usage of the design.
    always @(posedge tx_clk) begin
        case (state_tx)
            idle: begin
                tx <= 1'b1; // Default idle state for TX line
                txData <= 0; // Clear the txData register
                bitIndex <= 0; // Reset the bit index
                txdone_reg <= 0; // Reset the transmission done signal

                if (start == 1'b1 && !internal_tx_fifo_full) begin
                    internal_tx_wr_en <= 1'b1; // Write enable for TX FIFO
                    txData <= {1'b1, txin, 1'b0}; // Load data with start and stop bits
                    state_tx <= send; // Transition to the send state to begin transmission
                    $display("TX State: IDLE -> SEND at time %0t, TXIN: %0h", $time, txin); // Debugging information
                end else begin
                    state_tx <= idle; // Remain in idle state if start signal is not received
                end
            end

            send: begin
                tx <= txData[bitIndex]; // Transmit the current bit
                internal_tx_wr_en <= 1'b0; // Disable write enable for TX FIFO
                state_tx <= check; // Transition to the check state to determine the next action
                $display("TX State: SEND -> CHECK at time %0t, TX Bit: %b", $time, txData[bitIndex]); // Debugging information
            end

            check: begin
                if (bitIndex < 9) begin
                    if (bitDone_tx_reg == 1'b1) begin
                        bitIndex <= bitIndex + 1; // Move to the next bit
                        state_tx <= send; // Transition back to the send state to transmit the next bit
                        $display("TX State: CHECK -> SEND at time %0t, Bit Index: %0d", $time, bitIndex); // Debugging information
                    end
                end else begin
                    state_tx <= idle; // Transition to idle state after all bits are transmitted
                    bitIndex <= 0; // Reset the bit index
                    txdone_reg <= 1'b1; // Set the transmission done signal
                    internal_tx_rd_en <= 1'b1; // Enable read for TX FIFO to fetch next data
                    $display("TX State: CHECK -> IDLE at time %0t, TXDONE: %b", $time, txdone_reg); // Debugging information
                end
            end

            default: state_tx <= idle; // Default to idle state if an unknown state is encountered
        endcase
    end

    // RX Logic
    reg bitDone_rx_reg = 0; // Register to hold the bitDone signal for RX
    integer count_rx = 0;    // Counter for RX to track the number of clock cycles within a bit period
    reg [1:0] state_rx = 0;  // State machine for RX, manages the different states of the reception process
    integer rcount = 0;      // Counter for RX to track the number of clock cycles within a bit period during reception
    integer rindex = 0;      // Bit index for reception, tracks the current bit being received
    reg [9:0] rxdata;        // Received data buffer, holds the received bits

    // State encoding for RX state machine
    localparam ridle = 0, rwait = 1, recv = 2, rcheck = 3; // States for the RX state machine

    // Generate trigger for baud rate for RX
    always @(posedge rx_clk) begin
        if (state_rx == ridle) begin
            count_rx <= 0; // Reset the counter when in idle state
        end else begin
            if (count_rx == wait_count) begin
                bitDone_rx_reg <= 1'b1; // Set bitDone when the counter reaches the baud rate interval
                count_rx <= 0; // Reset the counter to start a new bit period
            end else begin
                count_rx <= count_rx + 1; // Increment the counter to track the passage of time within a bit period
                bitDone_rx_reg <= 1'b0; // Clear bitDone to indicate the bit period is not yet complete
            end
        end
    end

    // Process methodology: Mealy State Machine
    // Justification: The outputs (actions taken) depend on both the current state and the inputs (e.g., start signal for TX, rx input for RX).
    // This choice is justified by the need to react quickly to input changes and to minimize the number of states, which helps in reducing the complexity and resource usage of the design.
    always @(posedge rx_clk) begin
        case (state_rx)
            ridle: begin
                rxdata <= 0; // Clear the received data buffer
                rindex <= 0; // Reset the bit index
                rcount <= 0; // Reset the counter
                rxdone_reg <= 0; // Reset the reception done signal

                if (rx == 1'b0) begin
                    state_rx <= rwait; // Transition to the wait state if a start bit is detected
                    $display("RX State: IDLE -> RWAIT at time %0t", $time); // Debugging information
                end else begin
                    state_rx <= ridle; // Remain in idle state if no start bit is detected
                end
            end

            rwait: begin
                if (rcount < wait_count / 2) begin
                    rcount <= rcount + 1; // Wait for the middle of the start bit
                    state_rx <= rwait; // Remain in the wait state
                end else begin
                    rcount <= 0; // Reset the counter
                    state_rx <= recv; // Transition to the receive state to start receiving data bits
                    rxdata <= {rx, rxdata[9:1]}; // Shift in the received bit
                    internal_rx_wr_en <= 1'b1; // Enable write for RX FIFO
                    $display("RX State: RWAIT -> RECV at time %0t, RX Data: %0h", $time, rxdata); // Debugging information
                end
            end

            recv: begin
                if (rindex < 9) begin
                    if (bitDone_rx_reg == 1'b1) begin
                        rindex <= rindex + 1; // Move to the next bit
                        state_rx <= rwait; // Transition back to the wait state to receive the next bit
                        $display("RX State: RECV -> RWAIT at time %0t, Bit Index: %0d", $time, rindex); // Debugging information
                    end
                end else begin
                    state_rx <= ridle; // Transition to idle state after all bits are received
                    rindex <= 0; // Reset the bit index
                    rxout_reg <= rxdata[8:1]; // Store the received data
                    rxdone_reg <= 1'b1; // Set the reception done signal
                    internal_rx_rd_en <= 1'b1; // Enable read for RX FIFO
                    $display("RX State: RECV -> IDLE at time %0t, RXOUT: %0h, RXDONE: %b", $time, rxout_reg, rxdone_reg); // Debugging information
                end
            end

            default: state_rx <= ridle; // Default to idle state if an unknown state is encountered
        endcase
    end

    // Assign internal registers to outputs
    assign rxout = rxout_reg; // Assign the received data output
    assign rxdone = rxdone_reg; // Assign the reception completion signal
    assign txdone = txdone_reg; // Assign the transmission completion signal
    assign bitDone_tx = bitDone_tx_reg; // Assign the TX bitDone signal
    assign bitDone_rx = bitDone_rx_reg; // Assign the RX bitDone signal

endmodule