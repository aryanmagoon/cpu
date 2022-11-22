library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity memory_interface is
  port(
    Reset    : in std_logic;
    Clock     : in std_LOGIC;
    memstrobe   : in std_logic;
    MAin     : in std_logic;
    MDwr     : in std_logic;
    MDbus    : in std_logic;
    MDrd     : in std_logic;
    MDout    : in std_logic;
    Addr_Bus : out std_logic_vector(31 downto 0);
    Data_Bus : inout std_logic_vector(31 downto 0);
    cpu_bus  : inout std_logic_vector(31 downto 0)
    );
End memory_interface;


Architecture Rtl of memory_interface is

  signal ma_contents : std_logic_vector(31 downto 0);
  signal md_contents : std_logic_vector(31 downto 0);
  signal md_input    : std_logic_vector(31 downto 0);
  signal md_enable    : std_logic;

begin

  Addr_Bus <= ma_contents;

  ma_register : process(Clock, Reset)
  begin
    if (Reset = '1') then
      ma_contents <= (others => '0');
    elsif (falling_edge(Clock)) then
      if(MAin = '1') then
        ma_contents <= cpu_bus;
      end if;
    end if;
  end process ma_register;

  md_logic : process(MDbus, MDrd, memstrobe, Data_Bus, cpu_bus)
  begin
    if(MDbus = '1') then
      md_input <= cpu_bus;
    elsif(MDrd = '1') then
      md_input <= Data_Bus;
    else
      md_input <= (others => '0');
    end if;

    if ((MDbus = '1') or ((MDrd = '1') and (memstrobe = '1'))) then
      md_enable <= '1';
    else
      md_enable <= '0';
    end if;
  end process md_logic;

  md_register : process(Clock, Reset)
  begin
    if (Reset = '1') then
      md_contents <= (others => '0');
    elsif (falling_edge(Clock)) then
      if(md_enable = '1') then
        md_contents <= md_input;
      end if;
    end if;
  end process md_register;

  md_tristate : process(md_contents,MDwr,MDout)
  begin
    if(MDwr = '1') then
      Data_Bus <= md_contents;
    else
      Data_Bus <= (others => 'Z');
    end if;

    if(MDout = '1') then
      cpu_bus <= md_contents;
    else
      cpu_bus <= (others => 'Z');
    end if;
  end process md_tristate;

end Rtl;
