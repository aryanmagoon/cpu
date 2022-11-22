--===========================================================================--
--
--  S Y N T H E Z I A B L E    miniUART   C O R E
--
--  www.OpenCores.Org - January 2000
--  This core adheres to the GNU public license  
--
-- Design units   : miniUART core for the OCRP-1
--
-- File name      : miniuart.vhd
--
-- Purpose        : Implements an miniUART device for communication purposes 
--                  between the OR1K processor and the Host computer through
--                  an RS-232 communication protocol.
--                  
-- Library        : uart_lib.vhd
--
-- Dependencies   : IEEE.Std_Logic_1164
--===========================================================================--
-- Description    : The memory consists of a dual-port memory addressed by
--                  two counters (RdCnt & WrCnt). The third counter (StatCnt)
--                  sets the status signals and keeps a track of the data flow.
-------------------------------------------------------------------------------
-- Entity for miniUART Unit - 9600 baudrate                                  --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.UART_Def.all;

entity miniUART is
  port (
    ProcClk  : in std_logic;
    SysClk   : in  Std_Logic;  -- UART System Clock
    Reset    : in  Std_Logic;  -- Reset input
--    CS_N     : in  Std_Logic;
--    RD_N     : in  Std_Logic;
--    WR_N     : in  Std_Logic;
    RD     : in  Std_Logic;
    WR     : in  Std_Logic;
    Done     : out std_logic := 'Z';
    Memstrobe : out std_logic := 'Z';
    RxD      : in  Std_Logic;
    TxD      : out Std_Logic;
    IntRx_N  : out Std_Logic;  -- Receive interrupt
    IntTx_N  : out Std_Logic;  -- Transmit interrupt
    iack     : in std_logic;           -- interrupt acknowledge
--     Addr     : in  Std_Logic_Vector(1 downto 0); -- 
--     DataIn   : in  Std_Logic_Vector(7 downto 0); -- 
--     DataOut  : out Std_Logic_Vector(7 downto 0)); -- 
    Addr_Bus : in  Std_Logic_Vector(31 downto 0); -- 
    Data_Bus : inout Std_Logic_Vector(31 downto 0) := (others => 'Z')); -- 
end entity;
-------------------------------------------------------------------------------
-- Architecture for miniUART Controller Unit
-------------------------------------------------------------------------------
architecture rtl of miniUART is
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal RxData : Std_Logic_Vector(7 downto 0); -- 
  signal TxData : Std_Logic_Vector(7 downto 0); -- 
  signal CSReg  : Std_Logic_Vector(7 downto 0); -- Ctrl & status register
  --             CSReg detailed 
  -----------+--------+--------+--------+--------+--------+--------+--------+
  -- CSReg(7)|CSReg(6)|CSReg(5)|CSReg(4)|CSReg(3)|CSReg(2)|CSReg(1)|CSReg(0)|
  --   Res   |  Res   |  Res   |  Res   | UndRun | OvrRun |  FErr  |  OErr  |
  -----------+--------+--------+--------+--------+--------+--------+--------+
  signal EnabRx : Std_Logic;  -- Enable RX unit
  signal EnabTx : Std_Logic;  -- Enable TX unit
  signal DRdy   : Std_Logic;  -- Receive Data ready
  signal TRegE  : Std_Logic;  -- Transmit register empty
  signal TBufE  : Std_Logic;  -- Transmit buffer empty
  signal FErr   : Std_Logic;  -- Frame error
  signal OErr   : Std_Logic;  -- Output error
  signal Read   : Std_Logic;  -- Read receive buffer
  signal Load   : Std_Logic;  -- Write to UART
  signal LoadTxD   : Std_Logic;  -- Load transmit buffer
  signal CS_N : std_logic;
  signal SelectMemory0x0, SelectMemory0x4 : std_logic;
  signal Isrc_info : std_logic_vector(15 downto 0);
  signal Isrc_vect_Rx : std_logic_vector(7 downto 0);
  signal Isrc_vect_Tx : std_logic_vector(7 downto 0);
  signal Int_Tx_N_enable : std_logic := '1';  -- interrupt mask bits
  signal Int_Rx_N_enable : std_logic := '1';  -- '1' disables interrupts

  -----------------------------------------------------------------------------
  -- Baud rate Generator
  -----------------------------------------------------------------------------
  component ClkUnit is
    port (
      SysClk   : in  Std_Logic;  -- System Clock
      EnableRX : out Std_Logic;  -- Control signal
      EnableTX : out Std_Logic;  -- Control signal
      Reset    : in  Std_Logic   -- Reset input
      );
  end component;
  -----------------------------------------------------------------------------
  -- Receive Unit
  -----------------------------------------------------------------------------
  component RxUnit is
    port (
      Clk    : in  Std_Logic;  -- Clock signal
      Reset  : in  Std_Logic;  -- Reset input
      Enable : in  Std_Logic;  -- Enable input
      RxD    : in  Std_Logic;  -- RS-232 data input
      RD     : in  Std_Logic;  -- Read data signal
      FErr   : out Std_Logic;  -- Status signal
      OErr   : out Std_Logic;  -- Status signal
      DRdy   : out Std_Logic;  -- Status signal
      DataIn : out Std_Logic_Vector(7 downto 0)
      );
  end component;
  -----------------------------------------------------------------------------
  -- Transmitter Unit
  -----------------------------------------------------------------------------
  component TxUnit is
    port (
      Clk    : in  Std_Logic;  -- Clock signal
      Reset  : in  Std_Logic;  -- Reset input
      Enable : in  Std_Logic;  -- Enable input
      Load   : in  Std_Logic;  -- Load transmit data
      TxD    : out Std_Logic;  -- RS-232 data output
      TRegE  : out Std_Logic;  -- Tx register empty
      TBufE  : out Std_Logic;  -- Tx buffer empty
      DataO  : in  Std_Logic_Vector(7 downto 0)
      );
  end component;
