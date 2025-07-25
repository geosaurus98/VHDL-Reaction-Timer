----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
-- 
-- Create Date: 
-- Design Name: Arithmetic Logic Unit (ALU) for Reaction Timer
-- Module Name: ALU - Behavioral Architecture
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Digilent Nexys-4 DDR FPGA Board (Artix-7 XC7A100T-1CSG324C)
-- Tool Versions: AMD Vivado 2022.2
-- 
-- Description:
-- This module implements a 32-bit Arithmetic Logic Unit (ALU) for a Reaction Timer system.
-- It supports operations to pass the current count, find minimum, find maximum, or compute 
-- the average of stored reaction times.
-- The ALU output is automatically converted to Binary Coded Decimal (BCD) format.
-- 
-- Dependencies: 
-- - DoubleDabbler32Bit.vhd (Binary to BCD converter module).
-- 
-- Revision History:
--  - Revision 0.01: Initial version created to support core and extension specifications.
-- 
-- Additional Comments:
--  - Designed to integrate with reaction time storage and display modules.
--  - Output values are ready for direct 7-segment display decoding.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
  Port (
    operation : in STD_LOGIC_VECTOR(1 downto 0);           -- ALU operation: 00 = pass count, 01 = min, 10 = max, 11 = avg
    clk       : in STD_LOGIC;                              -- System clock (e.g., clk_ms)
    A, B, C, count : in STD_LOGIC_VECTOR(31 downto 0);     -- Inputs
    result    : out STD_LOGIC_VECTOR(31 downto 0)          -- Final BCD result
  );
end ALU;

architecture Behavioral of ALU is

  -- Binary to BCD conversion control
  signal start_bcd     : STD_LOGIC := '0';              -- Start signal for converter
  signal done_bcd      : STD_LOGIC;                     -- High when conversion is done
  signal bcd_output    : STD_LOGIC_VECTOR(31 downto 0); -- Final converted BCD output
  signal result_ready  : STD_LOGIC := '0';              -- Flag to control when to send to converter
  signal binary_buffer : STD_LOGIC_VECTOR(31 downto 0); -- Binary input to converter

  -- Internal unsigned values
  signal A_unsigned      : unsigned(31 downto 0);
  signal B_unsigned      : unsigned(31 downto 0);
  signal C_unsigned      : unsigned(31 downto 0);
  signal count_unsigned  : unsigned(31 downto 0);
  signal result_unsigned : unsigned(31 downto 0); -- ALU result before conversion

  -- Component declaration
  component DoubleDabbler32Bit is
    Port (
      clk     : in  STD_LOGIC;
      reset   : in  STD_LOGIC;
      start   : in  STD_LOGIC;
      BIN     : in  STD_LOGIC_VECTOR(31 downto 0);
      BCD     : out STD_LOGIC_VECTOR(31 downto 0);
      done    : out STD_LOGIC
    );
  end component;

    begin
    
    -- ALU operation (pure combinational logic)
    A_unsigned     <= unsigned(A);
    B_unsigned     <= unsigned(B);
    C_unsigned     <= unsigned(C);
    count_unsigned <= unsigned(count);
    
    process(operation, A_unsigned, B_unsigned, C_unsigned, count_unsigned)
    begin
    case operation is
      when "00" =>  -- Pass current count
        result_unsigned <= count_unsigned;
    
      when "01" =>  -- Find minimum reaction time
          if (B_unsigned = 0) and (C_unsigned = 0) then
             result_unsigned <= (A_unsigned);
          elsif (C_unsigned = 0) then
             if (A_unsigned <= B_unsigned) then
              result_unsigned <= A_unsigned;
            else
              result_unsigned <= B_unsigned;
            end if;
          else
            if (A_unsigned <= B_unsigned) and (A_unsigned <= C_unsigned) then
              result_unsigned <= A_unsigned;
            elsif (B_unsigned <= A_unsigned) and (B_unsigned <= C_unsigned) then
              result_unsigned <= B_unsigned;
            else
              result_unsigned <= C_unsigned;
            end if;
          end if;    
    
      when "10" =>  -- Find maximum reaction time
        if (A_unsigned >= B_unsigned) and (A_unsigned >= C_unsigned) then
          result_unsigned <= A_unsigned;
        elsif (B_unsigned >= A_unsigned) and (B_unsigned >= C_unsigned) then
          result_unsigned <= B_unsigned;
        else
          result_unsigned <= C_unsigned;
        end if;
    
      when "11" =>  -- Compute average reaction time
        if (B_unsigned = 0) and (C_unsigned = 0) then -- A stored
            result_unsigned <= (A_unsigned);
        elsif (C_unsigned = 0) then -- A B stored
            result_unsigned <= (A_unsigned + B_unsigned) / 2;
        else
            result_unsigned <= (A_unsigned + B_unsigned + C_unsigned) / 3;
        end if;
          
        when others =>
            result_unsigned <= (others => '0');
    end case;
    end process;
    
    -- Clocked process: Trigger BCD conversion when result changes
    process(clk)
    begin
        if rising_edge(clk) then
            if result_ready = '0' then
                binary_buffer <= std_logic_vector(result_unsigned);
                start_bcd     <= '1';    -- Start one-shot pulse
                result_ready  <= '1';    -- Prevent re-triggering
            else
                start_bcd <= '0';
            end if;
    
            if done_bcd = '1' then
                result <= bcd_output;    -- Output ready result
                result_ready <= '0';     -- Reset ready flag
            end if;
        end if;
    end process;
    
    -- Instantiation of the 32-bit Binary to BCD converter
    BINARY_TO_BCD_INIT: DoubleDabbler32Bit
        port map (
            clk   => clk,
            reset => '0',      -- No reset used
            start => start_bcd,
            BIN   => binary_buffer,
            BCD   => bcd_output,
            done  => done_bcd
        );
    
end Behavioral;