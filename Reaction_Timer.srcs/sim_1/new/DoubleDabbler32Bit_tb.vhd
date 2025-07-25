----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
--
-- Create Date: 05/16/2025
-- Design Name: Double Dabble 32-bit Testbench
-- Module Name: DoubleDabbler32Bit_tb - Behavioral
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Simulation only
-- Tool Versions: AMD Vivado 2022.2
--
-- Description:
-- This testbench verifies the functionality of the 32-bit binary-to-BCD converter module.
-- It applies various binary inputs, initiates the conversion, and waits for completion.
-- Expected outputs should be confirmed using simulation waveforms.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DoubleDabbler32Bit_tb is
end DoubleDabbler32Bit_tb;

architecture sim of DoubleDabbler32Bit_tb is

    -- Component Declaration
    component DoubleDabbler32Bit
        Port (
            clk     : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            start   : in  STD_LOGIC;
            BIN     : in  STD_LOGIC_VECTOR(31 downto 0);
            BCD     : out STD_LOGIC_VECTOR(31 downto 0);
            done    : out STD_LOGIC
        );
    end component;

    -- Signals
    signal clk_tb     : STD_LOGIC := '0';
    signal reset_tb   : STD_LOGIC := '0';
    signal start_tb   : STD_LOGIC := '0';
    signal BIN_tb     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal BCD_tb     : STD_LOGIC_VECTOR(31 downto 0);
    signal done_tb    : STD_LOGIC;

    constant clk_period : time := 10 ns;

begin

    -- Instantiate Unit Under Test
    uut: DoubleDabbler32Bit
        port map (
            clk   => clk_tb,
            reset => reset_tb,
            start => start_tb,
            BIN   => BIN_tb,
            BCD   => BCD_tb,
            done  => done_tb
        );

    -- Clock process
    clk_process : process
    begin
        while now < 400 ns loop
            clk_tb <= '0';
            wait for clk_period / 2;
            clk_tb <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
        procedure start_conversion(input_val : in std_logic_vector(31 downto 0)) is
        begin
            BIN_tb <= input_val;
            start_tb <= '1';
            wait for clk_period;
            start_tb <= '0';
            wait until done_tb = '1';
            wait for clk_period;  -- Let done go back low
        end procedure;
    begin
        -- Reset the system
        reset_tb <= '1';
        wait for clk_period * 2;
        reset_tb <= '0';
        wait for clk_period * 2;

        -- Test 1: Convert 65432
        start_conversion(std_logic_vector(to_unsigned(65432, 32)));

        -- Finish
        wait;
    end process;

end sim;