----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
-- 
-- Create Date: 03/05/2025 10:02:34 PM
-- Design Name: Reaction Timer Finite State Machine (FSM)
-- Module Name: finite_state_machine - Behavioral Architecture
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Digilent Nexys-4 DDR FPGA Board (Artix-7 XC7A100T-1CSG324C)
-- Tool Versions: AMD Vivado 2022.2
-- 
-- Description:
-- This module implements the top-level finite state machine (FSM) controlling 
-- the ENEL373 Reaction Timer system. It manages prompting, timing, error detection, 
-- displaying results, and calculating statistics.
-- 
-- Dependencies:
-- - PRNG_1.vhd (Pseudo-Random Delay Generator)
-- - PRNG_2.vhd
-- - PRNG_3.vhd
-- 
-- Revision History:
--  - Revision 0.01: Initial version created for milestone and full project functionality.
-- 
-- Additional Comments:
--  - Integrates three independent PRNG instances for randomized countdown timing.
--  - Displays average, maximum, and minimum reaction times upon user request.
--  - Outputs timing and system messages directly to a 7-segment multiplexer.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity finite_state_machine is
    Port ( 
       clk                                  : in STD_LOGIC; -- Clock signal
       BTNC, BTNU, BTNR, BTND, BTNL         : in STD_LOGIC; -- Button inputs
       ALU_message                          : in STD_LOGIC_VECTOR (31 downto 0); -- ALU output input
       counter_en, counter_rst, storage_rst : out STD_LOGIC; -- Timer and storage controls
       displays_on                          : out STD_LOGIC_VECTOR(3 downto 0);   -- Active displays control
       display_data                         : out STD_LOGIC_VECTOR (31 downto 0); -- Display message output
       operation                            : out STD_LOGIC_VECTOR (1 downto 0);  -- ALU operation control
       led_display  			    : out STD_LOGIC_VECTOR (1 downto 0)); --
end finite_state_machine;

architecture Behavioral of finite_state_machine is

    component PRNG_1 is
        Port (
        clk         : in  STD_LOGIC;
        enable      : in  STD_LOGIC;
        random_val  : out STD_LOGIC_VECTOR(10 downto 0));                  
    end component;

    component PRNG_2 is
        Port (
        clk         : in  STD_LOGIC;
        enable      : in  STD_LOGIC;
        random_val  : out STD_LOGIC_VECTOR(10 downto 0));                  
    end component;

    component PRNG_3 is
        Port (
        clk         : in  STD_LOGIC;
        enable      : in  STD_LOGIC;
        random_val  : out STD_LOGIC_VECTOR(10 downto 0));                  
    end component;

    -- FSM state encoding
    type state_type is (error, warning_3, warning_2, warning_1, counting, printing, average, max, min, reset);
    signal current_state, next_state : state_type := warning_3;

    -- Internal signals
    constant MAX_T : natural := 3000; -- Maximum timer value
    signal state_timer : natural range 0 to MAX_T-1 := 0; -- Timer
    signal time_1, time_2, time_3 : STD_LOGIC_VECTOR(10 downto 0); -- Random delays
    signal timer_set : STD_LOGIC := '0'; -- Trigger for random number generation

