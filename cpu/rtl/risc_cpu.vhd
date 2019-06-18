----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.05.2019 23:13:44
-- Design Name: 
-- Module Name: risc_cpu - Behavioral
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
use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity risc_cpu is
    Port ( IADDR : out STD_LOGIC_VECTOR (7 downto 0);      -- Instruction ROM address
           IDATA_IN : in STD_LOGIC_VECTOR (15 downto 0);   -- Instruction ROM data
           IVALID : in std_logic;                          -- Instruction ROM valid signal
           DADDR : out STD_LOGIC_VECTOR (7 downto 0);      -- Data RAM address
           DDATA_IN: in STD_LOGIC_VECTOR (7 downto 0);     -- Data RAM data in
           DDATA_OUT: out STD_LOGIC_VECTOR (7 downto 0);   -- Data RAM data out
           DVALID : in STD_LOGIC;                          -- Data RAM valid signal
           DWE : out STD_LOGIC;                            -- Data RAM write enable
           NRST : in STD_LOGIC;                            -- Reset signal
           CLK : in STD_LOGIC;                             -- Clock
           START : in STD_LOGIC;                           -- Start signal
           CPU_OUTPUT : out STD_LOGIC_VECTOR(7 downto 0)); -- CPU output port
end risc_cpu;

architecture Behavioral of risc_cpu is

component risc_alu is
Generic(bit_width : integer := 8);
Port ( input_a : in STD_LOGIC_VECTOR ((bit_width-1) downto 0);
       input_b : in STD_LOGIC_VECTOR ((bit_width-1) downto 0);
       output : out STD_LOGIC_VECTOR ((bit_width-1) downto 0);
       carry_in : in STD_LOGIC;
       status : out STD_LOGIC_VECTOR(4 downto 0);
       operation : in STD_LOGIC_VECTOR (3 downto 0));
end component risc_alu;

constant negative : integer := 4;
constant zero     : integer := 3;
constant carry    : integer := 2;
constant sign     : integer := 1;
constant overflow : integer := 0;
constant data_bit_width : integer := 8;

subtype opcode     is std_logic_vector(15 downto 0);
subtype alu_opcode is std_logic_vector(3 downto 0);
subtype cpu_data   is std_logic_vector((data_bit_width-1) downto 0);
type gp_registers  is array (0 to 15) of cpu_data;


signal registers : gp_registers;               -- Register file
signal ir : std_logic_vector(15 downto 0);     -- Instruction register
signal pc : std_logic_vector(7 downto 0);      -- Program counter
signal status : std_logic_vector(4 downto 0);  -- S Z C N V
signal cpu_out : std_logic_vector(7 downto 0); -- CPU output

-- Immediate ALU opcodes:
-- 1aaa rrrr iiii iiii
-- a - ALU opcode
-- r - register
-- i - immediate value
constant c_IMMEDIATE_ARITHMETIC : opcode := "1---------------"; -- Immediate arithmetic operations
--constant a_OR  : alu_opcode := "0000";
--constant a_AND : alu_opcode := "0001";
--constant a_XOR : alu_opcode := "0010"; 
--constant a_ADD : alu_opcode := "0011";
--constant a_ADC : alu_opcode := "0100";
--constant a_SUB : alu_opcode := "0101";
--constant a_SUBC: alu_opcode := "0110";
--constant a_CMP : alu_opcode := "0111";

-- Direct ALU opcodes
-- 0001 aaaa rrrr dddd
-- a - ALU opcode
-- r - first operand and destination register
-- d - second operand
constant c_DIRECT_ARITHMETIC : opcode := "0001------------"; -- Direct arithmetic operations
--constant a_OR  : alu_opcode := "0000";
--constant a_AND : alu_opcode := "0001";
--constant a_XOR : alu_opcode := "0010"; 
--constant a_ADD : alu_opcode := "0011";
--constant a_ADC : alu_opcode := "0100";
--constant a_SUB : alu_opcode := "0101";
--constant a_SUBC: alu_opcode := "0110";
--constant a_CMP : alu_opcode := "0111";
--constant a_LSL : alu_opcode := "1000";
--constant a_LSR : alu_opcode := "1001";
--constant a_ASR : alu_opcode := "1010";
--constant a_ROL : alu_opcode := "1011";
--constant a_ROR : alu_opcode := "1100";
--constant a_INV : alu_opcode := "1101";
--constant a_NEG : alu_opcode := "1110";

