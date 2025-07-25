----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
-- 
-- Create Date: 03/17/2025 07:04:57 AM
-- Design Name: Clock Divider
-- Module Name: clock_divider - Behavioral Architecture
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Digilent Nexys-4 DDR FPGA Board (Artix-7 XC7A100T-1CSG324C)
-- Tool Versions: AMD Vivado 2022.2
-- 
-- Description:
-- This module implements a configurable clock divider.
-- It produces a slower clock output by toggling after a specified upper bound count.
-- 
-- Dependencies: None.
-- 
-- Revision History:
--  - Revision 0.01: Initial version created for Reaction Timer project.
-- 
-- Additional Comments:
--  - Slower clock (SLOWCLK) is generated by toggling the dummy signal.
--  - UPPERBOUND input allows dynamic adjustment of the clock division ratio.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider is
    Port (
        CLK         : in  STD_LOGIC;                    -- Input clock
        upper_bound  : in  STD_LOGIC_VECTOR(27 downto 0); -- Division threshold
        slow_clk     : out STD_LOGIC                      -- Output slow clock
    );
end clock_divider;

architecture Behavioral of clock_divider is

    signal count : unsigned(27 downto 0) := (others => '0'); -- Internal counter
    signal slow_clk_toggle : STD_LOGIC := '1'; -- Internal slow clock signal

begin

    -- Drive output clock from internal slow_clk_reg signal
    slow_clk <= slow_clk_toggle;

    -- Counter process: toggles slow clock when upper bound is reached
    process(CLK)
    begin
        if rising_edge(CLK) then
            if count = unsigned(upper_bound) then
                count <= (others => '0');
                slow_clk_toggle <= not slow_clk_toggle;
            else
                count <= count + 1;
            end if;
        end if;
    end process;

end Behavioral;