----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
-- 
-- Create Date: 03/05/2025 10:02:34 PM
-- Design Name: Reaction Timer Top-Level Module
-- Module Name: top_module - Structural Architecture
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Digilent Nexys-4 DDR FPGA Board (Artix-7 XC7A100T-1CSG324C)
-- Tool Versions: AMD Vivado 2022.2
-- 
-- Description:
-- This module connects and coordinates all submodules to implement the full Reaction Timer project.
-- It handles user inputs, timing, state control, randomization, and seven-segment display outputs.
-- 
-- Dependencies:
-- - clock_divider.vhd
-- - binary_timer.vhd
-- - finite_state_machine.vhd
-- - reaction_stats.vhd
-- - bcd_to_7seg.vhd
-- - MUX_8to1.vhd
-- 
-- Revision History:
--  - Revision 0.01: Initial version created for project submission.
-- 
-- Additional Comments:
--  - Uses two clock dividers for system timing and multiplexing refresh rate.
--  - Provides visual indication of ALU operations via LEDs.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Top Module
entity top_module is
    Port (
        CLK100MHZ                    : in STD_LOGIC;                      -- System clock input
        BTNU, BTNL, BTNR, BTND, BTNC : in STD_LOGIC;                      -- Button presses
        CA, CB, CC, CD, CE, CF, CG   : out STD_LOGIC;                     -- 7-segment display outputs
        DP                           : out STD_LOGIC;                     -- Decimal point output
        AN                           : out STD_LOGIC_VECTOR (7 downto 0); -- 8-bit display control
        LED                          : out STD_LOGIC_VECTOR (15 downto 0) -- LED 
    );
end top_module;

architecture Structural of top_module is

    -- Component Declarations
    
    component bcd_to_7seg is
        Port ( bcd                          : in STD_LOGIC_VECTOR (3 downto 0);           
               CA, CB, CC, CD, CE, CF, CG   : out STD_LOGIC;
               DP                           : out STD_LOGIC);                    
    end component;

    component clock_divider is
        Port ( CLK        : in STD_LOGIC;
               upper_bound : in STD_LOGIC_VECTOR (27 downto 0);
               slow_clk    : out STD_LOGIC);
    end component;
    
    component finite_state_machine is
        Port ( clk                                  : in STD_LOGIC;
               BTNC, BTNU, BTNR, BTND, BTNL         : in STD_LOGIC; 
               ALU_message                          : in STD_LOGIC_VECTOR (31 downto 0);
	           counter_en, counter_rst, storage_rst : out STD_LOGIC;
       	       displays_on                          : out STD_LOGIC_VECTOR(3 downto 0);
               display_data                         : out STD_LOGIC_VECTOR (31 downto 0);
               operation, led_display               : out STD_LOGIC_VECTOR (1 downto 0));
    end component;
        
    component binary_timer is
        Port ( counter_en  : in STD_LOGIC;
               counter_rst : in STD_LOGIC;
               CLK         : in STD_LOGIC;
               timer_count : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    
    component MUX_8to1 is
        Port ( CLK             : in STD_LOGIC;
               displays_active : in STD_LOGIC_VECTOR(3 downto 0);
               message         : in STD_LOGIC_VECTOR(31 downto 0);
               selected_bcd    : out STD_LOGIC_VECTOR(3 downto 0);
               AN              : out STD_LOGIC_VECTOR(7 downto 0));
    end component;
    
    component reaction_stats is
        Port ( CLK                     : in STD_LOGIC;
               counter_en, storage_rst : in STD_LOGIC;
               operation               : in STD_LOGIC_VECTOR(1 downto 0);
               result                  : in STD_LOGIC_VECTOR(31 downto 0);
               ALU_message             : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    
    component operation_leds is
        Port ( led_display  : STD_LOGIC_VECTOR(1 downto 0);
               led_pattern : out STD_LOGIC_VECTOR(15 downto 0));
    end component;

    -- Clock and control signals
    signal fast_clk      : STD_LOGIC;  -- ~8kHz for display refresh
    signal clk_ms        : STD_LOGIC;  -- ~1kHz for timing (1 ms tick)
    
    -- Clock divider upper bounds
    signal upper_bound_fast : STD_LOGIC_VECTOR(27 downto 0) := X"00030D4";
    signal upper_bound_ms   : STD_LOGIC_VECTOR(27 downto 0) := X"000C350";
    
    -- Timer and ALU I/O
    signal timer_count   : STD_LOGIC_VECTOR(31 downto 0); -- Timer result in ms
    signal alu_result    : STD_LOGIC_VECTOR(31 downto 0); -- ALU result (avg, min, max)
    
    -- Display data path
    signal display_data  : STD_LOGIC_VECTOR(31 downto 0); -- Data currently displayed
    signal selected_bcd  : STD_LOGIC_VECTOR(3 downto 0);  -- Digit for 7-seg display

    -- Control signals for timer and storage
    signal counter_en    : STD_LOGIC;                         -- Enables the binary timer (starts counting)
    signal counter_rst   : STD_LOGIC;                         -- Resets the binary timer to zero
    signal storage_rst   : STD_LOGIC;                         -- Resets stored reaction statistics in ALU module
    
    -- Display configuration
    signal displays_on   : STD_LOGIC_VECTOR(3 downto 0);      -- Number of active digits to cycle through on the display
    
    -- ALU operation selector
    signal operation     : STD_LOGIC_VECTOR(1 downto 0);      -- Selects statistic to display: avg (BTNR), max (BTNU), min (BTND)
    
    -- LED configuration
    signal led_display   : STD_LOGIC_VECTOR(1 downto 0);      -- Controls which LED's are powered on

begin

    clk_div_fast : clock_divider
        Port map (
            CLK => CLK100MHZ,
            upper_bound => upper_bound_fast,
            slow_clk => fast_clk );
    
    clk_div_ms : clock_divider
        Port map (
            CLK => CLK100MHZ,
            upper_bound => upper_bound_ms,
            slow_clk => clk_ms );

    binary_timer_inst : binary_timer
        port map ( 
            counter_en => counter_en, 
            counter_rst => counter_rst, 
            CLK => clk_ms, 
            timer_count => timer_count );

    fsm : finite_state_machine
        Port map (
            clk => clk_ms,
            operation => operation,
            BTNC => BTNC, 
            BTNR => BTNR, 
            BTNU => BTNU, 
            BTND => BTND, 
            BTNL => BTNL,
            ALU_message => alu_result,
            counter_en => counter_en, 
            counter_rst => counter_rst,          
            display_data => display_data,
            displays_on => displays_on,
            storage_rst => storage_rst, 
            led_display => led_display);

    bcd_convert : bcd_to_7seg
        Port map ( 
            bcd => selected_bcd, 
            CA => CA, 
            CB => CB, 
            CC => CC, 
            CD => CD, 
            CE => CE, 
            CF => CF, 
            CG => CG, 
            DP => DP );

    mux_display : MUX_8to1
        Port map ( 
            CLK => fast_clk, 
            displays_active => displays_on,
            message => display_data, 
            AN => AN, 
            selected_bcd => selected_bcd );
    
    stats: reaction_stats
        Port map ( 
            CLK => clk_ms, 
            counter_en => counter_en, 
            operation => operation, 
            storage_rst => storage_rst, 
            result => timer_count, 
            ALU_message => alu_result );
    
    LED_disp: operation_leds
        Port map (
            led_display => led_display,  
            led_pattern => LED );
    
end Structural;