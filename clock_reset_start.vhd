use std.textio.all;
library IEEE;
use IEEE.std_logic_1164.all;

entity clock_reset_start is
  port (
    start  : out   std_logic := '0';
    reset  : out   std_logic := '0';
    clock  : out std_logic := '0';
    clock_UART : out std_logic := '0'
    );
end clock_reset_start;


architecture rtl of clock_reset_start is

  constant Period : time := 400 ns;
  signal clock_internal : std_logic := '0';
  constant UARTClockPeriod : time := 24 ns; -- ~40 MHz
  signal clock_internal_UART : std_logic := '0';

begin

  reset_gen : process
  begin
    reset <= '1' after Period/4, '0' after (Period * 3)/4;
    start <=  '1' after (Period * 5)/4, '0' after (Period * 7)/4;
    wait;
  end process reset_gen;

  clock_generator : process
  begin
    wait for Period/2;
    clock_internal <= not clock_internal;
  end process;

  clock <= clock_internal;

  UART_clock_generator : process
  begin
    wait for UARTClockPeriod/2;
    clock_internal_UART <= not clock_internal_UART;
  end process;

  clock_UART <= clock_internal_UART;

end rtl;
