
----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
-- 
-- Create Date: 04/28/2025 10:22:17 AM
-- Design Name: 11-bit Pseudo-Random Number Generator (PRNG)
-- Module Name: PRNG_3 - Behavioral Architecture
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Digilent Nexys-4 DDR FPGA Board (Artix-7 XC7A100T-1CSG324C)
-- Tool Versions: AMD Vivado 2022.2
-- 
-- Description:
-- This module implements an 11-bit Linear Feedback Shift Register (LFSR) based 
-- pseudo-random number generator. 
-- The output is used to introduce randomized timing delays in the Reaction Timer.
-- 
-- Dependencies: None.
-- 
-- Revision History:
--  - Revision 0.01: Initial version created to support reaction timer randomization extension.
-- 
-- Additional Comments:
--  - LFSR taps are located at bits 10 and 8 (zero-indexed).
--  - Output range: 0 to 2047 (11 bits).
--  - Any non-zero seed can be used to initialize the LFSR.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PRNG_3 is
    Port (
        clk         : in  STD_LOGIC;                       -- System clock
        enable      : in  STD_LOGIC;                       -- Enable signal for random number generation
        random_val  : out STD_LOGIC_VECTOR(10 downto 0)    -- 11-bit pseudo-random output
    );
end PRNG_3;

architecture Behavioral of PRNG_3 is

    -- Internal LFSR register, initialized with a non-zero seed
    signal lfsr : STD_LOGIC_VECTOR(10 downto 0) := "11100011100";

begin

    -- LFSR update process
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                -- Feedback polynomial: XOR between bit 10 and bit 8
                lfsr <= lfsr(9 downto 0) & (lfsr(10) xor lfsr(8)); -- New taps at bits 10 and 8

            end if;
        end if;
    end process;

    -- Assign current LFSR state to output
    random_val <= lfsr;

end Behavioral;
