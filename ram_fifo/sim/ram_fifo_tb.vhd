----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.05.2019 22:10:23
-- Design Name: 
-- Module Name: ram_fifo_tb - Behavioral
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

entity ram_fifo_tb is
--  Port ( );
end ram_fifo_tb;

architecture Behavioral of ram_fifo_tb is

component ram_fifo_v1_0 is
generic (
C_RAM_DATA_WIDTH              : integer   := 2;
C_RAM_ADDRESS_WIDTH               : integer   := 8;
C_S00_AXIS_TDATA_WIDTH    : integer    := 32
);
port (
R_RAM_WRITE : in std_logic;
R_RAM_DATA_IN : in std_logic_vector(15 downto 0);
R_RAM_DATA_OUT : out std_logic_vector(15 downto 0);
R_RAM_ADDRESS : in std_logic_vector(7 downto 0);
R_RAM_VALID : out std_logic;
s00_axis_aclk    : in std_logic;
s00_axis_aresetn    : in std_logic;
S00_AXIS_TREADY    : out std_logic;
S00_AXIS_TDATA    : in std_logic_vector(31 downto 0);
S00_AXIS_TSTRB    : in std_logic_vector((32/8)-1 downto 0);
S00_AXIS_TLAST    : in std_logic;
S00_AXIS_TVALID    : in std_logic
);
end component ram_fifo_v1_0;

signal    R_RAM_WRITE : std_logic;
signal    R_RAM_DATA_IN : std_logic_vector(15 downto 0);
signal    R_RAM_DATA_OUT : std_logic_vector(15 downto 0);
signal    R_RAM_ADDRESS : std_logic_vector(7 downto 0);
signal    R_RAM_VALID : std_logic;
signal    R_RAM_WRITE_DONE : std_logic;

signal    S_AXIS_ACLK    :  std_logic;
signal    S_AXIS_ARESETN :  std_logic;
signal    S_AXIS_TREADY  :  std_logic;
signal    S_AXIS_TDATA   :  std_logic_vector(31 downto 0);
signal    S_AXIS_TSTRB   :  std_logic_vector((32/8)-1 downto 0);
signal    S_AXIS_TLAST   :  std_logic;
signal    S_AXIS_TVALID  :  std_logic;

constant clk_period : time := 1us;

begin

fifo_ram_v1_0_S00_AXIS_inst : ram_fifo_v1_0
generic map (
    C_RAM_DATA_WIDTH          => 2,
    C_RAM_ADDRESS_WIDTH       => 8,
    C_S00_AXIS_TDATA_WIDTH    => 32
    )
port map (
    R_RAM_WRITE => R_RAM_WRITE,
    R_RAM_DATA_IN => R_RAM_DATA_IN,
    R_RAM_DATA_OUT => R_RAM_DATA_OUT,
    R_RAM_ADDRESS => R_RAM_ADDRESS,
    R_RAM_VALID => R_RAM_VALID,
    s00_axis_aclk    => S_AXIS_ACLK,
    s00_axis_aresetn    => S_AXIS_ARESETN,
    S00_AXIS_TREADY    => S_AXIS_TREADY,
    S00_AXIS_TDATA    => S_AXIS_TDATA,
    S00_AXIS_TSTRB    => S_AXIS_TSTRB,
    S00_AXIS_TLAST    => S_AXIS_TLAST,
    S00_AXIS_TVALID    => S_AXIS_TVALID
);

AXI_PROC : process

begin

S_AXIS_ARESETN <= '0';
S_AXIS_TDATA <= x"00000000";
S_AXIS_TVALID <= '0';
S_AXIS_TLAST <= '0';
R_RAM_WRITE <= '0';
R_RAM_ADDRESS <= x"00";
R_RAM_DATA_IN <= x"0000";
wait for clk_period;

S_AXIS_ARESETN <= '1';

wait for clk_period;

S_AXIS_TDATA <= x"00010002";
S_AXIS_TVALID <= '1';
wait for 2*clk_period;

S_AXIS_TDATA <= x"00030004";
wait for clk_period;

S_AXIS_TDATA <= x"00050006";
wait for clk_period;

S_AXIS_TDATA <= x"00070008";
S_AXIS_TLAST <= '1';
wait for clk_period;

S_AXIS_TDATA <= x"0009000a";
S_AXIS_TLAST <= '0';
wait for 2*clk_period;

S_AXIS_TDATA <= x"000b000c";
S_AXIS_TLAST <= '1';
wait for clk_period;

S_AXIS_TVALID <= '0';

wait for clk_period;

R_RAM_ADDRESS <= x"00";
wait for 2*clk_period;

R_RAM_ADDRESS <= x"01";
wait for clk_period;

R_RAM_ADDRESS <= x"02";
wait for clk_period;

R_RAM_ADDRESS <= x"03";
wait for clk_period;

R_RAM_ADDRESS <= x"04";
wait for clk_period;

R_RAM_ADDRESS <= x"05";
wait for clk_period;

R_RAM_ADDRESS <= x"06";
wait for clk_period;

R_RAM_ADDRESS <= x"07";
wait for clk_period;

R_RAM_ADDRESS <= x"08";
wait for clk_period;

R_RAM_ADDRESS <= x"09";
wait for clk_period;

R_RAM_ADDRESS <= x"0a";
wait for clk_period;

R_RAM_ADDRESS <= x"0b";
wait for clk_period;

R_RAM_ADDRESS <= x"0c";
wait for clk_period;

R_RAM_ADDRESS <= x"0d";
wait for clk_period;

R_RAM_ADDRESS <= x"0e";
wait for clk_period;

R_RAM_DATA_IN <= x"1010";
R_RAM_WRITE <= '1';

wait for 2*clk_period;

R_RAM_WRITE <= '0';

wait for clk_period;

wait for 4*clk_period;

end process;

CLK_PROC : process
begin
S_AXIS_ACLK <= '0';
wait for clk_period/2;
S_AXIS_ACLK <= '1';
wait for clk_period/2;
end process;


end Behavioral;
