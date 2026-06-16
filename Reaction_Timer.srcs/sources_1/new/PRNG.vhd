----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
--
-- Design Name: 11-bit Pseudo-Random Number Generator (PRNG)
-- Module Name: PRNG - Behavioral Architecture
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Digilent Nexys-4 DDR FPGA Board (Artix-7 XC7A100T-1CSG324C)
-- Tool Versions: AMD Vivado 2022.2
--
-- Description:
-- Parameterised 11-bit Fibonacci LFSR (Linear Feedback Shift Register).
-- Polynomial: x^11 + x^9 + 1  (taps at bits 10 and 8, zero-indexed).
-- Period: 2^11 - 1 = 2047 states.
--
-- The LFSR runs freely on every rising clock edge regardless of enable,
-- so the output depends on the exact moment enable is asserted rather than
-- on a predictable enable pattern. When enable is high the current LFSR
-- state is latched into the output register; when enable is low the output
-- holds its last captured value. This keeps random_val stable while the
-- FSM reads it during warning states.
--
-- Generic:
--   SEED  Initial (non-zero) LFSR state. Different instances should use
--         different seeds so they occupy different positions in the sequence.
--
-- Dependencies: None.
--
-- Revision History:
--  - Revision 0.01: Initial version -- replaced three identical enable-gated
--                   modules with one generic free-running implementation.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PRNG is
    generic (
        SEED : STD_LOGIC_VECTOR(10 downto 0) := "10101010101"
    );
    Port (
        clk        : in  STD_LOGIC;
        enable     : in  STD_LOGIC;
        random_val : out STD_LOGIC_VECTOR(10 downto 0)
    );
end PRNG;

architecture Behavioral of PRNG is

    signal lfsr     : STD_LOGIC_VECTOR(10 downto 0) := SEED;
    signal captured : STD_LOGIC_VECTOR(10 downto 0) := SEED;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            lfsr <= lfsr(9 downto 0) & (lfsr(10) xor lfsr(8));  -- always advance
            if enable = '1' then
                captured <= lfsr;                                  -- latch on enable
            end if;
        end if;
    end process;

    random_val <= captured;

end Behavioral;
