use std.textio.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rom_27C64 is
  generic (
    filename : string := "romfile"
    );
  port (
    Addr : in std_logic_vector(12 downto 0);
          OE   : in std_logic;
          CE   : in std_logic;
          Data : out std_logic_vector(7 downto 0)
    );
end rom_27C64;


architecture rtl of rom_27C64 is

  constant not_digit : integer := -999;
  constant Delay : time := 5 ns;
  constant MemorySize : integer := 8191;
  type rom_array is array(MemorySize DOWNTO 0) of std_logic_vector(7 downto 0);
  signal rom_contents : rom_array;
  signal first : boolean := false;

  function digit_value(c : character) return integer is
    begin
      if (c >= '0') AND (c <= '9') then
        return (character'pos(c) - character'pos('0'));
      elsif (c >= 'a') AND (c <= 'f') then
        return (character'pos(c) - character'pos('a') + 10);
      elsif (c >= 'A') AND (c <= 'F') then
        return (character'pos(c) - character'pos('A') + 10);
      else
        return not_digit;
      end if;
  end function digit_value;

  procedure read_modelfile (file fp : text;
                            signal memory_image : inout rom_array) is
    variable ln : line;
    variable temp_char : character;
    variable temp_value : natural;
    variable temp_addr : natural;
    variable temp_data : natural;
    variable good : boolean;
  begin
    while(not(endfile (fp))) loop
      readline(fp,ln);
      read(ln,temp_char,good);
      if(good and (digit_value(temp_char) /= not_digit)) then
        temp_addr := digit_value(temp_char);
        read(ln,temp_char,good);
        while(good and (digit_value(temp_char) /= not_digit)) loop
          temp_addr := temp_addr * 16 + digit_value(temp_char);
          read(ln,temp_char,good);
        end loop;
        read(ln,temp_char);
        temp_value := digit_value(temp_char);
        read(ln,temp_char);
        temp_data := temp_value * 16 + digit_value(temp_char);
        memory_image(temp_addr) <= std_logic_vector(To_Unsigned(temp_data,8));
      end if;
    end loop;
    return;
 end read_modelfile;

begin

  initialize : process
      file fp : text open READ_MODE is filename;
  begin
    read_modelfile(fp,rom_contents);
    wait;
  end process initialize;

  memory : process(Addr, OE, CE)
  begin
    if(OE = '0' and CE = '0') then
      Data <= rom_contents(To_Integer(unsigned(Addr))) after Delay;
    else
      Data <= "ZZZZZZZZ" after Delay;
    end if;
  end process memory;

end rtl;

