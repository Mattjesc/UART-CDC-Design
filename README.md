# UART Design with CDC, FIFO Buffers, and Dynamic Baud Rate Configuration

## Overview

This repository contains implementations of a UART (Universal Asynchronous Receiver/Transmitter) with Clock Domain Crossing (CDC), First In, First Out (FIFO) buffers, and dynamic Baud Rate Configuration (BRC). The project is divided into three versions, each adding new features to the previous one. This progression demonstrates the enhancement of UART functionality, starting from basic CDC, incorporating FIFO buffers, and finally enabling dynamic baud rate adjustment. The project addresses the lack of accessible and available information and implementations of UARTs with these additional features online.

## Project Structure

The project is organized into three folders, each representing a different version of the UART implementation:

1. **UART_CDC_BASIC**: Basic version with Clock Domain Crossing.
2. **UART_CDC_FIFO**: Enhanced version with FIFO buffers for TX and RX.
3. **UART_CDC_FIFO_BRC**: Advanced version with dynamic Baud Rate Configuration.

Each version contains a more detailed README file that explains the signals and simulation results. Please refer to these README files for in-depth information on each version.

### Why?

The project aims to provide a robust and flexible UART solution capable of handling asynchronous communication between different clock domains, managing data flow efficiently with FIFO buffers, and adapting to various communication requirements through dynamic baud rate adjustment. These features are essential for modern digital systems that require reliable and efficient data transmission.

### Clock Domain Crossing (CDC)

In UART communication, the transmitter and receiver often operate at different clock frequencies. The CDC design handles this by using separate clock signals for the transmitter (`tx_clk`) and receiver (`rx_clk`). This is crucial in UART implementations to ensure proper synchronization and data integrity when clocks are asynchronous. The use of CDC ensures that data can be reliably transmitted and received even when the clocks of the transmitting and receiving systems are not synchronized.

## Basic Principles and Intuition

### UART Communication

UART is a protocol used for asynchronous serial communication. The basic structure of UART communication involves a start bit, data bits, an optional parity bit, and a stop bit, as shown in the first image. The start bit signals the beginning of a data frame, followed by the data bits (D0-D7), optional parity bit, and the stop bit indicating the end of the frame.

The UART protocol is widely used for serial communication due to its simplicity and efficiency. The inclusion of start and stop bits ensures that the receiver can detect the beginning and end of each data frame, even when the sender and receiver are not synchronized by a common clock.

### Bit Timing and Baud Rate

The second image illustrates the timing of bits in UART communication. The baud rate defines the number of bits transmitted per second. For example, a baud rate of 9600 means 9600 bits are transmitted each second. The wait count is calculated based on the clock frequency and baud rate, determining the duration of each bit.

Accurate timing is essential for reliable UART communication. The wait count, derived from the clock frequency and baud rate, ensures that each bit is sampled at the correct interval. This precise timing allows the receiver to correctly interpret the incoming data bits, maintaining data integrity.

### State Machines for Transmission and Reception

The transmitter state machine transitions through states to send the start bit, data bits, and stop bit. The receiver state machine transitions through states to detect the start bit, receive the data bits, and stop bit. These state machines ensure the correct sequence of operations for reliable data transmission and reception.

The use of state machines simplifies the control logic for UART transmission and reception. The state machines follow a Mealy machine approach, where the outputs depend on both the current state and the inputs. This methodology is chosen because it allows for quick reactions to input changes and minimizes the number of states, reducing design complexity and resource usage. The state machines ensure that each bit is correctly sent and received in the proper sequence, handling start, data, and stop bits efficiently.

In this project, we implement three distinct process methodologies for the state machines:

### Single Process Methodology

**Single Process State Machine (Mealy)**: In this approach, both state transitions and output logic are handled within a single always block. This ensures that state and output are updated simultaneously and in sync with the clock, simplifying the design by keeping all the logic within one process.

- **Application in Project**: 
  - This methodology is used in the UART transmission state machine. The single always block manages the state transitions (idle, send, check) and updates the transmission output (`tx`) based on the current state and the `start` signal. This approach simplifies the handling of the transmission logic, ensuring that all transitions and outputs are synchronized with the `tx_clk`.

