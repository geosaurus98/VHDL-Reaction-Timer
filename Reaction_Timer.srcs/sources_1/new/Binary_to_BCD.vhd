----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
-- 
-- Original Author: Andreas Poulsen (@supercigar) 
-- Original Create Date: 20:06:37 04/27/2020 
-- 
-- Modified by: George Johnson (2025)
-- 
-- Design Name: 32-bit Double Dabble Binary-to-BCD Converter
-- Module Name: DoubleDabbler32Bit - Behavioral Architecture
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Digilent Nexys-4 DDR FPGA Board (Artix-7 XC7A100T-1CSG324C)
-- Tool Versions: AMD Vivado 2022.2
-- 
-- Description:
-- This module converts a 32-bit unsigned binary input into a 32-bit Binary-Coded Decimal (BCD) output,
-- suitable for driving a multi-digit seven-segment display.
-- It uses the "Double Dabble" (shift-and-add-3) algorithm.
-- A synchronous FSM (Finite State Machine) structure manages the conversion process.
--
-- Dependencies: None.
--
-- Revision History:
--  - Original Version (2020): Andreas Poulsen (8-bit to 20-bit BCD converter).
--  - Revision 0.01 (2025): Adapted and expanded to 32-bit input and 32-bit BCD output.
-- 
-- Additional Comments:
--  - Used under open-source/public code guidelines with attribution.
--  - Scratchpad variable expanded to 64 bits to accommodate shifts.
--  - 8 decimal digits are assumed.

----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DoubleDabbler32Bit is
    Port (
        clk     : in  STD_LOGIC;                      -- System clock
        reset   : in  STD_LOGIC;                      -- Asynchronous reset
        start   : in  STD_LOGIC;                      -- Start conversion
        BIN     : in  STD_LOGIC_VECTOR(31 downto 0);  -- Binary input
        BCD     : out STD_LOGIC_VECTOR(31 downto 0);  -- BCD output (8 digits)
        done    : out STD_LOGIC                       -- Conversion complete flag
    );
end DoubleDabbler32Bit;

architecture Behavioral of DoubleDabbler32Bit is
    -- FSM states
    type state_type is (IDLE, RUNNING, FINISHED);
    signal state   : state_type := IDLE;

    -- Constants
    constant MAX_SHIFT_COUNT : integer := 32;

    -- Control signals
    signal counter    : integer range 0 to MAX_SHIFT_COUNT := 0;
    signal result_bcd : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
begin

    -- Double Dabble algorithm FSM
    process(clk, reset)
    variable scratch : unsigned(63 downto 0);
    begin
        if reset = '1' then
            state      <= IDLE;
            counter    <= 0;
            result_bcd <= (others => '0');
            
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if start = '1' then
                        scratch := (others => '0');
                        scratch(31 downto 0) := unsigned(BIN);
                        counter <= 0;
                        state <= RUNNING;
                    end if;
    
                when RUNNING =>
                    -- Add 3 to any BCD digit >= 5
                    for j in 0 to 7 loop
                        if scratch(63 - j*4 downto 60 - j*4) > 4 then
                            scratch(63 - j*4 downto 60 - j*4) := scratch(63 - j*4 downto 60 - j*4) + 3;
                        end if;
                    end loop;
    
                    -- Shift left
                    scratch := scratch(62 downto 0) & '0';
                    counter <= counter + 1;
    
                    if counter = 31 then
                        result_bcd <= std_logic_vector(scratch(63 downto 32));
                        state <= FINISHED;
                    end if;
    
                when FINISHED =>
                    state <= IDLE;
                    
            end case;
        end if;
    end process;

    -- Output assignments
    BCD  <= result_bcd;
    done <= '1' when state = FINISHED else '0';

end Behavioral;