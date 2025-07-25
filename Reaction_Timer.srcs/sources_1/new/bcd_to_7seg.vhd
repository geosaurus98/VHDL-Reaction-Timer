----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
-- 
-- Create Date: 03/05/2025 10:02:34 PM
-- Design Name: BCD to 7-Segment Display Decoder
-- Module Name: bcd_to_7seg - Behavioral
-- Project Name: Reaction Timer
-- Target Devices: Digilent Nexys-4 DDR FPGA (Artix-7 XC7A100T)
-- Tool Versions: Vivado 2022.2
--
-- Description: 
-- This module implements a behavioral BCD to 7-segment decoder.
-- It translates a 4-bit binary coded decimal (BCD) input into corresponding 
-- control signals for a common-cathode seven-segment display.
-- It supports numeric digits (0-9), a decimal point (DP), and basic error 
-- characters ("O", "R", "E") for system error feedback.
-- Default behavior for undefined BCD inputs is to blank the display.
--
-- Dependencies: None
-- 
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--     - Part of ENEL373 Reaction Timer Project.
--     - Designed to meet core specification for numerical and error display.
--     - Default 'blank' output for undefined BCD values.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bcd_to_7seg is
    Port ( bcd : in STD_LOGIC_VECTOR (3 downto 0); -- BCD input
           CA : out STD_LOGIC;                     -- Segment A
           CB : out STD_LOGIC;                     -- Segment B
           CC : out STD_LOGIC;                     -- Segment C
           CD : out STD_LOGIC;                     -- Segment D
           CE : out STD_LOGIC;                     -- Segment E
           CF : out STD_LOGIC;                     -- Segment F
           CG : out STD_LOGIC;					   -- Segment G
           DP : out STD_LOGIC                      -- Decimal Point
    );
end bcd_to_7seg;

architecture Behavioral of bcd_to_7seg is
    signal segment_pattern : STD_LOGIC_VECTOR (0 to 7);        -- 7-segment display output
begin

    -- BCD to 7-segment conversion logic
    process (bcd)
    begin
        case bcd is
            when "0000" => segment_pattern <= "00000011"; -- '0'
            when "0001" => segment_pattern <= "10011111"; -- '1'
            when "0010" => segment_pattern <= "00100101"; -- '2'
            when "0011" => segment_pattern <= "00001101"; -- '3'
            when "0100" => segment_pattern <= "10011001"; -- '4'
            when "0101" => segment_pattern <= "01001001"; -- '5'
            when "0110" => segment_pattern <= "01000001"; -- '6'
            when "0111" => segment_pattern <= "00011111"; -- '7'
            when "1000" => segment_pattern <= "00000001"; -- '8'
            when "1001" => segment_pattern <= "00001001"; -- '9'
            when "1010" => segment_pattern <= "11111110"; -- Decimal Point (DP only)
            when "1011" => segment_pattern <= "11111111"; -- Blank (unused)
            when "1100" => segment_pattern <= "11000101"; -- 'O' (for "Error" display)
            when "1101" => segment_pattern <= "11110101"; -- 'R' (for "Error" display)
            when "1110" => segment_pattern <= "01100001"; -- 'E' (for "Error" display)
            when others => segment_pattern <= "11111111"; -- Default to blank
        end case;
    end process; 

    -- Assign decoded segments to outputs
    CA <= segment_pattern(0);
    CB <= segment_pattern(1);
    CC <= segment_pattern(2);
    CD <= segment_pattern(3);
    CE <= segment_pattern(4);
    CF <= segment_pattern(5);
    CG <= segment_pattern(6);
    DP <= segment_pattern(7);
    
end Behavioral;