### Two Process Methodology

**Two Process State Machine (Mealy)**: This methodology separates the state transition logic and the output logic into two distinct always blocks. This separation can make the design clearer by decoupling state transitions from output generation, allowing each to be handled independently.

- **Application in Project**:
  - This approach is used in the FIFO control logic. One always block manages the state transitions (e.g., idle, read, write) based on the FIFO's status (empty, full) and control signals (`wr_en`, `rd_en`). The second always block generates the FIFO's output signals (`dout`, `empty`, `full`). By separating these concerns, the design can clearly define how state transitions trigger changes in FIFO status and outputs.

### Three Process Methodology

**Three Process State Machine (Mealy)**: This involves three separate always blocks, one for state transitions, one for output logic, and one for handling specific conditions or actions related to the state transitions. This approach can further modularize the design, making it easier to manage complex state behaviors.

- **Application in Project**:
  - This methodology is applied in the UART reception state machine. The first always block handles state transitions (e.g., idle, rwait, recv, rcheck) based on the `rx` input signal. The second always block manages the output logic for the received data (`rxout`) and the reception completion signal (`rxdone`). The third always block handles conditions such as bit sampling and timing (e.g., `bitDone_rx_reg`) to ensure accurate data reception. This modularization allows for clear separation of the reception logic, improving readability and maintainability.

## Version Details

### UART_CDC_BASIC (Version 1)

#### Overview

This version implements a basic UART with Clock Domain Crossing (CDC). It focuses on the fundamental functionality of transmitting and receiving data asynchronously between two different clock domains (`tx_clk` and `rx_clk`).

#### Key Features

- **Clock Domain Crossing**: Separate clock domains for TX and RX.
- **State Machines**: Efficient state machines for handling UART communication.

#### Simulation Waveform

The simulation waveform provides insight into the behavior of the basic UART with CDC. Below is an example of the waveform generated during the simulation:

### UART_CDC_FIFO (Version 2)

#### Overview

This version builds on the basic UART with CDC by incorporating FIFO buffers for both transmission (TX) and reception (RX). The FIFOs provide better handling of data flow and improved robustness in asynchronous communication between different clock domains.

#### Key Features

- **FIFO Buffers**: Smooth data flow management and improved robustness.

#### Simulation Waveform

The simulation waveform provides insight into the behavior of the UART with CDC and FIFO buffers. Below is an example of the waveform generated during the simulation:

### UART_CDC_FIFO_BRC (Version 3)

#### Overview

This version builds on the UART with CDC and FIFO by adding dynamic Baud Rate Configuration (BRC). The baud rate can be adjusted dynamically, allowing the UART to accommodate different communication requirements.

#### Key Features

- **Dynamic Baud Rate Configuration**: Flexibility to adapt to different communication requirements.

#### Simulation Waveform

The simulation waveform provides insight into the behavior of the UART with CDC, FIFO buffers, and dynamic baud rate configuration. Below is an example of the waveform generated during the simulation:

#### Dynamic Baud Rate Configuration

During the simulation, the baud rate is dynamically adjusted, which affects the frequency of the `bitDone_tx` and `bitDone_rx` signals toggling. This demonstrates the UART module's capability to adapt to different communication requirements by changing the baud rate, which in turn adjusts the timing of bit period completion.

## Tools and Environment

- **Vivado**: The project was developed and simulated using Vivado. Any version would work fine but in case of problems, try using 2020.2.

## Conclusion

This project demonstrates the iterative enhancement of a UART with advanced features, including CDC, FIFO buffers, and dynamic baud rate configuration. These features are crucial for modern digital communication systems, providing robustness, flexibility, and efficiency in data transmission and reception. The detailed documentation and testbenches for each version offer a comprehensive guide for understanding and implementing these features in practical applications.

For more detailed information on the signals and simulation results, please refer to the README files within each version's folder.

### Disclaimer

This project has not been tested on a real FPGA board yet and is currently limited to simulations.