LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity shift_control is
  port (
  Reset : in std_logic;
  Clock : in std_logic;
  ld_shift : in std_logic;
  decr : in std_logic;
  Neq0 : out std_logic;
  cpu_bus : inout std_logic_vector(31 downto 0) := (others => 'Z')
    );
end shift_control;

architecture rtl of shift_control is
signal n_counter : unsigned(4 downto 0);
signal n_counter_next : unsigned(4 downto 0);


begin  -- rtl

	n_counter_current_state : process(reset, clock)
	begin
		if(reset='1') then
			n_counter<= (others => '0');
		elsif rising_edge(clock) then
			n_counter<= n_counter_next;
		end if;
	end process n_counter_current_state;
	
	n_counter_next_state : process (ld_shift, decr, cpu_bus, n_counter)
	begin
		if(ld_shift='1' and decr='0') then
			n_counter_next<=unsigned(cpu_bus(4 downto 0));
		elsif(ld_shift='0' and decr='1') then
			n_counter_next<=n_counter-1;
		end if;
	end process n_counter_next_state;
	
	Neq0<= '1' when n_counter=0 else '0';

	

			
			
	
end rtl;