library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity memory_bus_controller is
  port (
    Clock         : in std_logic;
    Reset       : in std_logic;
    R           : in std_logic;
    W           : in std_logic;
    addr_bus        : in std_logic_vector(31 downto 0);
    done        : out std_logic;
    memstrobe   : out std_logic;
    RAM_OE      : out std_logic;
    RAM_CS      : out std_logic;
    RAM_WE      : out std_logic;
    ROM_OE      : out std_logic;
    ROM_CS      : out std_logic
    );
end memory_bus_controller;


architecture RTL of memory_bus_controller is

  type STATES is (IDLE,ROMR,RAMR,RAMW1,RAMW2);
  signal current_state : STATES := IDLE;
  signal next_state    : STATES := IDLE;
  signal RAM_address, ROM_address : std_logic;

begin	

  -- The memory map has a 27c64-based EPROM (32 bits wide) from
  -- address 0x00000000 to 0x00007FFF:
  -- Bit number
  -- 3    2    2    1    1
  -- 1    7    3    9    5
  -- 0000 0000 0000 0000 0111 1111 1111 1111 = 0x00007FFF
  
  ROM_address <= not(
    addr_bus(31) or addr_bus(30) or addr_bus(29) or addr_bus(28) or
    addr_bus(27) or addr_bus(26) or addr_bus(25) or addr_bus(24) or
    addr_bus(23) or addr_bus(22) or addr_bus(21) or addr_bus(20) or
    addr_bus(19) or addr_bus(18) or addr_bus(17) or addr_bus(16) or
    addr_bus(15));

  -- The memory map has a 6116-based SRAM memory from
  -- address 0x00008000 to address 0x00009FFF:
  -- Bit number
  -- 3    2    2    1    1
  -- 1    7    3    9    5
  -- 0000 0000 0000 0000 1000 0000 0000 0000 = 0x00008000
  -- 0000 0000 0000 0000 1001 1111 1111 1111 = 0x00009FFF
  RAM_address <= not(
    addr_bus(31) or addr_bus(30) or addr_bus(29) or addr_bus(28) or
    addr_bus(27) or addr_bus(26) or addr_bus(25) or addr_bus(24) or
    addr_bus(23) or addr_bus(22) or addr_bus(21) or addr_bus(20) or
    addr_bus(19) or addr_bus(18) or addr_bus(17) or addr_bus(16)) and
                 addr_bus(15);

  CLKD : process(Clock,Reset)
  begin
    if(Reset = '1') then
      current_state <= IDLE;
    elsif rising_edge(Clock) then
      current_state <= next_state;
    end if;
  end process CLKD;

  STATE_TRANS : process(current_state,W,R,RAM_address,ROM_address)
  begin
    next_state <= current_state;
    case current_state is
      when IDLE =>
        if(ROM_address = '1' and R = '1') then
          next_state <= ROMR;
        elsif(RAM_address = '1' and R = '1') then
          next_state <= RAMR;
        elsif(RAM_address = '1' and W = '1') then
          next_state <= RAMW1;
        else
          next_state <= IDLE;
        end if;
      when ROMR =>
        next_state <= IDLE;
      when RAMR =>
        next_state <= IDLE;
      when RAMW1 =>
        next_state <= RAMW2;
      when RAMW2 =>
        next_state <= IDLE;
      when others =>
        next_state <= IDLE;
    end case;
  end process STATE_TRANS;

  OUTPUT : process(current_state)
  begin
    case current_state is
      when IDLE =>
--        done      <= '0';
--        memstrobe <= '0';
        done      <= 'Z'; -- interrupt
        memstrobe <= 'Z'; -- interrupt
        RAM_WE    <= '1';
        RAM_OE    <= '1';
        RAM_CS    <= '1';
        ROM_OE    <= '1';
        ROM_CS    <= '1';
      when ROMR =>
        done      <= '1';
        memstrobe <= '1';
        RAM_WE    <= '1';
        RAM_OE    <= '1';
        RAM_CS    <= '1';
        ROM_OE    <= '0';
        ROM_CS    <= '0';
      when RAMR =>
        done      <= '1';
        memstrobe <= '1';
        RAM_WE    <= '1';
        RAM_OE    <= '0';
        RAM_CS    <= '0';
        ROM_OE    <= '1';
        ROM_CS    <= '1';
      when RAMW1 =>
        done      <= '0';
        memstrobe <= '0';
        RAM_WE    <= '0';
        RAM_OE    <= '1';
        RAM_CS    <= '0';
        ROM_OE    <= '1';
        ROM_CS    <= '1';
      when RAMW2 =>
        done      <= '1';
        memstrobe <= '0';
        RAM_WE    <= '1';
        RAM_OE    <= '1';
        RAM_CS    <= '0';
        ROM_OE    <= '1';
        ROM_CS    <= '1';
    end case;
  end process OUTPUT;
end RTL;