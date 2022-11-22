LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity alu is
  port (
    Reset : in std_logic;
	 Clock : in std_logic;
	 Ain : in std_logic;
	 Cin : in std_logic;
	 Cout : in std_logic;
	 ADD_op : in std_logic;
	 SUB_op : in std_logic;
	 Neg_op : in std_logic;
	 AND_op : in std_logic;
	 OR_op : in std_logic;
	 Not_op : in std_logic;
	 SHR_op : in std_logic;
	 SHRA_op : in std_logic;
	 SHL_op : in std_logic;
	 SHC_op : in std_logic;
	 CeqB_op : in std_logic;
	 INCR4_op : in std_logic;
	 cpu_bus : inout std_logic_vector(31 downto 0):=(others => 'Z')
    );
end alu;

architecture rtl of alu is
	signal A_Q : unsigned(31 downto 0);
	signal B : unsigned(31 downto 0);
	signal C : unsigned(31 downto 0);
	signal C_Q : unsigned(31 downto 0);

  

begin  -- rtl

a_register : process(Clock, Reset)
begin
	if(Reset='1') then
		A_Q <= (others => '0');
	elsif(Ain='1' and rising_edge(Clock)) then
		A_Q <= unsigned(cpu_bus);
	end if;
end process a_register;

B<= unsigned(cpu_bus);

alu_logic : process(A_Q, B, ADD_op, CeqB_op, Not_op, OR_op, Neg_op,
AND_op, SUB_op, SHR_op, SHRA_op, SHL_op, SHC_op, INCR4_op)
begin
if(ADD_op='1') then
	C<= A_Q+B;
elsif(CeqB_op='1') then
	C<=B;
elsif(Not_op='1') then
	C<=not(B);
elsif(OR_op='1') then	
	C<= (A_Q or B);
elsif(Neg_op='1') then
	C<= unsigned(-(signed(B)));
elsif(AND_op='1') then
	C<= (A_Q and B);
elsif(SUB_op='1') then
	C<= A_Q-B;
elsif(SHR_op='1') then
	C<=shift_right(B,1);
elsif(SHL_op='1') then
	C<=shift_left(B,1);
elsif(INCR4_op='1') then
	C<=(B+4);
elsif(SHC_op='1') then
	C<=rotate_left(B,1);
elsif(SHRA_op = '1') then
	C(31)<=B(31);
	C(30 downto 0)<=B(31 downto 1);
else
	C<= (others => '0');
end if;
end process alu_logic;

c_register : process(Clock, Reset)
begin
	if(Reset='1') then
		C_Q<=(others => '0');
	elsif(Cin='1' and rising_edge(Clock)) then
		C_Q<=C;
	end if;	
end process c_register;

c_tristate : process(Cout, C_Q)
begin
	if(Cout='1') then
		cpu_bus<=std_logic_vector(C_Q);
	else
		cpu_bus<= (others => 'Z');
	end if;
end process c_tristate;


end rtl;