begin

    time_inst_1 : PRNG_1
    Port map (
        clk => clk,
        enable => timer_set,
        random_val => time_1
    );

    time_inst_2 : PRNG_2
    Port map (
        clk => clk,
        enable => timer_set,
        random_val => time_2
    );

    time_inst_3 : PRNG_3
    Port map (
        clk => clk,
        enable => timer_set,
        random_val => time_3
    );

    -- State register: updates current state on rising clock edge
    STATE_REGISTER: process(clk)
    begin
        if rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- Output decoder: sets outputs based on current state
    OUTPUT_DECODE: process(current_state, ALU_message)
    begin
        -- Default output values
        displays_on <= "1000";
        counter_en  <= '0';
        counter_rst <= '0';
        operation   <= "00";
	led_display <= "00";
        display_data<= (others => '0');
        storage_rst <= '0';
        timer_set   <= '0';

        case current_state is
            when error =>
                display_data <= X"EDDCDFFF"; -- Error display

            when warning_3 =>
                displays_on  <= "0011";
                counter_rst  <= '1';
                display_data <= X"FFFFFAAA"; -- 3 dots

            when warning_2 =>
                displays_on  <= "0010";
                display_data <= X"FFFFFFAA"; -- 2 dots

            when warning_1 =>
                displays_on  <= "0001";
                display_data <= X"FFFFFFFA"; -- 1 dot

            when counting =>
                counter_en   <= '1';
                display_data <= ALU_message;

            when printing =>
                display_data <= ALU_message;
                timer_set    <= '1'; -- Trigger PRNG

            when average =>
                operation    <= "11";
                display_data <= ALU_message;
		led_display <= "11";

            when max =>
                operation    <= "10";
                display_data <= ALU_message;
		led_display <= "10";

            when min =>
                operation    <= "01";
                display_data <= ALU_message;
		led_display <= "01";

            when reset =>
                storage_rst  <= '1';
                display_data <= X"00000000";

            when others =>
                counter_rst <= '1'; -- Safety default
        end case;
    end process;
       
    -- Next state decoder: determines next state transitions
    NEXT_STATE_DECODE: process(current_state, state_timer, BTNC, BTNU, BTND, BTNR, BTNL, time_1, time_2, time_3)
    begin
        next_state <= current_state; -- Default to holding state

        case current_state is
            when error =>
                if state_timer = 999 then
                    next_state <= warning_3;
                end if;

            when warning_3 =>
                if state_timer = to_integer(unsigned(time_1)) + 200 then
                    next_state <= warning_2;
                end if;

            when warning_2 =>
                if BTNC = '1' then
                    next_state <= error;
                elsif state_timer = to_integer(unsigned(time_2)) + 200 then
                    next_state <= warning_1;
                end if;

            when warning_1 =>
                if BTNC = '1' then
                    next_state <= error;
                elsif state_timer = to_integer(unsigned(time_3)) + 200 then
                    next_state <= counting;
                end if;

            when counting =>
                if BTNC = '1' then
                    next_state <= printing;
                end if;

            when printing =>
                if BTNC = '1' and state_timer >= 999 then
                    next_state <= warning_3;
                elsif BTNU = '1' then
                    next_state <= max;
                elsif BTNR = '1' then
                    next_state <= average;
                elsif BTND = '1' then
                    next_state <= min;
                elsif BTNL = '1' then
                    next_state <= reset;
                end if;

            when average =>
                if BTNC = '1' then
                    next_state <= printing;
                elsif BTNU = '1' then
                    next_state <= max;
                elsif BTND = '1' then
                    next_state <= min;
                elsif BTNL = '1' then
                    next_state <= reset;
                end if;

            when max =>
                if BTNC = '1' then
                    next_state <= printing;
                elsif BTNR = '1' then
                    next_state <= average;
                elsif BTND = '1' then
                    next_state <= min;
                elsif BTNL = '1' then
                    next_state <= reset;
                end if;

            when min =>
                if BTNC = '1' then
                    next_state <= printing;
                elsif BTNU = '1' then
                    next_state <= max;
                elsif BTNR = '1' then
                    next_state <= average;
                elsif BTNL = '1' then
                    next_state <= reset;
                end if;

            when reset =>
                if BTNC = '1' then
                    next_state <= warning_3;
                end if;

            when others =>
                null;
        end case;
    end process;
    
    -- Timer counter: resets on state transition, increments otherwise
    TIMER: process(clk)
    begin
        if rising_edge(clk) then
            if current_state /= next_state then
                state_timer <= 0;
            elsif state_timer /= MAX_T-1 then
                state_timer <= state_timer + 1;
            end if;
        end if;
    end process;

end Behavioral;