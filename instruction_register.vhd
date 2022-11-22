LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;

entity instruction_register is
  port (
    Reset : in std_logic;
	 Clock : in std_logic;
	 IRin : in std_logic;
	 c1out : in std_logic;
	 c2out : in std_logic;
	 Gra : in std_logic;
	 Grb : in std_logic;
	 Grc : in std_logic;
	 opcode : out std_logic_vector(4 downto 0);
	 register_select : out std_logic_vector(4 downto 0);
	 c3_2_downto_0: out std_logic_vector(2 downto 0);
	 cpu_bus : inout std_logic_vector(31 downto 0)
	
    );
end instruction_register;

architecture rtl of instruction_register is
	signal register_contents : std_logic_vector(31 downto 0);

begin  -- rtl

IR_process : process(Reset, Clock)
begin
	if (Reset = '1') then
		register_contents <= (others => '0');
	elsif rising_edge(Clock) then
		if(IRin ='1') then
			register_contents <= cpu_bus;
		end if;
	end if;
end process IR_process;
cpu_bus_process : process(c1out, c2out, register_contents)
begin
	if(c1out= '1') then
		cpu_bus(21 downto 0) <= register_contents(21 downto 0);
		cpu_bus(31 downto 22) <= (others => register_contents(21));
	elsif(c2out = '1') then
		cpu_bus(16 downto 0) <= register_contents(16 downto 0);
		cpu_bus(31 downto 17) <= (others => register_contents(16));
	else
		cpu_bus <= (others => 'Z');
	end if;
end process cpu_bus_process;
register_select_process : process(Gra, Grb, Grc, register_contents)
begin
	if(Gra = '1') then
		register_select <= register_contents(26 downto 22);
	elsif(Grb = '1') then
		register_select <= register_contents(21 downto 17);
	elsif(Grc = '1') then
		register_select <= register_contents(16 downto 12);
	else
		register_select <= (others => '0');
	end if;
	
end process register_select_process;

opcode <= register_contents(31 downto 27);

c3_2_downto_0<= register_contents(2 downto 0);



end rtl;