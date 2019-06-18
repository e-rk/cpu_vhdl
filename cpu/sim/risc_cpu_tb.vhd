----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.05.2019 23:29:56
-- Design Name: 
-- Module Name: risc_cpu_tb - Behavioral
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

entity risc_cpu_tb is
--  Port ( );
end risc_cpu_tb;

architecture Behavioral of risc_cpu_tb is

component ram_fifo_v1_0 is
	generic (
    -- Users to add parameters here
    C_RAM_DATA_WIDTH    : integer := 1;
    C_RAM_ADDRESS_WIDTH : integer := 8;
    -- User parameters ends
    -- Do not modify the parameters beyond this line


    -- Parameters of Axi Slave Bus Interface S00_AXIS
    C_S00_AXIS_TDATA_WIDTH    : integer    := 32
);
port (
    -- Users to add ports here
    R_RAM_WRITE : in std_logic;
    R_RAM_DATA_IN : in std_logic_vector(8*C_RAM_DATA_WIDTH-1 downto 0);
    R_RAM_DATA_OUT : OUT std_logic_vector(8*C_RAM_DATA_WIDTH-1 downto 0);
    R_RAM_ADDRESS : in std_logic_vector(C_RAM_ADDRESS_WIDTH-1 downto 0);
    R_RAM_VALID : out std_logic;
    -- User ports ends
    -- Do not modify the ports beyond this line


    -- Ports of Axi Slave Bus Interface S00_AXIS
    s00_axis_aclk    : in std_logic;
    s00_axis_aresetn    : in std_logic;
    s00_axis_tready    : out std_logic;
    s00_axis_tdata    : in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
    s00_axis_tstrb    : in std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0);
    s00_axis_tlast    : in std_logic;
    s00_axis_tvalid    : in std_logic
);
end component ram_fifo_v1_0;