-- Load/store opcodes
-- 0010 rrrr iiii iiii
-- r - Destination/source register
-- i - immediate address
constant c_LDS : opcode := "0100------------";
constant c_STS : opcode := "0101------------";
-- Load immediate value
constant c_LDI : opcode := "0010------------";

-- Branching instructions
-- 0111 0bbb iiii iiii
-- b - branch instruction
-- i - jump address
constant c_BR_I : opcode := "01110-----------";
--constant BR   : opcode := "01110000--------";
--constant BREQ : opcode := "01110001--------";
--constant BRNE : opcode := "01110010--------";
--constant BRL  : opcode := "01110011--------";
--constant BRG  : opcode := "01110100--------";
--constant BRLE : opcode := "01110101--------";
--constant BRGE : opcode := "01110110--------";
--constant BRZ  : opcode := "01110111--------";
constant c_BR   : std_logic_vector(2 downto 0) := "000";
constant c_BREQ : std_logic_vector(2 downto 0) := "001";
constant c_BRNE : std_logic_vector(2 downto 0) := "010";
constant c_BRL  : std_logic_vector(2 downto 0) := "011";
constant c_BRG  : std_logic_vector(2 downto 0) := "100";
constant c_BRLE : std_logic_vector(2 downto 0) := "101";
constant c_BRGE : std_logic_vector(2 downto 0) := "110";

constant c_MOV : opcode := "01111000--------";
constant c_OUT : opcode := "01111001--------";

constant c_NOP : opcode := "0000000000000000";

type state is ( HALT,     -- This is the initial/idle state.
                FETCH,    -- Read data from instruction ROM
                DECODE,   -- Decode the instruction
                EXECUTE,  -- Execute the instruction
                EXECUTE_2,-- Additional execute stage
                FAULT);   -- Fault state

signal cpu_state        : state;
signal data_address     : cpu_data;

signal alu_in_a         : cpu_data;
signal alu_in_b         : cpu_data;
signal alu_out          : cpu_data;
signal alu_status       : std_logic_vector(4 downto 0);
signal alu_operation    : alu_opcode;

signal cpu_ready : std_logic;

begin

alu : risc_alu
generic map(bit_width => data_bit_width)
port map(input_a => alu_in_a,
         input_b => alu_in_b,
         output => alu_out,
         carry_in => status(carry),
         status => alu_status,
         operation => alu_operation);


IADDR <= pc;
DADDR <= data_address;
CPU_OUTPUT <= cpu_out;

