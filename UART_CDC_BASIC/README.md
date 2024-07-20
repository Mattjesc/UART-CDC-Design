# UART with Clock Domain Crossing (CDC) - Basic Version

## Overview

This repository contains a basic implementation of a UART (Universal Asynchronous Receiver/Transmitter) with Clock Domain Crossing (CDC). The design focuses on the fundamental functionality of transmitting and receiving data asynchronously between two different clock domains (`tx_clk` and `rx_clk`). 

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

## Testbench

The testbench (`uart_tb.v`) sets up a simulation environment to test the UART module. It generates clock signals, initiates data transmission, and monitors the behavior of the UART.

### Key Components of the Testbench
- **Clock Generation**: Generates `tx_clk` and `rx_clk` signals with different frequencies to simulate separate clock domains.
- **Data Transmission**: Random data is generated and sent through the UART for transmission.
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
- **i**: Loop index for generating multiple data transmissions in the testbench.

### Simulation Waveform Interpretation

The simulation waveform provides insight into the behavior of the UART module with Clock Domain Crossing (CDC). Below is a detailed breakdown of the key signals and their interactions, along with the observed behavior:

#### Clock Signals (`tx_clk` and `rx_clk`)
- **Observation**: `tx_clk` toggles every 5 ns (100 MHz), while `rx_clk` toggles every 7 ns (approximately 71.4 MHz).
- **Justification**: This demonstrates separate clock domains for the transmitter and receiver, which is crucial for systems where the transmitter and receiver operate at different clock frequencies or have different timing requirements.

#### Transmission Initiation (`start` and `txin` signals)
- **Observation**: When `start` is asserted, the transmission process begins with the `txin` data being serialized and output through the `tx` signal.
- **Justification**: The start signal initiates the transmission process, moving the state machine from the idle state to the send state, where the `tx` signal outputs the serialized data.

#### Bit Period Completion (`bitDone_tx` and `bitDone_rx`)
- **Observation**: `bitDone_tx` and `bitDone_rx` toggle at regular intervals, indicating the completion of each bit period for transmission and reception, respectively.
- **Justification**: These signals ensure the correct timing for each bit as per the baud rate, maintaining synchronization between the transmitted and received bits.

#### Data Transmission and Reception (`txin` and `rxout` signals)
- **Observation**: `txin` shows the data to be transmitted. `rxout` matches `txin` after the transmission and reception are complete.
- **Justification**: The data (`txin`) is correctly transmitted and received (`rxout`), demonstrating the functionality of the UART module.

#### Completion Signals (`txdone` and `rxdone`)
- **Observation**: `txdone` is asserted after the transmission is complete, and `rxdone` is asserted after the reception is complete.
- **Justification**: These signals indicate the end of each transmission and reception cycle, allowing for proper synchronization and control flow in the testbench.

#### Multiple Transmissions and Receptions (`i` and loop in testbench)
- **Observation**: The loop in the testbench generates multiple data transmissions (`txin` changes), and the `start` signal is toggled accordingly. The waveform shows several instances of data being transmitted and received.
- **Justification**: This demonstrates the ability of the UART module to handle multiple transmissions and receptions in sequence, ensuring robustness and reliability.

### Comprehensive Explanation of Each Step in the Waveform
- **Initial Setup**: All signals are initialized. `tx` and `rx` are idle (high), `start` is low, and `txin` is zero.
- **First Transmission**: `start` is asserted, `txin` is set to a random value. The transmission process begins, serializing the data and outputting through the `tx` signal.
- **Completion of First Transmission**: `txdone` is asserted, indicating the end of the transmission.
- **First Reception**: The received data is processed and output through the `rxout` signal.
- **Completion of First Reception**: `rxdone` is asserted, indicating the end of the reception.
- **Subsequent Transmissions and Receptions**: The loop generates new `txin` values, and the process repeats.

### Summary
- **Behavior**: The UART module successfully handles the transmission and reception of data with separate clock domains. The start signal initiates the transmission, and the data is correctly transmitted and received (`rxout`).
- **Timing**: The `bitDone_tx` and `bitDone_rx` signals ensure correct bit timing as per the baud rate, and the `txdone` and `rxdone` signals indicate the completion of each transmission and reception.
- **Multiple Cycles**: The module can handle multiple transmissions and receptions sequentially, as demonstrated by the loop in the testbench.
