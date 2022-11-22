LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity con_logic is
  port (
  Reset : in std_logic;
  Clock : in std_logic;
  CONin : in std_logic;
  CON : out std_logic;
  c3_2_downto_0 : in STD_LOGIC_VECTOR(2 downto 0);
  cpu_bus : inout std_logic_vector(31 downto 0) := (others => 'Z')
    );
end con_logic;

architecture rtl of con_logic is
	signal con_next : std_logic;
	signal eq_zero : std_logic;
	signal branch_always : std_logic;
	signal branch_eq_zero : std_logic;
	signal branch_neq_zero : std_logic;
	signal branch_ge_zero : std_logic;
	signal branch_lt_zero : std_logic;
	signal buscheck : std_logic_vector(31 downto 0) := (others => '0');


begin  -- rtl

	con_current_state : process(Clock, Reset)
	begin
		if(Reset='1') then
			Con<='0';
		elsif rising_edge(Clock) then
			if(Conin='1') then
				CON<=con_next;
			end if;
		end if;
	end process con_current_state;
	
	eq_zero <= '1' when cpu_bus(31 downto 0)="00000000000000000000000000000000" else '0';
	
	branch_always <= '1' when c3_2_downto_0(2 downto 0) = "001" else '0';
	branch_neq_zero<= '1' when (c3_2_downto_0(2 downto 0)="011" and  eq_zero='0') else '0';
	branch_eq_zero<= '1' when (c3_2_downto_0(2 downto 0)="010" and eq_zero='1') else '0';
	
	branch_ge_zero<= '1' when (c3_2_downto_0="100" and  cpu_bus(31)='0') else '0';
	branch_lt_zero<= '1' when (c3_2_downto_0="101" and cpu_bus(31)='1') else '0';
	
	con_next<=(branch_always or branch_eq_zero or branch_neq_zero or branch_ge_zero or branch_lt_zero);
	

			
			
	
end rtl;