----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
-- 
-- Create Date: 05/02/2025 04:25:58 PM
-- Design Name: LED Display Control
-- Module Name: operation_leds - Behavioral
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Digilent Nexys-4 DDR FPGA Board (Artix-7 XC7A100T-1CSG324C)
-- Tool Versions: AMD Vivado 2022.2
-- 
-- Description: 
-- This module outputs a 16-bit LED pattern based on the selected reaction time 
-- statistic to be displayed: minimum, maximum, or average. It supports intuitive
-- visual feedback for users interacting with the reaction timer system.
-- 
-- Dependencies: None
-- 
-- Revision History:
--  - Revision 0.01: Initial version created for ENEL373 submission.
-- 
-- Additional Comments:
--  - This module is connected to the ALU statistical output selector.
--  - LED patterns provide a visual cue corresponding to the operation performed.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity operation_leds is
    Port (
        led_display : in  STD_LOGIC_VECTOR(1 downto 0); -- 2-bit led_display selector
        led_pattern : out STD_LOGIC_VECTOR(15 downto 0) -- 16-bit LED output pattern
    );
end operation_leds;

architecture Behavioral of operation_leds is

    -- LED pattern definitions for each operation type
    constant LED_NONE : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); -- No LEDs lit
    constant LED_MIN  : STD_LOGIC_VECTOR(15 downto 0) := "0000000000011111"; -- Rightmost LEDs
    constant LED_MAX  : STD_LOGIC_VECTOR(15 downto 0) := "1111100000000000"; -- Leftmost LEDs
    constant LED_AVG  : STD_LOGIC_VECTOR(15 downto 0) := "0000011111100000"; -- Middle LEDs

begin

    -- Output the correct LED pattern based on the current led_display value
    process(led_display) 
    begin
        case led_display is
            when "00" =>
                led_pattern <= LED_NONE; -- No operation
            when "01" =>
                led_pattern <= LED_MIN;  -- Min operation
            when "10" =>
                led_pattern <= LED_MAX;  -- Max operation
            when "11" =>
                led_pattern <= LED_AVG;  -- Avg operation
            when others =>
                led_pattern <= LED_NONE; -- Safety default
        end case;
    end process;

end Behavioral;