library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ram_fifo_v1_0_S00_AXIS is
	generic (
		-- Users to add parameters here
        C_RAM_DATA_WIDTH    : integer := 1;
        C_RAM_ADDRESS_WIDTH : integer := 8;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
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

		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end ram_fifo_v1_0_S00_AXIS;

architecture arch_imp of ram_fifo_v1_0_S00_AXIS is
	-- function called clogb2 that returns an integer which has the 
	-- value of the ceiling of the log base 2.
	function clogb2 (bit_depth : integer) return integer is 
	variable depth  : integer := bit_depth;
	  begin
	    if (depth = 0) then
	      return(0);
	    else
	      for clogb2 in 1 to bit_depth loop  -- Works for up to 32 bit integers
	        if(depth <= 1) then 
	          return(clogb2);      
	        else
	          depth := depth / 2;
	        end if;
	      end loop;
	    end if;
	end;    

	-- Total number of input data.
	constant NUMBER_OF_INPUT_WORDS  : integer := 2**C_RAM_ADDRESS_WIDTH;
	-- bit_num gives the minimum number of bits needed to address 'NUMBER_OF_INPUT_WORDS' size of FIFO.
	constant bit_num  : integer := C_RAM_ADDRESS_WIDTH;
	-- Bit width of data accessed in RAM mode
	constant data_width : integer := 8*C_RAM_DATA_WIDTH;
	-- FIFO write step
	constant write_step : integer := 4/C_RAM_DATA_WIDTH;
	-- Define the states of state machine
	-- The control state machine oversees the writing of input streaming data to the FIFO,
	-- and outputs the streaming data from the FIFO
	type state is ( RAM_MODE,        -- This is the initial/idle state.
	                FIFO_MODE); -- Write data to memory using the AXI_S interface
	signal axis_tready	: std_logic;
	-- State variable
	signal  mst_exec_state : state;  
	-- FIFO implementation signals
	signal  byte_index : integer;    
	-- FIFO write enable
	signal fifo_wren : std_logic;
	-- FIFO full flag
	signal fifo_full_flag : std_logic;
	-- FIFO write pointer
	signal write_pointer : std_logic_vector(C_RAM_ADDRESS_WIDTH-1 downto 0) ;
	-- sink has accepted all the streaming data and stored in FIFO
	signal writes_done : std_logic;
--    signal tlast_count : std_logic_vector((data_width/2)-1 downto 0);
--    signal write_count : std_logic_vector((data_width/2)-1 downto 0);
	type FIFO_WORD_TYPE is array (0 to (NUMBER_OF_INPUT_WORDS-1)) of std_logic_vector((data_width-1)downto 0);
	
    signal stream_data_fifo : FIFO_WORD_TYPE;
begin
	-- I/O Connections assignments

	S_AXIS_TREADY	<= axis_tready;
	-- Control state machine implementation
	process(S_AXIS_ACLK)
	begin
	  if (rising_edge (S_AXIS_ACLK)) then
	    if(S_AXIS_ARESETN = '0') then
	      -- Synchronous reset (active low)
	      mst_exec_state      <= RAM_MODE;
	    else
	      case (mst_exec_state) is
	        when RAM_MODE     => 
	          -- The sink starts accepting tdata when 
	          -- there tvalid is asserted to mark the
	          -- presence of valid streaming data 
	          if (S_AXIS_TVALID = '1')then
	            mst_exec_state <= FIFO_MODE;
	          else
	            mst_exec_state <= RAM_MODE;
	          end if;
	      
	        when FIFO_MODE => 
	          -- When the sink has accepted all the streaming input data,
	          -- the interface swiches functionality to a streaming master
	          if (writes_done = '1') then
--	          	tlast_count <= tlast_count + 1;
	            mst_exec_state <= RAM_MODE;
	          else
	            -- The sink accepts and stores tdata 
	            -- into FIFO
	            mst_exec_state <= FIFO_MODE;
	          end if;
	        
	        when others    => 
	          mst_exec_state <= RAM_MODE;
	      end case;
	    end if;  
	  end if;
	end process;
	-- AXI Streaming Sink 
	-- 
	-- The example design sink is always ready to accept the S_AXIS_TDATA  until
	-- the FIFO is not filled with NUMBER_OF_INPUT_WORDS number of input words.
	axis_tready <= '1' when ((mst_exec_state = FIFO_MODE) and (write_pointer <= NUMBER_OF_INPUT_WORDS-1)) else '0';

	process(S_AXIS_ACLK)
	begin
	  if (rising_edge (S_AXIS_ACLK)) then
	    if(S_AXIS_ARESETN = '0') then
	      writes_done <= '0';
	      write_pointer <= x"00";
	    else
	      if (write_pointer <= NUMBER_OF_INPUT_WORDS-1) then
	        if (fifo_wren = '1') then
	          -- write pointer is incremented after every write to the FIFO
	          -- when FIFO write signal is enabled.
	          writes_done <= '0';
	          write_pointer <= write_pointer + write_step;
--	          write_count <= write_count + 1;
	        end if;
	        if ((write_pointer = NUMBER_OF_INPUT_WORDS-1) or S_AXIS_TLAST = '1') then
	          -- reads_done is asserted when NUMBER_OF_INPUT_WORDS numbers of streaming data 
	          -- has been written to the FIFO which is also marked by S_AXIS_TLAST(kept for optional usage).
	          writes_done <= '1';
	        end if;
	      end  if;
	    end if;
	  end if;
	end process;

	-- FIFO write enable generation
	fifo_wren <= S_AXIS_TVALID and axis_tready;
	--R_RAM_WREADY <= '1' when (mst_exec_state = RAM_WRITE) else '0';

	-- FIFO Implementation
  -- Streaming input data is stored in FIFO
  process(S_AXIS_ACLK)
  begin
    if (rising_edge (S_AXIS_ACLK)) then
      if (fifo_wren = '1') then
        for i in 0 to (write_step-1) loop
            stream_data_fifo(to_integer(unsigned(write_pointer))+(write_step-i-1)) <= S_AXIS_TDATA(((i+1)*data_width -1) downto i*data_width);
        end loop;
        R_RAM_VALID <= '0';
      elsif (mst_exec_state = RAM_MODE) then
        if (R_RAM_WRITE = '1') then
            stream_data_fifo(to_integer(unsigned(R_RAM_ADDRESS))) <= R_RAM_DATA_IN;
            R_RAM_VALID <= '0';
        else
            R_RAM_DATA_OUT <= stream_data_fifo(to_integer(unsigned(R_RAM_ADDRESS)));
            R_RAM_VALID <= '1';
        end if;
      end if;
    end if;
  end process;
--    R_RAM_DATA_OUT <= write_pointer((data_width/2-1) downto 0) & tlast_count;
	-- Add user logic here

	-- User logic ends
end arch_imp;
