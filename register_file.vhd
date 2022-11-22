library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
  port (
    Reset : in std_logic;
	 Clock : in std_logic;
	 register_select : in std_logic_vector(4 downto 0);
	 Rin : in std_logic;
	 Rout : in std_logic;
	 BAout : in std_logic;
	 cpu_bus : inout std_logic_vector(31 downto 0) := (others => 'Z')
	
    );
end register_file;

architecture rtl of register_file is
	type registerFile is array(0 to 31) of std_logic_vector(31 downto 0);
	signal registers : registerFile;

begin  -- rtl



register_process : process(Reset, Clock, Rin, register_select)
variable i : integer := 0;
begin
	if (Reset = '1') then
		for i in 0 to 31 loop
			registers(i)<=(others=>'0');
		end loop;
	elsif (rising_edge(Clock) and Rin='1')  then
		registers(to_integer(unsigned(register_select)))<=cpu_bus;
	end if;
end process register_process;

bus_process : process(Rout, BAout, register_select)
begin
if(Rout = '1') then
	cpu_bus(31 downto 0)<=registers(to_integer(unsigned(register_select)))(31 downto 0);
elsif(BAout='1' and to_integer(unsigned(register_select)) = 0) then
	cpu_bus <= (others => '0');
elsif(BAout='1' and to_integer(unsigned(register_select)) /=0) then
	cpu_bus <= registers(to_integer(unsigned(register_select)));
else
	cpu_bus<= (others =>'Z');
end if;
	
end process bus_process;

end rtl;
