----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
-- 
-- Create Date: 03/05/2025 10:02:34 PM
-- Design Name: 8-to-1 Seven-Segment Display Multiplexer with BCD Digit Extractor
-- Module Name: MUX_8to1 - Behavioral Architecture
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Digilent Nexys-4 DDR FPGA Board
-- Tool Versions: AMD Vivado 2022.2
-- 
-- Description: 
-- This module implements a behavioral 8-to-1 multiplexer for a seven-segment display system.
-- It cycles through active displays based on an internal clock-driven counter.
-- The number of active displays (1-8) is configurable via a 4-bit input.
-- Outputs the currently selected anode enable signal and corresponding 4-bit BCD digit
-- extracted from a 32-bit message input.
-- 
-- Dependencies: None
-- 
-- Revision:
-- Revision 0.02 - Integrated digit selection logic into multiplexer
--
-- Additional Comments:
--  - Designed for integration into the ENEL373 Reaction Timer project display subsystem.
--  - Active-low anode control assumed. 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUX_8to1 is
    Port (
        CLK             : in  STD_LOGIC;                        -- Clock signal for cycling through displays
        displays_active : in  STD_LOGIC_VECTOR (0 to 3);        -- Number of active displays (1 to 8)
        message         : in  STD_LOGIC_VECTOR (31 downto 0);   -- Packed 8-digit BCD message
        selected_bcd    : out STD_LOGIC_VECTOR (3 downto 0);    -- Selected BCD digit (output to 7-seg decoder)
        AN              : out STD_LOGIC_VECTOR (7 downto 0));    -- Anode control signals (active-low)
end MUX_8to1;

architecture Behavioral of MUX_8to1 is

    signal selection       : INTEGER range 0 to 7 := 0;          -- Current display index
    signal active_displays : INTEGER range 1 to 8 := 1;          -- Total number of active digits (minimum 1)

begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            if to_integer(unsigned(displays_active)) = 0 then
                active_displays <= 1;
            else
                active_displays <= to_integer(unsigned(displays_active));
            end if;
    
            selection <= (selection + 1) mod active_displays;
        end if;
    end process;

    -- Output logic: drive AN, sel, and selected_bcd based on current selection
    process(selection, message)
    begin

        case selection is
            when 0 =>
                AN <= "11111110";
                selected_bcd <= message(3 downto 0);
            when 1 =>
                AN <= "11111101";
                selected_bcd <= message(7 downto 4);
            when 2 =>
                AN <= "11111011";
                selected_bcd <= message(11 downto 8);
            when 3 =>
                AN <= "11110111";
                selected_bcd <= message(15 downto 12);
            when 4 =>
                AN <= "11101111";
                selected_bcd <= message(19 downto 16);
            when 5 =>
                AN <= "11011111";
                selected_bcd <= message(23 downto 20);
            when 6 =>
                AN <= "10111111";
                selected_bcd <= message(27 downto 24);
            when 7 =>
                AN <= "01111111";
                selected_bcd <= message(31 downto 28);
            when others =>
                AN <= "11111111";
                selected_bcd <= "1111"; -- blank/error
        end case;
    end process;

end Behavioral;
