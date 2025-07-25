----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
--
-- Create Date: 03/01/2025
-- Design Name: Clock Divider Testbench
-- Module Name: clock_divider_tb - Behavioral
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Simulation only
-- Tool Versions: AMD Vivado 2022.2
--
-- Description:
-- This testbench verifies the behavior of the clock_divider module by applying
-- a fast clock input and a small upper_bound value, and observing the output slow_clk toggling.
--
-- Expectations:
--  - slow_clk toggles every (upper_bound + 1) rising edges of CLK.
--  - Using a small upper_bound (e.g., 3) allows simulation within a short time frame.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider_tb is
end clock_divider_tb;

architecture behavior of clock_divider_tb is

    -- Component Declaration
    component clock_divider
        Port (
            CLK          : in  STD_LOGIC;
            upper_bound  : in  STD_LOGIC_VECTOR(27 downto 0);
            slow_clk     : out STD_LOGIC
        );
    end component;

    -- Signals for testbench
    signal CLK         : STD_LOGIC := '0';
    signal upper_bound : STD_LOGIC_VECTOR(27 downto 0) := (others => '0');
    signal slow_clk    : STD_LOGIC;

    -- Clock period definition
    constant clk_period : time := 10 ns; -- 100 MHz clock

begin

    -- Instantiate Unit Under Test
    uut: clock_divider
        port map (
            CLK         => CLK,
            upper_bound => upper_bound,
            slow_clk    => slow_clk
        );

    -- Clock generation
    clk_process : process
    begin
        while now < 500 ns loop
            CLK <= '0';
            wait for clk_period / 2;
            CLK <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        -- Set upper bound to a small value for faster simulation
        upper_bound <= std_logic_vector(to_unsigned(3, 28));  -- Toggles every 4 cycles
        wait for 500 ns;
        wait;
    end process;

end behavior;