begin
  -----------------------------------------------------------------------------
  -- Address decoding to generate internal version of chip select, CS_N, which
  -- in the original model was an input to the device.
  -- The memory map has two 32-bit memory locations, 0xFFFFF000 and 0xFFFFF004.
  -- Bit number
  -- 3    2    2    1    1    1
  -- 1    7    3    9    5    1    7    3210
  -- 1111 1111 1111 1111 1111 0000 0000 0000 = 0xFFFFF000
  -- 1111 1111 1111 1111 1111 0000 0000 0100 = 0xFFFFF004
  --
  -- The first memory location at Addr_Bus(3 downto 0) = "0000" is used to either
  -- write to the transmit register or read from the receive register.
  --
  -- The second memory location at Addr_Bus(3 downto 0) = "0100" is used to
  -- either write the ISR vectors for this device or read the control/status
  -- register, CSReg.
  -----------------------------------------------------------------------------
  CS_N <= not (Addr_Bus(31) and Addr_Bus(30) and Addr_Bus(29) and Addr_Bus(28) and
               Addr_Bus(27) and Addr_Bus(26) and Addr_Bus(25) and Addr_Bus(24) and
               Addr_Bus(23) and Addr_Bus(22) and Addr_Bus(21) and Addr_Bus(20) and
               Addr_Bus(19) and Addr_Bus(18) and Addr_Bus(17) and Addr_Bus(16) and
               Addr_Bus(15) and Addr_Bus(14) and Addr_Bus(13) and Addr_Bus(12));
  SelectMemory0x0 <= not(Addr_Bus(3)) and not(Addr_Bus(2));
  SelectMemory0x4 <= not(Addr_Bus(3)) and (Addr_Bus(2));

  isrc_info <= "0000000000000000";
  
  -----------------------------------------------------------------------------
  -- Instantiation of internal components
  -----------------------------------------------------------------------------
  ClkDiv  : ClkUnit port map (SysClk,EnabRX,EnabTX,Reset); 
  TxDev   : TxUnit port map (SysClk,Reset,EnabTX,LoadTxD,TxD,TRegE,TBufE,TxData);
  RxDev   : RxUnit port map (SysClk,Reset,EnabRX,RxD,Read,FErr,OErr,DRdy,RxData);
  -----------------------------------------------------------------------------
  -- Implements the controller for Rx&Tx units
  -----------------------------------------------------------------------------
  RSBusCtrl : process(SysClk,Reset,Read,Load)
    variable StatM : Std_Logic_Vector(4 downto 0);
  begin
    if Rising_Edge(SysClk) then
