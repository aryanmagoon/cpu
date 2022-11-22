use std.textio.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ram_6116 is
  port (
    Addr : in std_logic_vector(10 downto 0);
          OE   : in std_logic;
          CE   : in std_logic;
          WE   : in std_logic;
          Data : inout std_logic_vector(7 downto 0)
    );
end ram_6116;


architecture rtl of ram_6116 is

  constant Delay : time := 70 ns;
  constant MemorySize : integer := 2047;
  type ram_array is array(MemorySize DOWNTO 0) of std_logic_vector(7 downto 0);
  signal ram_contents : ram_array;

begin

  memory : process(Addr, OE, CE, WE)
  begin
    if(OE = '0' and CE = '0' and WE = '1') then
      Data <= ram_contents(To_Integer(unsigned(Addr))) after Delay;
    elsif(OE = '1' and CE = '0' and rising_edge(WE)) then
      ram_contents(To_Integer(unsigned(Addr))) <= Data after Delay;
    else
      Data <= (others => 'Z') after Delay;
    end if;
  end process memory;

end rtl;

