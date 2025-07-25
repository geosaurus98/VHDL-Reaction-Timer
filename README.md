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
- Randomized delay using 3 parallel PRNGs (extension feature)

## Top-Level Architecture
The system consists of the following main modules:

- **Top Module**: Structural VHDL module connecting all subsystems
- **FSM**: Finite state machine controlling program flow and timing logic
- **Binary Timer**: 32-bit counter tracking user reaction time
- **Clock Dividers**: Generate 1 kHz and 8 kHz system clocks
- **MUX_8to1**: Multiplexes 8-digit display and extracts BCD values
- **BCD to 7-Segment Decoder**: Converts BCD digits to segment control
- **PRNG Modules**: Generate randomized delay intervals using LFSRs
- **ALU**: Performs min, max, average operations and handles BCD conversion
- **DoubleDabbler32Bit**: Converts binary results to BCD using shift-and-add-3
- **Reaction Stats**: Stores and updates last 3 reaction times
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
6. **Restart**: Pressing BTNC again resets and restarts the test sequence.

## Button and Switch Mapping
| Input | Function               |
|-------|------------------------|
| BTNC  | Start/Stop/Reset       |
| BTNU  | Show Maximum Time      |
| BTND  | Show Minimum Time      |
| BTNR  | Show Average Time      |
| BTNL  | Clear Stored Results   |

## File Structure

```
/src
├── top_module.vhd
├── finite_state_machine.vhd
├── binary_timer.vhd
├── clock_divider.vhd
├── MUX_8to1.vhd
├── bcd_to_7seg.vhd
├── PRNG_1.vhd
├── PRNG_2.vhd
├── PRNG_3.vhd
├── ALU.vhd
├── DoubleDabbler32Bit.vhd
├── reaction_stats.vhd
└── led.vhd
```
---

## Testbenches Included  

| Testbench File            | Module Under Test        | Description |
|---------------------------|--------------------------|-------------|
| `DoubleDabbler32Bit_tb.vhd` | DoubleDabbler32Bit     | Converts binary input to 32-bit BCD |
| `MUX_8to1_tb.vhd`           | MUX_8to1               | Cycles through digits and checks display output |
| `bcd_to_7seg_tb.vhd`        | bcd_to_7seg            | Verifies segment outputs for digits 0–15 |
| `clock_divider_tb.vhd`      | clock_divider          | Validates correct division of 100 MHz input |

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
- Random delay timings are generated using three 11-bit LFSRs (one per PRNG)  
- ALU avoids invalid results when fewer than 3 reaction times are available  
- The system handles button bounce and invalid inputs gracefully

## License & Attribution
- BCD converter (DoubleDabbler32Bit) adapted from Andreas Poulsen’s public implementation (@supercigar)
- All other code authored by Group 8
- Submitted as coursework for ENEL373, University of Canterbury

## Vivado Version
Tested and synthesized using: **Vivado 2022.2**
