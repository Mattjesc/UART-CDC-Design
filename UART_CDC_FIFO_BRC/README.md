# UART with Clock Domain Crossing (CDC), FIFO Buffers, and Dynamic Baud Rate Configuration

## Overview

This repository contains an upgraded implementation of a UART (Universal Asynchronous Receiver/Transmitter) with Clock Domain Crossing (CDC), First In, First Out (FIFO) buffers, and dynamic Baud Rate Configuration (BRC). The design enhances the basic UART functionality by incorporating FIFOs for both transmission (TX) and reception (RX), providing better handling of data flow and improved robustness in asynchronous communication between different clock domains. Additionally, the baud rate can be dynamically adjusted to accommodate different communication requirements.

## Key Components

### Clock Domains
- **tx_clk**: Clock signal for the transmitter.
- **rx_clk**: Clock signal for the receiver.

### Transmitter (TX) Logic
- **State machine**: With states `idle`, `send`, and `check`.
- **txData**: Register to hold the data to be transmitted, including start and stop bits.
- **bitIndex**: Counter to track the current bit being transmitted.
- **bitDone_tx_reg**: Signal to indicate the completion of a bit period.

### Receiver (RX) Logic
- **State machine**: With states `ridle`, `rwait`, `recv`, and `rcheck`.
- **rxdata**: Register to hold the received data.
- **rindex**: Counter to track the current bit being received.
- **bitDone_rx_reg**: Signal to indicate the completion of a bit period.

### FIFO Buffers
- **TX FIFO**: Handles the buffering of data to be transmitted, preventing data loss if the transmitter is busy.
- **RX FIFO**: Buffers incoming data to be processed by the receiver, preventing data overflow.

### Signals
- **start**: Signal to initiate the transmission.
- **txin**: 8-bit data input for transmission.
- **tx**: Serial output for transmitted data.
- **rx**: Serial input for received data.
- **rxout**: 8-bit data output for received data.
- **rxdone**: Signal indicating reception completion.
- **txdone**: Signal indicating transmission completion.
- **bitDone_tx**: Internal signal for TX bit period completion.
- **bitDone_rx**: Internal signal for RX bit period completion.
- **tx_fifo_full**: Indicates that the TX FIFO is full.
- **tx_fifo_empty**: Indicates that the TX FIFO is empty.
- **tx_fifo_wr_en**: Write enable for the TX FIFO.
- **tx_fifo_rd_en**: Read enable for the TX FIFO.
- **rx_fifo_full**: Indicates that the RX FIFO is full.
- **rx_fifo_empty**: Indicates that the RX FIFO is empty.
- **rx_fifo_wr_en**: Write enable for the RX FIFO.
- **rx_fifo_rd_en**: Read enable for the RX FIFO.
- **baud_rate**: Configurable baud rate for UART communication.

## FIFO Modules

### TX FIFO Module
The TX FIFO module handles the buffering of data to be transmitted. It ensures that data is temporarily stored when the transmitter is busy, preventing data loss.

#### TX FIFO Signals
- **clk**: Clock signal for the FIFO.
- **reset**: Reset signal to initialize the FIFO.
- **din**: Data input to the FIFO.
- **wr_en**: Write enable signal to write data to the FIFO.
- **dout**: Data output from the FIFO.
- **rd_en**: Read enable signal to read data from the FIFO.
- **empty**: Indicates that the FIFO is empty.
- **full**: Indicates that the FIFO is full.

### RX FIFO Module
The RX FIFO module buffers incoming data to be processed by the receiver. It ensures that data is temporarily stored when the receiver is busy, preventing data overflow.

#### RX FIFO Signals
- **clk**: Clock signal for the FIFO.
- **reset**: Reset signal to initialize the FIFO.
- **din**: Data input to the FIFO.
- **wr_en**: Write enable signal to write data to the FIFO.
- **dout**: Data output from the FIFO.
- **rd_en**: Read enable signal to read data from the FIFO.
- **empty**: Indicates that the FIFO is empty.
- **full**: Indicates that the FIFO is full.

## Testbench

The testbench (`uart_tb.v`) sets up a simulation environment to test the UART module with FIFO buffers and dynamic baud rate configuration. It generates clock signals, initiates data transmission, changes the baud rate during simulation, and monitors the behavior of the UART.

### Key Components of the Testbench
- **Clock Generation**: Generates `tx_clk` and `rx_clk` signals with different frequencies to simulate separate clock domains.
- **Data Transmission**: Random data is generated and sent through the UART for transmission.
- **Baud Rate Configuration**: Changes the baud rate during the simulation to verify dynamic adjustment.
- **Loopback Setup**: The transmitted data is looped back to the receiver to verify the correct reception.
- **Signal Monitoring**: Continuously monitors and displays the key signals and their interactions during the simulation.

