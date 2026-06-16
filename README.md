# ENEL373 Reaction Timer Project
University of Canterbury – Department of Electrical and Computer Engineering  
Group 8  
- Matthew Claridge  
- Joel Dunwoodie  
- George Johnson  

## Project Overview
This project implements a digital **Reaction Timer** on the Digilent **Nexys-4 DDR FPGA** (Artix-7 XC7A100T-1CSG324C) as part of the ENEL373 course.  
It measures and displays a user's reaction time with millisecond precision and includes statistical tracking features such as average, minimum, and maximum times.

## Core Features
- Visual prompting with sequentially disabled decimal points
- Millisecond-accurate timing triggered via BTNC
- Seven-segment display output with active display multiplexing
- Support for statistical operations (AVG, MIN, MAX)
- Error detection for early input
- Configurable number of displayed digits
- Randomised delay using a parameterised free-running LFSR (extension feature)

## Top-Level Architecture
The system consists of the following main modules:

- **Top_Module**: Structural VHDL module connecting all subsystems
- **FSM**: Finite state machine controlling program flow and timing logic
- **Binary Timer**: 32-bit counter tracking user reaction time
- **Clock Dividers**: Generate 1 kHz and 8 kHz system clocks
- **Multiplexer**: Multiplexes 8-digit display and extracts BCD values
- **BCD to 7-Segment Decoder**: Converts BCD digits to segment control signals
- **PRNG**: Parameterised 11-bit free-running LFSR; three instances with different seeds generate independent randomised delay intervals
- **ALU**: Purely combinational 32-bit arithmetic and logic unit (ADD, SUB, AND, OR, XOR, NOT, SLT, PASS) with zero, carry, overflow, and negative flags
- **Reaction Stats**: Stores the last 3 reaction times and computes min, max, and average; converts the result to BCD for display
- **Binary to BCD**: Converts 32-bit binary values to BCD using the Double Dabble (shift-and-add-3) algorithm
- **LED Display Control**: Maps operation states to board LEDs

## How It Works
1. **Startup**: System begins with 3 decimal points lit (indicating a pending test).
2. **Prompting**: Decimal points are turned off sequentially at random intervals (between 0.200 and 2.248 seconds).
3. **Timing**: When the last prompt disappears, the timer starts.
4. **User Input**: User presses **BTNC** to stop the timer. Reaction time is stored.
5. **Display Mode**: Users can view:
   - **Average** via **BTNR**
   - **Maximum** via **BTNU**
   - **Minimum** via **BTND**
   - **Clear results** via **BTNL**
6. **Restart**: Pressing BTNC again (after ~1 second) resets and restarts the test sequence.

## Button and Switch Mapping
| Input | Function               |
|-------|------------------------|
| BTNC  | Start/Stop/Restart     |
| BTNU  | Show Maximum Time      |
| BTND  | Show Minimum Time      |
| BTNR  | Show Average Time      |
| BTNL  | Clear Stored Results   |

## File Structure

```
Reaction_Timer.srcs/
├── sources_1/new/
│   ├── Top_Module.vhd
│   ├── fsm.vhd
│   ├── binary_timer.vhd
│   ├── clock_divider.vhd
│   ├── Multiplexer.vhd
│   ├── bcd_to_7seg.vhd
│   ├── PRNG.vhd
│   ├── ALU.vhd
│   ├── Binary_to_BCD.vhd
│   ├── reaction_stats.vhd
│   └── led.vhd
├── sim_1/new/
│   ├── DoubleDabbler32Bit_tb.vhd
│   ├── MUX_8to1_tb.vhd
│   ├── bcd_to_7seg_tb.vhd
│   └── clock_divider_tb.vhd
└── constrs_1/new/
    └── (constraints file)
```

---

## Testbenches Included  

| Testbench File              | Module Under Test   | Description                                      |
|-----------------------------|---------------------|--------------------------------------------------|
| `DoubleDabbler32Bit_tb.vhd` | Binary_to_BCD       | Converts binary input to 32-bit BCD             |
| `MUX_8to1_tb.vhd`           | Multiplexer         | Cycles through digits and checks display output  |
| `bcd_to_7seg_tb.vhd`        | bcd_to_7seg         | Verifies segment outputs for digits 0–15         |
| `clock_divider_tb.vhd`      | clock_divider       | Validates correct division of 100 MHz input      |

---

## Simulation Guide  

To simulate and verify individual modules using Vivado:  
1. Open your project in **Vivado 2022.2**  
2. Add the corresponding testbench file  
3. Run **Behavioral Simulation**  
4. Observe waveforms and signals such as `state`, `counter_en`, `done`, or `selected_bcd` to verify functionality  

Note: Simulations are most effective when comparing expected vs. actual transitions in waveform viewer.

---

## Notes  
- Seven-segment digits are updated using an 8-digit active display multiplexer  
- All modules are **synthesizable** and **simulation-ready**  
- Random delays use one parameterised free-running LFSR (`PRNG.vhd`), instantiated three times with different seeds
- `reaction_stats` handles min/max/average computation and BCD conversion; it correctly handles cases where fewer than 3 reaction times have been stored
- The system detects early button presses and displays an error message before restarting

## License & Attribution
- BCD converter (`Binary_to_BCD.vhd`) adapted from Andreas Poulsen's public implementation (@supercigar)
- All other code authored by Group 8
- Submitted as coursework for ENEL373, University of Canterbury

## Vivado Version
Tested and synthesized using: **Vivado 2022.2**
