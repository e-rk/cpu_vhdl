----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.05.2019 23:34:08
-- Design Name: 
-- Module Name: risc_alu - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity risc_alu is
    Generic(bit_width : integer := 8);
    Port ( input_a : in STD_LOGIC_VECTOR ((bit_width-1) downto 0);
           input_b : in STD_LOGIC_VECTOR ((bit_width-1) downto 0);
           output : out STD_LOGIC_VECTOR ((bit_width-1) downto 0);
           carry_in : in STD_LOGIC;
           status : out STD_LOGIC_VECTOR(4 downto 0);
           operation : in STD_LOGIC_VECTOR (3 downto 0));
end risc_alu;

architecture Behavioral of risc_alu is

subtype alu_opcode is std_logic_vector(3 downto 0);

constant a_OR  : alu_opcode := "0000";
constant a_AND : alu_opcode := "0001";
constant a_XOR : alu_opcode := "0010"; 
constant a_ADD : alu_opcode := "0011";
constant a_ADC : alu_opcode := "0100";
constant a_SUB : alu_opcode := "0101";
constant a_SUBC: alu_opcode := "0110";
constant a_CMP : alu_opcode := "0111";

constant a_LSL : alu_opcode := "1000";
constant a_LSR : alu_opcode := "1001";
constant a_ASR : alu_opcode := "1010";
constant a_ROL : alu_opcode := "1011";
constant a_ROR : alu_opcode := "1100";
constant a_INV : alu_opcode := "1101";
constant a_NEG : alu_opcode := "1110";

constant negative : integer := 4;
constant zero     : integer := 3;
constant carry    : integer := 2;
constant sign     : integer := 1;
constant overflow : integer := 0;

signal result : std_logic_vector(bit_width downto 0);
signal a : std_logic_vector(bit_width downto 0);
signal b : std_logic_vector(bit_width downto 0);

signal status_s : std_logic_vector(4 downto 0);

function nor_reduct(vector : in std_logic_vector) return std_logic is
  variable result : std_logic := '0';
begin
  for i in vector'range loop
    result := result or vector(i);
  end loop;
  return not result;
end function;

function and_reduct(vector : in std_logic_vector) return std_logic is
  variable result : std_logic := '1';
begin
  for i in vector'range loop
    result := result and vector(i);
  end loop;
  return result;
end function;

begin

a <= '0' & input_a;
b <= '0' & input_b;
status <= status_s;

status_s(zero)     <= nor_reduct(result);
status_s(carry)    <= result(bit_width);
status_s(sign)     <= status_s(negative) xor status_s(overflow);
status_s(negative) <= result(bit_width - 1);

with operation select status_s(overflow) <=
    (a(bit_width-1) and b(bit_width-1) and (not result(bit_width-1))) or ((not a(bit_width-1)) and (not b(bit_width-1)) and result(bit_width-1)) when a_ADD,
    (a(bit_width-1) and b(bit_width-1) and (not result(bit_width-1))) or ((not a(bit_width-1)) and (not b(bit_width-1)) and result(bit_width-1)) when a_ADC,
    (a(bit_width-1) and (not b(bit_width-1)) and (not result(bit_width-1))) or ((not a(bit_width-1)) and b(bit_width-1) and result(bit_width-1)) when a_SUB,
    (a(bit_width-1) and (not b(bit_width-1)) and (not result(bit_width-1))) or ((not a(bit_width-1)) and b(bit_width-1) and result(bit_width-1)) when a_SUBC,
    (a(bit_width-1) and (not b(bit_width-1)) and (not result(bit_width-1))) or ((not a(bit_width-1)) and b(bit_width-1) and result(bit_width-1)) when a_CMP,
    and_reduct(result(bit_width-1) & (not result(bit_width-2 downto 0)))                                                                         when a_NEG,
    status_s(carry) xor status_s(negative)                                                                                                       when a_LSL,
    status_s(carry) xor status_s(negative)                                                                                                       when a_LSR,
    status_s(carry) xor status_s(negative)                                                                                                       when a_ROR,
    status_s(carry) xor status_s(negative)                                                                                                       when a_ROL,
    status_s(carry) xor status_s(negative)                                                                                                       when a_ASR,
    '0'                                                                                                                                          when others;

with operation select output <=
    input_a                         when a_CMP,
    result((bit_width-1) downto 0)  when others;

with operation select result <=
    a or b                                              when a_OR,
    a and b                                             when a_AND,
    a xor b                                             when a_XOR,
    a((bit_width-1) downto 0) & '0'                     when a_LSL,
    a(0) & '0' & a((bit_width-1) downto 1)              when a_LSR,
    a(0) & a(bit_width-1) & a((bit_width-1) downto 1)   when a_ASR,
    a((bit_width-1) downto 0) & carry_in                when a_ROL,
    a(0) & carry_in & a((bit_width-1) downto 1)         when a_ROR,
    a + b                                               when a_ADD,
    a + b + carry_in                                    when a_ADC,
    a - b                                               when a_SUB,
    a - b - carry_in                                    when a_SUBC,
    not(a)                                              when a_INV,
    not(a) + 1                                          when a_NEG,
    a - b                                               when a_CMP,
    a                                                   when others;

end Behavioral;