--      if Reset = '0' then
      if Reset = '1' then
        StatM := "00000";
        IntTx_N <= '1';
        IntRx_N <= '1';
        CSReg <= "11110000";
      else
        StatM(0) := DRdy;
        StatM(1) := FErr;
        StatM(2) := OErr;
        StatM(3) := TBufE;
        StatM(4) := TRegE;
      end if;
      case StatM is
        -- Data in Rx register ready to be read.
        when "00001" =>
          IntRx_N <= '0' or Int_Rx_N_enable;
          CSReg(2) <= '1';
        -- Tx register is full (i.e. still transmitting character), but the
        -- transmit buffer is empty and can be written to with another character
        when "01000" =>
          IntTx_N <= '0' or Int_Tx_N_enable;
          CSReg(3) <= '1';
        -- Both the transmit buffer is empty, and the Rx buffer is full.
        when "01001" =>
          IntRx_N <= '0' or Int_Rx_N_enable;
          CSReg(2) <= '1';
          IntTx_N <= '0' or Int_Tx_N_enable;
          CSReg(3) <= '1';
        when "10001" =>
          IntRx_N <= '0' or Int_Rx_N_enable;
          CSReg(2) <= '1';
        when "11001" =>
          IntRx_N <= '0' or Int_Rx_N_enable;
          CSReg(2) <= '1';
        when "11000" =>
          IntTx_N <= '0' or Int_Tx_N_enable;
          CSReg(3) <= '1';
        when others => null;
      end case;

      if (Read = '1' and SelectMemory0x0 = '1') then
        CSReg(2) <= '0';
        IntRx_N <= '1';
      end if;

      if (Load = '1' and SelectMemory0x0 = '1') then
        CSReg(3) <= '0';
        IntTx_N <= '1';
      end if;
    end if;
  end process;
  -----------------------------------------------------------------------------
  -- Combinational section
  -----------------------------------------------------------------------------
  process(SysClk)
  begin
--    if (CS_N = '0' and RD_N = '0') then
    if (CS_N = '0' and RD = '1') then
      Read <= '1';
    else
      Read <= '0';
    end if;
    
--    if (CS_N = '0' and WR_N = '0') then
    if (CS_N = '0' and WR = '1') then
      Load <= '1';
    else
      Load <= '0';
    end if;
  end process;

  LoadTxD <= Load and SelectMemory0x0;

  process(SysClk)
  begin
    if (iack = '1') then
      Data_Bus(15 downto 0) <= isrc_info;
      -- Note that if both interrupts are active at the same time, then the
      -- receive interrupt is serviced first (since there is not a receive
      -- buffer, as there is with the transmit function).
      if (CSReg(2) = '1') then
        Data_Bus(23 downto 16) <= isrc_vect_rx;
      elsif (CSReg(3) = '1') then
        Data_Bus(23 downto 16) <= isrc_vect_tx;
      else
        Data_Bus(23 downto 16) <= (others => '0');
      end if;
      Data_Bus(31 downto 24) <= (others => '0');
    elsif (Read = '1' and SelectMemory0x0 = '1') then
      Data_Bus(7 downto 0) <= RxData;
      Data_Bus(31 downto 8) <= (others => '0');
    elsif (Read = '1' and SelectMemory0x4 = '1') then
      Data_Bus(7 downto 0) <= CSReg;
      Data_Bus(31 downto 8) <= (others => '0');
    else
      Data_Bus <= (others => 'Z');
    end if;
  end process;

  -- Note that the processor clock is used to latch data from the data bus
  -- instead of the UART system clock to prevent invalid data that's on the
  -- data bus at the end of a processor clock cycle to be latched, due to the
  -- fact that the UART system clock is much faster than the processor clock.
  process(ProcClk)
  begin
    if falling_edge(ProcClk) then
      if (LoadTxD = '1') then
        TxData <= Data_Bus(7 downto 0);
        
      elsif (Load = '1' and SelectMemory0x4 = '1') then
        Isrc_vect_Rx <= Data_Bus(15 downto 8);
        Isrc_vect_Tx <= Data_Bus(7 downto 0);

        -- mask bits to mask the Tx and Rx interrupts
        Int_Tx_N_enable <= Data_Bus(16);
        Int_Rx_N_enable <= Data_Bus(17);
      end if;
    end if;
  end process;

  -- purpose: Generate done and memstrobe signals.
  Done_signal_process: process (Read, Load, iack)
  begin  -- process Complete_signal_process
    if (Read = '1' or iack = '1') then
      done <= '1';
      Memstrobe <= '1';
    elsif (Load = '1') then
      done <= '1';
      Memstrobe <= '0';
    else
      done <= 'Z';
      Memstrobe <= 'Z';
    end if;
  end process Done_signal_process;

end rtl;