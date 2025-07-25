----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
-- 
-- Create Date: 03/10/2025 10:12:48 AM
-- Design Name: 32-bit Binary Timer
-- Module Name: binary_timer - Behavioral Architecture
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Digilent Nexys-4 DDR FPGA Board (Artix-7 XC7A100T-1CSG324C)
-- Tool Versions: AMD Vivado 2022.2
-- 
-- Description:
-- This module implements a simple 32-bit binary counter for timing user reaction events.
-- It increments while enabled and resets to zero on command.
-- The counter output is a 32-bit unsigned value, converted to STD_LOGIC_VECTOR format.
-- 
-- Dependencies: None.
-- 
-- Revision History:
--  - Revision 0.01: Initial version created for Reaction Timer project.
-- 
-- Additional Comments:
--  - Compatible with ALU and seven-segment display decoding modules.
--  - Counter is synchronous with system clock.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity binary_timer is
    Port (
        counter_en  : in  STD_LOGIC;                    -- Enable signal to increment counter
        counter_rst : in  STD_LOGIC;                    -- Reset signal to clear counter
        CLK         : in  STD_LOGIC;                    -- System clock
        timer_count : out STD_LOGIC_VECTOR(31 downto 0) -- 32-bit counter output
    );
end binary_timer;

architecture Behavioral of binary_timer is

    signal counter_reg : unsigned(31 downto 0) := (others => '0');
    
begin

    -- Counter process: increment or reset on rising clock edge
    process(CLK)
    begin
        if rising_edge(CLK) then
            if counter_rst = '1' then
                counter_reg <= (others => '0');        -- Reset counter
            elsif counter_en = '1' then
                counter_reg <= counter_reg + 1;     -- Increment counter
            end if;
        end if;
    end process;

    -- Assign unsigned counter to standard logic vector output
    timer_count <= std_logic_vector(counter_reg);

end Behavioral;
