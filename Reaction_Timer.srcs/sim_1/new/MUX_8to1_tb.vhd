----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
--
-- Create Date: 04/07/2025
-- Design Name: MUX_8to1 Testbench
-- Module Name: MUX_8to1_tb - Behavioral
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Simulation only
-- Tool Versions: AMD Vivado 2022.2
--
-- Description:
-- This testbench verifies that the MUX_8to1 module correctly cycles through anodes
-- and outputs the appropriate 4-bit BCD digits from the message input. It also checks
-- correct behavior for different values of displays_active.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUX_8to1_tb is
end MUX_8to1_tb;

architecture behavior of MUX_8to1_tb is

    -- Component declaration
    component MUX_8to1
        Port (
            CLK             : in  STD_LOGIC;
            displays_active : in  STD_LOGIC_VECTOR (0 to 3);
            message         : in  STD_LOGIC_VECTOR (31 downto 0);
            selected_bcd    : out STD_LOGIC_VECTOR (3 downto 0);
            AN              : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    -- Signals for connecting to UUT
    signal CLK_tb             : STD_LOGIC := '0';
    signal displays_active_tb : STD_LOGIC_VECTOR (0 to 3) := "1000"; -- Default: 8 displays
    signal message_tb         : STD_LOGIC_VECTOR (31 downto 0);
    signal selected_bcd_tb    : STD_LOGIC_VECTOR (3 downto 0);
    signal AN_tb              : STD_LOGIC_VECTOR (7 downto 0);

    constant clk_period : time := 20 ns; -- 50 MHz

begin

    -- Instantiate UUT
    uut: MUX_8to1
        port map (
            CLK             => CLK_tb,
            displays_active => displays_active_tb,
            message         => message_tb,
            selected_bcd    => selected_bcd_tb,
            AN              => AN_tb
        );

    -- Clock process
    clk_process : process
    begin
        while now < 2000 ns loop
            CLK_tb <= '0';
            wait for clk_period / 2;
            CLK_tb <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        -- Assign message "01234567" in packed BCD
        message_tb <= x"76543210";

        wait for 300 ns;

        -- Change to show only 3 digits
        displays_active_tb <= "0011";
        wait for 200 ns;
        
        -- Change to show only 2 digits
        displays_active_tb <= "0010";
        wait for 200 ns;
        
        -- Change to show only 1 digit
        displays_active_tb <= "0001";
        wait for 200 ns;       

        -- Back to full 8 digits
        displays_active_tb <= "1000";
        wait for 400 ns;

        -- Set to 0 (should default to 1 digit)
        displays_active_tb <= "0000";
        wait for 400 ns;

        wait;
    end process;

end behavior;
