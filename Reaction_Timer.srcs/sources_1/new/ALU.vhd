----------------------------------------------------------------------------------
-- Company: University of Canterbury, Department of Electrical and Computer Engineering
-- Engineer: Monday Group 8
--           - Matthew Claridge
--           - Joel Dunwoodie
--           - George Johnson
--
-- Design Name: Arithmetic Logic Unit (ALU)
-- Module Name: ALU - Behavioral Architecture
-- Project Name: ENEL373 Reaction Timer Project
-- Target Devices: Digilent Nexys-4 DDR FPGA Board (Artix-7 XC7A100T-1CSG324C)
-- Tool Versions: AMD Vivado 2022.2
--
-- Description:
-- Purely combinational 32-bit ALU. Selects an arithmetic or logic operation on
-- two generic operands A and B based on a 3-bit opcode. Produces a 32-bit result
-- and four status flags: Zero, Carry, Overflow, Negative.
--
-- Opcode table:
--   000  ADD  : result = A + B
--   001  SUB  : result = A - B
--   010  AND  : result = A AND B
--   011  OR   : result = A OR B
--   100  XOR  : result = A XOR B
--   101  NOT  : result = NOT A
--   110  SLT  : result = 1 if A < B (signed), else 0
--   111  PASS : result = A
--
-- Flags:
--   zero     : high when result = 0
--   carry    : unsigned carry-out (ADD) or borrow (SUB, high when A < B unsigned)
--   overflow : signed two's-complement overflow (ADD and SUB only)
--   negative : MSB of result (sign bit)
--
-- Dependencies: None.
--
-- Revision History:
--  - Revision 0.01: Initial version -- proper ALU replacing prior stats-calculator stub.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port (
        A        : in  STD_LOGIC_VECTOR(31 downto 0);
        B        : in  STD_LOGIC_VECTOR(31 downto 0);
        opcode   : in  STD_LOGIC_VECTOR(2 downto 0);
        result   : out STD_LOGIC_VECTOR(31 downto 0);
        zero     : out STD_LOGIC;
        carry    : out STD_LOGIC;
        overflow : out STD_LOGIC;
        negative : out STD_LOGIC
    );
end ALU;

architecture Behavioral of ALU is

    signal result_sig : STD_LOGIC_VECTOR(31 downto 0);
    signal carry_sig  : STD_LOGIC;
    signal ovflow_sig : STD_LOGIC;

begin

    process(A, B, opcode)
        variable add_r : unsigned(32 downto 0);
        variable sub_r : unsigned(32 downto 0);
        variable res   : STD_LOGIC_VECTOR(31 downto 0);
        variable c     : STD_LOGIC;
        variable ov    : STD_LOGIC;
    begin
        add_r := ('0' & unsigned(A)) + ('0' & unsigned(B));
        sub_r := ('0' & unsigned(A)) - ('0' & unsigned(B));
        res   := (others => '0');
        c     := '0';
        ov    := '0';

        case opcode is
            when "000" =>  -- ADD
                res := std_logic_vector(add_r(31 downto 0));
                c   := add_r(32);
                ov  := ((not A(31)) and (not B(31)) and add_r(31)) or
                        (A(31) and B(31) and (not add_r(31)));

            when "001" =>  -- SUB (A - B)
                res := std_logic_vector(sub_r(31 downto 0));
                c   := sub_r(32);  -- borrow: '1' when A < B (unsigned)
                ov  := ((not A(31)) and B(31) and sub_r(31)) or
                        (A(31) and (not B(31)) and (not sub_r(31)));

            when "010" =>  -- AND
                res := A and B;

            when "011" =>  -- OR
                res := A or B;

            when "100" =>  -- XOR
                res := A xor B;

            when "101" =>  -- NOT A
                res := not A;

            when "110" =>  -- SLT: result = 1 if A < B (signed comparison)
                if signed(A) < signed(B) then
                    res := (0 => '1', others => '0');
                else
                    res := (others => '0');
                end if;

            when others =>  -- PASS: result = A
                res := A;
        end case;

        result_sig <= res;
        carry_sig  <= c;
        ovflow_sig <= ov;
    end process;

    result   <= result_sig;
    zero     <= '1' when result_sig = X"00000000" else '0';
    carry    <= carry_sig;
    overflow <= ovflow_sig;
    negative <= result_sig(31);

end Behavioral;
