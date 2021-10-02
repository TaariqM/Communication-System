# Communication-System

This project simulates a communication system that also investigates the performance of three modulation techniques, in terms of bit error rate, as a function of SNR (Signal to Noise Ratio)

The three modulation techniques are:
* BPSK (Binary Phase Shift Keying)
* OOK (On-Off Keying)
* QPSK (Quadrature Phase Shift Keying)

Each modulation technique is implemented in three different files.

These files simulate a communication system, by implementing a transmitter, a channel, and a receiver.

## Receiver
The receiver consists of a Symbol Mapper. Its here where the modulation technique is implemented.

## Channel
The channel simulates a medium that the transmitted data travels through. White Gaussian Noise gets added to the transmitted data.

## Receiver
The receiver contains a decision device, that will check if the received data bits are above or below a certain threshold. This threshold will change, depending on the modulation technique used

## Bit Errors
The number of errors are then calculated. Number of errors is determined by comparing the received bits with the transmitted bits and counting how many times the bits dont match with each other.

This number is then divided by the total number of bits that were sent. This will give the bit error rate

## Displayed Plots
This project also displays a Bit Error Rate vs. SNR graph, which plots 3 curves corresponding to the theoretical probability of a bit error, the estimated probability of a bit error when 100 blocks of data is transmitted, and the estimated probability of a bit error when sufficient blocks of data are transmitted so that at least 50 errors are counted for each SNR point.
