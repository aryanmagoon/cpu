LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity program_counter is
  port (
    Reset : in std_logic;
	 Clock : in std_logic;
	 PCin : in std_logic;
	 PCout : in std_logic;
	 iack : in std_logic;
	 rfi_op : in std_logic;
	 cpu_bus : inout std_logic_vector(31 downto 0) := (others => 'Z')
    );
end program_counter;

architecture rtl of program_counter is

  signal register_contents : std_logic_vector(31 downto 0);
  signal ipc : std_logic_vector(31 downto 0);

begin  -- rtl

PC_process : process (Reset, Clock, PCin)
begin
	if(Reset='1') then
		register_contents <= (others => '0');
	elsif (rising_edge(Clock)) then
		if(rfi_op='1') then
			register_contents<=ipc;
		elsif(PCin ='1') then
			if(iack ='1') then
				register_contents<=(11 => cpu_bus(23), 10=> cpu_bus(22), 9=> cpu_bus(21), 8=> cpu_bus(20), 7 => cpu_bus(19), 6=> cpu_bus(18), 5=> cpu_bus(17), 4=> cpu_bus(16), others=>'0');
			else
				register_contents<=cpu_bus;
			end if;
		end if;
	end if;
end process PC_process;

CPU_process : process(PCout)
begin
	if(PCout = '1') then
		cpu_bus <= register_contents;
	else
		cpu_bus <= (others => 'Z');
	end if;
end process CPU_process;

ipc_register : process(Reset, iack)
begin
	if(Reset = '1') then
		ipc<=(others => '0');
	elsif rising_edge(iack) then
		ipc<= register_contents;
	end if;
end process ipc_register;
		
	
end rtl;