### Signals in the Testbench
- **tx_clk**: Transmitter clock signal, toggling every 5 ns.
- **rx_clk**: Receiver clock signal, toggling every 7 ns.
- **start**: Signal to initiate data transmission.
- **txin**: 8-bit data input for transmission.
- **rxout**: 8-bit data output for received data.
- **rxdone**: Signal indicating reception completion.
- **txdone**: Signal indicating transmission completion.
- **bitDone_tx**: Internal signal indicating completion of a bit period for transmission.
- **bitDone_rx**: Internal signal indicating completion of a bit period for reception.
- **tx_fifo_full**: Indicates that the TX FIFO is full.
- **tx_fifo_empty**: Indicates that the TX FIFO is empty.
- **tx_fifo_wr_en**: Write enable for the TX FIFO.
- **tx_fifo_rd_en**: Read enable for the TX FIFO.
- **rx_fifo_full**: Indicates that the RX FIFO is full.
- **rx_fifo_empty**: Indicates that the RX FIFO is empty.
- **rx_fifo_wr_en**: Write enable for the RX FIFO.
- **rx_fifo_rd_en**: Read enable for the RX FIFO.
- **baud_rate**: Configurable baud rate for UART communication.
- **i**: Loop index for generating multiple data transmissions in the testbench.

### Simulation Waveform Interpretation

The simulation waveform provides insight into the behavior of the UART module with FIFO buffers and dynamic baud rate configuration. Below is a detailed breakdown of the key signals and their interactions, along with the observed behavior:

#### Clock Signals (`tx_clk` and `rx_clk`)
- **Observation**: `tx_clk` toggles every 5 ns (100 MHz), while `rx_clk` toggles every 7 ns (approximately 71.4 MHz).
- **Justification**: This demonstrates separate clock domains for the transmitter and receiver, which is crucial for systems where the transmitter and receiver operate at different clock frequencies or have different timing requirements.

#### Transmission Initiation (`start` and `txin` signals)
- **Observation**: When `start` is asserted, the transmission process begins.
- **Justification**: The start signal initiates the transmission process, moving the state machine from the idle state to the send state.

#### Bit Period Completion (`bitDone_tx` and `bitDone_rx`)
- **Observation**: `bitDone_tx` and `bitDone_rx` toggle at regular intervals, indicating the completion of each bit period for transmission and reception, respectively.
- **Justification**: These signals ensure the correct timing for each bit as per the baud rate, maintaining synchronization between the transmitted and received bits.

#### Data Transmission and Reception (`txin` and `rxout` signals)
- **Observation**: `txin` shows the data to be transmitted. `rxout` matches `txin` after the transmission and reception are complete.
- **Justification**: The data (`txin`) is correctly transmitted and received, demonstrating the functionality of the UART module with FIFO.

#### Completion Signals (`txdone` and `rxdone`)
- **Observation**: `txdone` is asserted after the transmission is complete, and `rxdone` is asserted after the reception is complete.
- **Justification**: These signals indicate the end of each transmission and reception cycle, allowing for proper synchronization and control flow in the testbench.

#### FIFO Buffering
- **Observation**: The FIFO signals (`tx_fifo_full`, `tx_fifo_empty`, `tx_fifo_wr_en`, `tx_fifo_rd_en`, `rx_fifo_full`, `rx_fifo_empty`, `rx_fifo_wr_en`, `rx_fifo_rd_en`) indicate the state and control of the FIFO buffers.
- **Justification**: The FIFOs buffer the data to prevent overflow and ensure smooth data transmission and reception.

#### Baud Rate Configuration
- **Observation**: During the simulation, the baud rate is dynamically adjusted, affecting the frequency of the `bitDone_tx` and `bitDone_rx` signals toggling.
- **Justification**: This demonstrates the UART module's capability to adapt to different communication requirements by changing the baud rate, which in turn adjusts the timing of bit period completion.

### Summary
- **Behavior**: The UART module with FIFO and dynamic baud rate configuration successfully handles the transmission and reception of data across different clock domains. The start signal initiates the transmission, and the data is correctly transmitted and received. The module

 adapts to different baud rates during the simulation, demonstrating its flexibility.
- **Timing**: The `bitDone_tx` and `bitDone_rx` signals ensure correct bit timing as per the configured baud rate, and the `txdone` and `rxdone` signals indicate the completion of each transmission and reception.
- **FIFO**: The FIFO buffers effectively manage the data flow, preventing data loss and ensuring smooth operation.
- **Baud Rate Configuration**: The ability to dynamically adjust the baud rate allows the UART module to cater to various communication requirements, making it versatile for different applications.