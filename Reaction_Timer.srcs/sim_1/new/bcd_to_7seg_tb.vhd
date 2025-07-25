----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
-- 
-- Create Date: 03/16/2025 07:20:29 PM
-- Design Name: BCD to 7-Segment Decoder Testbench
-- Module Name: bcd_to_7seg_tb - Behavioral
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Digilent Nexys-4 DDR FPGA Board (Artix-7 XC7A100T-1CSG324C)
-- Tool Versions: AMD Vivado 2022.2
-- 
-- Description: 
-- This testbench verifies the correct behavior of the bcd_to_7seg module. 
-- It applies all 4-bit BCD inputs from 0 to 15 and checks the corresponding outputs 
-- on the 7-segment display segment control lines (CA to CG, DP). Only inputs 0-9 
-- are valid BCD values, so the outputs for 10-15 are undefined or invalid.
-- 
-- Expectations:
--  - For BCD inputs 0000 to 1001 (decimal 0 to 9), the outputs CA-CG should represent
--    the standard 7-segment display encoding for digits 0 to 9.
--  - For inputs 1010 to 1111 (10 to 15), output values are considered don't-care or undefined.
--  - DP (decimal point) is not used and should remain inactive (typically logic '1').
-- 
-- Dependencies: bcd_to_7seg.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- Simulation waveform should be used to visually confirm the correctness of the segment outputs.
-- This module is purely for functional simulation and does not include assertions.
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY bcd_to_7seg_tb IS
END bcd_to_7seg_tb;

ARCHITECTURE behavior OF bcd_to_7seg_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT bcd_to_7seg
        PORT (
            bcd : IN  std_logic_vector(3 downto 0);
            CA, CB, CC, CD, CE, CF, CG, DP : OUT std_logic
        );
    END COMPONENT;
   
    -- Signals to connect to the UUT
    SIGNAL bcd : std_logic_vector(3 downto 0) := "0000";
    SIGNAL CA, CB, CC, CD, CE, CF, CG, DP : std_logic;
    
BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: bcd_to_7seg
        PORT MAP (
            bcd => bcd,
            CA => CA,
            CB => CB,
            CC => CC,
            CD => CD,
            CE => CE,
            CF => CF,
            CG => CG,
            DP => DP
        );

    -- Stimulus process
    stim_proc: PROCESS
    BEGIN
        -- Apply test cases for all BCD values 0-15
        FOR i IN 0 TO 15 LOOP
            bcd <= std_logic_vector(to_unsigned(i, 4));
            WAIT FOR 20 ns;
        END LOOP;

        -- Stop the simulation
        WAIT;
    END PROCESS;

END behavior;
