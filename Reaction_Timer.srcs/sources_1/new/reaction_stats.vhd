----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
--
-- Create Date: 03/10/2025 10:12:48 AM
-- Design Name: Reaction Timer Statistics and Display Module
-- Module Name: reaction_stats - Behavioral Architecture
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Digilent Nexys-4 DDR FPGA Board (Artix-7 XC7A100T-1CSG324C)
-- Tool Versions: AMD Vivado 2022.2
--
-- Description:
-- Stores the three most recent reaction times in a FIFO and computes min, max,
-- or average on demand. The binary result is converted to BCD via the Double
-- Dabble algorithm for direct 7-segment display output.
--
-- Operation selector (operation port):
--   00  PASS : output current timer count (BCD)
--   01  MIN  : minimum of stored reaction times
--   10  MAX  : maximum of stored reaction times
--   11  AVG  : average of stored reaction times
--
-- Dependencies:
--   Binary_to_BCD.vhd  (DoubleDabbler32Bit -- binary-to-BCD converter)
--
-- Revision History:
--  - Revision 0.01: Initial version.
--  - Revision 0.02: Stats and BCD conversion moved here from the former ALU stub.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reaction_stats is
    Port (
        CLK         : in  STD_LOGIC;                     -- System clock (clk_ms)
        counter_en  : in  STD_LOGIC;                     -- Falling edge triggers result capture
        storage_rst : in  STD_LOGIC;                     -- Clears stored reaction times
        operation   : in  STD_LOGIC_VECTOR(1 downto 0);  -- Statistic selector
        result      : in  STD_LOGIC_VECTOR(31 downto 0); -- Current timer value (binary ms)
        ALU_message : out STD_LOGIC_VECTOR(31 downto 0)  -- BCD-encoded display value
    );
end reaction_stats;

architecture Behavioral of reaction_stats is

    component DoubleDabbler32Bit is
        Port (
            clk   : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            start : in  STD_LOGIC;
            BIN   : in  STD_LOGIC_VECTOR(31 downto 0);
            BCD   : out STD_LOGIC_VECTOR(31 downto 0);
            done  : out STD_LOGIC
        );
    end component;

    -- Three most recent reaction times (FIFO, newest = result_1)
    signal result_1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal result_2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal result_3 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal prev_counter_en : STD_LOGIC := '0';

    -- Combinational statistics result (binary)
    signal binary_result : STD_LOGIC_VECTOR(31 downto 0);

    -- BCD conversion handshake
    signal bcd_buffer : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal start_bcd  : STD_LOGIC := '0';
    signal done_bcd   : STD_LOGIC;
    signal bcd_output : STD_LOGIC_VECTOR(31 downto 0);
    signal converting : STD_LOGIC := '0';

begin

    -- -------------------------------------------------------------------------
    -- Combinational statistics selector
    -- -------------------------------------------------------------------------
    process(operation, result, result_1, result_2, result_3)
        variable r1, r2, r3 : unsigned(31 downto 0);
        variable sum2        : unsigned(32 downto 0);
        variable sum3        : unsigned(33 downto 0);
    begin
        r1 := unsigned(result_1);
        r2 := unsigned(result_2);
        r3 := unsigned(result_3);

        case operation is

            when "00" =>  -- Pass current timer count
                binary_result <= result;

            when "01" =>  -- Minimum
                if r2 = 0 and r3 = 0 then
                    binary_result <= result_1;
                elsif r3 = 0 then
                    if r1 <= r2 then
                        binary_result <= result_1;
                    else
                        binary_result <= result_2;
                    end if;
                else
                    if r1 <= r2 and r1 <= r3 then
                        binary_result <= result_1;
                    elsif r2 <= r1 and r2 <= r3 then
                        binary_result <= result_2;
                    else
                        binary_result <= result_3;
                    end if;
                end if;

            when "10" =>  -- Maximum
                if r1 >= r2 and r1 >= r3 then
                    binary_result <= result_1;
                elsif r2 >= r1 and r2 >= r3 then
                    binary_result <= result_2;
                else
                    binary_result <= result_3;
                end if;

            when others =>  -- "11": Average
                if r2 = 0 and r3 = 0 then
                    binary_result <= result_1;
                elsif r3 = 0 then
                    sum2 := ('0' & r1) + ('0' & r2);
                    binary_result <= std_logic_vector(sum2(32 downto 1));  -- exact /2
                else
                    sum3 := ("00" & r1) + ("00" & r2) + ("00" & r3);
                    binary_result <= std_logic_vector(resize(sum3 / 3, 32));
                end if;

        end case;
    end process;

    -- -------------------------------------------------------------------------
    -- BCD conversion controller
    -- Continuously re-triggers the Double Dabble converter so ALU_message
    -- tracks binary_result with a latency of ~32 clock cycles.
    -- -------------------------------------------------------------------------
    process(CLK)
    begin
        if rising_edge(CLK) then
            if converting = '0' then
                bcd_buffer <= binary_result;
                start_bcd  <= '1';
                converting <= '1';
            else
                start_bcd <= '0';
            end if;

            if done_bcd = '1' then
                ALU_message <= bcd_output;
                converting  <= '0';
            end if;
        end if;
    end process;

    -- -------------------------------------------------------------------------
    -- FIFO: capture new result on falling edge of counter_en
    -- -------------------------------------------------------------------------
    process(CLK)
    begin
        if rising_edge(CLK) then
            if storage_rst = '1' then
                result_1 <= (others => '0');
                result_2 <= (others => '0');
                result_3 <= (others => '0');
            elsif prev_counter_en = '1' and counter_en = '0' then
                result_3 <= result_2;
                result_2 <= result_1;
                result_1 <= result;
            end if;
            prev_counter_en <= counter_en;
        end if;
    end process;

    -- -------------------------------------------------------------------------
    -- Binary-to-BCD converter instance
    -- -------------------------------------------------------------------------
    BCD_CONV : DoubleDabbler32Bit
        port map (
            clk   => CLK,
            reset => '0',
            start => start_bcd,
            BIN   => bcd_buffer,
            BCD   => bcd_output,
            done  => done_bcd
        );

end Behavioral;
