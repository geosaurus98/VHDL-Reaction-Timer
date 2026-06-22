----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
-- 
-- Create Date: 03/10/2025 10:12:48 AM
-- Design Name: Reaction Timer Previous Results Storage
-- Module Name: reaction_stats - Behavioral Architecture
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Digilent Nexys-4 DDR FPGA Board (Artix-7 XC7A100T-1CSG324C)
-- Tool Versions: AMD Vivado 2022.2
-- 
-- Description:
-- This module stores the three most recent reaction times for statistical analysis.
-- It detects when a timer value is ready and shifts previous results in a FIFO structure.
-- An ALU module is instantiated to calculate the minimum, maximum, or average value.
-- 
-- Dependencies:
-- - ALU.vhd (Arithmetic Logic Unit for reaction time calculations)
-- 
-- Revision History:
--  - Revision 0.01: Initial version created to support core specifications.
-- 
-- Additional Comments:
--  - Designed to reset storage when requested and handle new results efficiently.
--  - Outputs a BCD-encoded result for easy seven-segment display.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity for storing previous results and passing them to the ALU
entity reaction_stats is
    Port (
        CLK         : in STD_LOGIC;                     -- System clock
        counter_en  : in STD_LOGIC;                     -- Timer enable signal (used to detect when to capture a result)
        storage_rst : in STD_LOGIC;                     -- Storage reset signal
        operation   : in STD_LOGIC_VECTOR(1 downto 0);  -- ALU operation selector: 01=min, 10=max, 11=avg
        result      : in STD_LOGIC_VECTOR(31 downto 0); -- Timer result to be stored
        ALU_message : out STD_LOGIC_VECTOR(31 downto 0) -- Result of ALU computation (in BCD)
    );
end reaction_stats;

architecture Behavioral of reaction_stats is

  -- ALU component declaration (performs average, min, or max)
  component ALU is
    Port (
      operation : in STD_LOGIC_VECTOR(1 downto 0);
      clk       : in STD_LOGIC;
      A, B, C, count : in STD_LOGIC_VECTOR(31 downto 0);
      result    : out STD_LOGIC_VECTOR(31 downto 0)
    );
  end component;

  -- FIFO buffer to hold the 3 most recent reaction times
  type fifo_type is array (0 to 2) of STD_LOGIC_VECTOR(31 downto 0);
  
  signal result_1 : std_logic_vector(31 downto 0) := (others =>'0');
  signal result_2 : std_logic_vector(31 downto 0) := (others =>'0');
  signal result_3 : std_logic_vector(31 downto 0) := (others =>'0');

  signal prev_counter_en : std_logic := '0';


begin
  -- Instantiate ALU for statistics calculation
  ALU_calcs : ALU
    Port map (
      operation => operation,
      count     => result,
      clk       => clk,
      A         => result_1,
      B         => result_2,
      C         => result_3,
      result    => ALU_message
    );

    -- Process to capture results and update storage
    process(CLK)
    begin
        if rising_edge(CLK) then
            if storage_rst = '1' then
                -- Reset all stored results
                result_1 <= (others => '0');
                result_2 <= (others => '0');
                result_3 <= (others => '0');

            elsif (prev_counter_en = '1') and (counter_en = '0') then
                -- Falling edge detected: capture new result
                result_3 <= result_2;
                result_2 <= result_1;
                result_1 <= result;
            end if;

            -- Update previous counter_en state
            prev_counter_en <= counter_en;
        end if;
    end process;
  
end Behavioral;