----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.05.2019 23:31:04
-- Design Name: 
-- Module Name: risc_alu_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity risc_alu_tb is
--  Port ( );
end risc_alu_tb;

architecture Behavioral of risc_alu_tb is

component risc_alu is
Generic(bit_width : integer := 8);
Port ( input_a : in STD_LOGIC_VECTOR ((bit_width-1) downto 0);
       input_b : in STD_LOGIC_VECTOR ((bit_width-1) downto 0);
       output : out STD_LOGIC_VECTOR ((bit_width-1) downto 0);
       carry_in : in STD_LOGIC;
       status : out STD_LOGIC_VECTOR(4 downto 0);
       operation : in STD_LOGIC_VECTOR (3 downto 0));
end component risc_alu;

constant bit_width : integer := 4;

subtype value is std_logic_vector((bit_width-1) downto 0);
subtype alu_opcode is std_logic_vector(3 downto 0);

signal a : value;
signal b : value;
signal output : value;

signal carry_register : std_logic;
signal status : STD_LOGIC_VECTOR(4 downto 0);
signal operation : alu_opcode;

constant clk_period : time := 1us;
signal CLK : std_logic;

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

begin

alu : risc_alu
generic map(bit_width => bit_width)
port map(input_a => a,
         input_b => b,
         output => output,
         carry_in => carry_register,
         status => status,
         operation => operation);

process
begin
    a <= x"0";
    b <= x"0";
    operation <= x"0";
    
    wait for clk_period;
    
    a <= "1000";
    b <= "0001";
    operation <= a_OR;
    
    wait for clk_period;
    
    operation <= a_AND;
    
    wait for clk_period;
    
    operation <= a_XOR;
    
    wait for clk_period;
    
    operation <= a_ADD;
    
    wait for clk_period;
    
    operation <= a_ADC;
    
    wait for clk_period;
    
    operation <= a_SUB;
    
    wait for clk_period;
    
    operation <= a_SUBC;
    
    wait for clk_period;
    
    operation <= a_INV;
    
    wait for clk_period;
    
    operation <= a_NEG;
    
    wait for clk_period;
    
    operation <= a_LSL;
    
    wait for clk_period;
    
    operation <= a_LSR;
    
    wait for clk_period;
    
    operation <= a_ASR;
    
    wait for clk_period;
    
    operation <= a_ROL;
    
    wait for clk_period;
    
    operation <= a_ROR;
    
    wait for clk_period;
    
    a <= "0110";
    b <= "0100";
    
    operation <= a_ADD;
    
    wait for clk_period;
    
    operation <= a_ADC;
    
    wait for clk_period;
    
    operation <= a_SUB;
    
    wait for clk_period;
    
    operation <= a_SUBC;
    
    wait for clk_period;
    
    operation <= a_CMP;
    a <= "0110";
    b <= "0110";
    
    wait for clk_period;
    
end process;

process(CLK)
begin
    carry_register <= status(carry);
end process;

CLK_PROC : process
begin
    CLK <= '0';
    wait for clk_period/2;
    CLK <= '1';
    wait for clk_period/2;
end process;

end Behavioral;