CPU_PROC : process(CLK)
begin
    if (rising_edge(CLK)) then
        if (NRST = '0') then
            DWE <= '0';
            cpu_state <= HALT;
            data_address <= x"00";
			cpu_out <= x"00";
			pc <= x"00";
            
        else
            if cpu_state = HALT then
                if START = '1' then
                    cpu_state <= FETCH;
                else
                    cpu_state <= HALT;
                end if;
            elsif cpu_state = FAULT then
                cpu_state <= FAULT;
            elsif cpu_state = FETCH then
                if IVALID = '1' then
                    ir <= IDATA_IN;
                    pc <= pc + 1;
                    cpu_state <= DECODE;
                else
                    cpu_state <= FETCH;
                end if;
            else
                if std_match(c_NOP, ir) then
                    cpu_state <= FETCH;
                    
                -- Immediate arithmetic handling
                elsif std_match(c_IMMEDIATE_ARITHMETIC, ir) then
                    case cpu_state is
                        when DECODE =>
                            alu_operation <= '0' & ir(14 downto 12);
                            alu_in_a <= registers(to_integer(unsigned(ir(11 downto 8))));
                            alu_in_b <= ir(7 downto 0);
                            cpu_state <= EXECUTE;
                            
                        when EXECUTE =>
                            registers(to_integer(unsigned(ir(10 downto 8)))) <= alu_out;
                            status <= alu_status;
                            cpu_state <= FETCH;
                            
                        when others =>
                            cpu_state <= FAULT;
                    end case;
                    
                -- Register-register arithmetic handling
                elsif std_match(c_DIRECT_ARITHMETIC, ir) then
                    case cpu_state is
                        when DECODE =>
                            alu_operation <= ir(11 downto 8);
                            alu_in_a <= registers(to_integer(unsigned(ir(7 downto 4))));
                            alu_in_b <= registers(to_integer(unsigned(ir(3 downto 0))));
                            cpu_state <= EXECUTE;
                            
                        when EXECUTE =>
                            registers(to_integer(unsigned(ir(7 downto 4)))) <= alu_out;
                            status <= alu_status;
                            cpu_state <= FETCH;
                            
                        when others =>
                            cpu_state <= FAULT;
                    end case;
                    
                -- Branch opcode handling
                elsif std_match(c_BR_I, ir) then
                    if ir(10 downto 8) = c_BR then
                        pc <= ir(7 downto 0);
                    elsif ir(10 downto 8) = c_BREQ then
                        if status(zero) = '1' then
                            pc <= ir(7 downto 0);
                        end if;
                    elsif ir(10 downto 8) = c_BRNE then
                        if status(zero) = '0' then
                            pc <= ir(7 downto 0);
                        end if;
                    elsif ir(10 downto 8) = c_BRL then
                        if status(carry) = '1' then
                            pc <= ir(7 downto 0);
                        end if;
                    elsif ir(10 downto 8) = c_BRLE then
                        if status(carry) = '1' or status(zero) = '1' then
                            pc <= ir(7 downto 0);
                        end if;
                    elsif ir(10 downto 8) = c_BRG then
                        if status(carry) = '0' and status(zero) = '0' then
                            pc <= ir(7 downto 0);
                        end if;
                    elsif ir(10 downto 8) = c_BRGE then
                        if status(carry) = '0' then
                            pc <= ir(7 downto 0);
                        end if;
                    end if;
                    if cpu_state = DECODE then
                        cpu_state <= EXECUTE;
                    elsif cpu_state <= EXECUTE then
                        cpu_state <= FETCH;
                    end if;
                    
                -- Miscelleanous opcode handling
                elsif std_match(c_OUT, ir) then
                    cpu_out <= registers(to_integer(unsigned(ir(3 downto 0))));
                    cpu_state <= FETCH;
                elsif std_match(c_MOV, ir) then
                    registers(to_integer(unsigned(ir(7 downto 4)))) <= registers(to_integer(unsigned(ir(3 downto 0))));
                    cpu_state <= FETCH;
                    
                -- Load/store opcode handling
                elsif std_match(c_LDI, ir) then
                    registers(to_integer(unsigned(ir(11 downto 8)))) <= ir(7 downto 0);
                    cpu_state <= FETCH;
                elsif std_match(c_LDS, ir) then
                    if cpu_state = DECODE then
                        data_address <= ir(7 downto 0);
                        cpu_state <= EXECUTE;
                        
                    elsif cpu_state = EXECUTE then
                        cpu_state <= EXECUTE_2; -- Additional clock cycle to allow the memory to return the correct data.
                        
                    elsif cpu_state = EXECUTE_2 then
                        if DVALID = '1' then
                            registers(to_integer(unsigned(ir(11 downto 8)))) <= DDATA_IN;
                            cpu_state <= FETCH;
                        end if;
                    end if;
                elsif std_match(c_STS, ir) then
                    if cpu_state = DECODE then
                        data_address <= ir(7 downto 0);
                        DWE <= '1';
                        DDATA_OUT <= registers(to_integer(unsigned(ir(11 downto 8))));
                        cpu_state <= EXECUTE;
                        
                    elsif cpu_state = EXECUTE then
                        DWE <= '0';
                        cpu_state <= FETCH;
                    end if;
                end if;
            end if;
        end if;
    end if;
end process;

end Behavioral;