component risc_cpu is
    Port ( IADDR : out STD_LOGIC_VECTOR (7 downto 0);  -- Instruction ROM address
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
end component risc_cpu;

signal    R_RAM_WRITE : std_logic;
signal    R_RAM_DATA_IN : std_logic_vector(15 downto 0);

signal    S_AXIS_ACLK    :  std_logic;
signal    S_AXIS_ARESETN :  std_logic;
signal    S_AXIS_TREADY  :  std_logic;
signal    S_AXIS_TDATA   :  std_logic_vector(31 downto 0);
signal    S_AXIS_TSTRB   :  std_logic_vector((32/8)-1 downto 0);
signal    S_AXIS_TLAST   :  std_logic;
signal    S_AXIS_TVALID  :  std_logic;

signal    DS_AXIS_TREADY  :  std_logic;
signal    DS_AXIS_TSTRB   :  std_logic_vector((32/8)-1 downto 0);



signal IADDR : STD_LOGIC_VECTOR (7 downto 0);
signal IDATA_IN : STD_LOGIC_VECTOR (15 downto 0);
signal IVALID : STD_LOGIC;
signal DADDR : STD_LOGIC_VECTOR (7 downto 0);
signal DDATA_IN: STD_LOGIC_VECTOR (7 downto 0);
signal DDATA_OUT: STD_LOGIC_VECTOR (7 downto 0);
signal DVALID : STD_LOGIC;
signal DWE : STD_LOGIC;
signal NRST : STD_LOGIC;
signal CLK : STD_LOGIC;
signal START : STD_LOGIC;
signal OUTPUT : STD_LOGIC_VECTOR(7 downto 0);

constant clk_period : time := 1us;

begin

instruction_rom : ram_fifo_v1_0
generic map (
    C_RAM_DATA_WIDTH          => 2,
    C_RAM_ADDRESS_WIDTH       => 8,
    C_S00_AXIS_TDATA_WIDTH    => 32
    )
port map (
    R_RAM_DATA_OUT => IDATA_IN,
    R_RAM_WRITE => '0',
    R_RAM_DATA_IN => x"0000",
    R_RAM_ADDRESS => IADDR,
    R_RAM_VALID => IVALID,
    s00_axis_aclk    => S_AXIS_ACLK,
    s00_axis_aresetn    => S_AXIS_ARESETN,
    s00_axis_tready    => S_AXIS_TREADY,
    s00_axis_tdata    => S_AXIS_TDATA,
    s00_axis_tstrb    => S_AXIS_TSTRB,
    s00_axis_tlast    => S_AXIS_TLAST,
    s00_axis_tvalid    => S_AXIS_TVALID
);

data_ram : ram_fifo_v1_0
generic map (
    C_RAM_DATA_WIDTH          => 1,
    C_RAM_ADDRESS_WIDTH       => 8,
    C_S00_AXIS_TDATA_WIDTH    => 32
    )
port map (
    R_RAM_DATA_OUT => DDATA_IN,
    R_RAM_WRITE => DWE,
    R_RAM_DATA_IN => DDATA_OUT,
    R_RAM_ADDRESS => DADDR,
    R_RAM_VALID => DVALID,
    s00_axis_aclk    => S_AXIS_ACLK,
    s00_axis_aresetn    => S_AXIS_ARESETN,
    s00_axis_tready    => DS_AXIS_TREADY,
    s00_axis_tdata    => x"00000000",
    s00_axis_tstrb    => DS_AXIS_TSTRB,
    s00_axis_tlast    => '0',
    s00_axis_tvalid    => '0'
);

rist_cpu_1 : risc_cpu
port map (
    IADDR => IADDR,
    IDATA_IN => IDATA_IN,
    IVALID => IVALID,
    DADDR => DADDR,
    DDATA_IN => DDATA_IN,
    DDATA_OUT => DDATA_OUT,
    DVALID => DVALID,
    DWE => DWE,
    NRST => NRST,
    CLK => S_AXIS_ACLK,
    START => START,
    CPU_OUTPUT => OUTPUT
    );

AXI_PROC : process

subtype opcode is std_logic_vector(15 downto 0);

constant LDI_R1 : opcode := "0010000101110110";
constant LDI_R5 : opcode := "0010010110000101";
constant LDI_R6 : opcode := "0010011011000000";

constant ADD_R1R5 : opcode := "0001001100010101";
constant ADD_R5R6 : opcode := "0001001101010110";

constant OUT_R1 : opcode := "0111100100000001";
constant OUT_R5 : opcode := "0111100100000101";
constant OUT_R6 : opcode := "0111100100000110";
constant BR_EQ  : opcode := "0111000100110000";

constant CMP_R1R5 : opcode := "0001011100010101";
constant CMP_R1R1 : opcode := "0001011100010001";

constant STS_R1 : opcode := "0101000100000011";
constant STS_R5 : opcode := "0101010100000100";
constant STS_R6 : opcode := "0101011000001000";
constant LDS_R5 : opcode := "0100010100000011";
constant LDS_R6 : opcode := "0100011000000100";

constant NOP : opcode := "0000000000000000";

begin

    S_AXIS_ARESETN <= '0';
    S_AXIS_TDATA <= x"00000000";
    S_AXIS_TVALID <= '0';
    S_AXIS_TLAST <= '0';
    R_RAM_WRITE <= '0';
    R_RAM_DATA_IN <= x"0000";
    NRST <= '0';
    START <= '0';
    wait for clk_period;
    
    S_AXIS_ARESETN <= '1';
    NRST <= '1';
    
    wait for clk_period;
    
    S_AXIS_TDATA <= LDI_R1 & OUT_R1;
    S_AXIS_TVALID <= '1';
    wait for 2*clk_period;
    
    S_AXIS_TDATA <= LDI_R5 & LDI_R6;
    wait for clk_period;
    
    S_AXIS_TDATA <= OUT_R5 & OUT_R6;
    wait for clk_period;
    
    S_AXIS_TDATA <= CMP_R1R1 & BR_EQ;
    wait for clk_period;
    
    S_AXIS_TDATA <= OUT_R5 & OUT_R5;
    wait for 20*clk_period;
    
    S_AXIS_TDATA <= OUT_R1 & ADD_R5R6;
    wait for clk_period;
    
    S_AXIS_TDATA <= ADD_R1R5 & OUT_R1;
    wait for clk_period;
    
    S_AXIS_TDATA <= OUT_R6 & OUT_R5;
    wait for clk_period;
    
    S_AXIS_TDATA <= STS_R1 & STS_R5;
    wait for clk_period;
    
    S_AXIS_TDATA <= STS_R6 & LDS_R6;
    wait for clk_period;
    
    S_AXIS_TDATA <= NOP & NOP;
    wait for clk_period;
    
    S_AXIS_TDATA <= LDS_R5 & ADD_R1R5;
    wait for clk_period;
    
    S_AXIS_TDATA <= OUT_R5 & OUT_R1;
    wait for clk_period;
    
    S_AXIS_TLAST <= '1';
    S_AXIS_TDATA <= NOP & NOP;
    wait for clk_period;
    
    S_AXIS_TVALID <= '0';
    S_AXIS_TLAST <= '0';
    
    wait for clk_period;
    
    START <= '1';
    
    wait for clk_period;
    
    START <= '0';
    
    wait for 5*256*clk_period;

end process;

CLK_PROC : process
begin
    S_AXIS_ACLK <= '0';
    wait for clk_period/2;
    S_AXIS_ACLK <= '1';
    wait for clk_period/2;
end process;

end Behavioral;
