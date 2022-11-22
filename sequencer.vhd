LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity sequencer is
  port(
    Reset     : in   std_logic;
    Clock      : in   std_logic;
    Start     : in   std_logic;
    Done      : in  std_logic;
    End_sig : in std_logic;
    Goto6 : in std_logic;
    Read_control : in std_logic;
    Write_control : in std_logic;
    Wait_sig : in std_logic;
    Stop_sig : in std_logic;
	 rfi_sig : in std_logic;
	 een_sig : in std_logic;
	 edi_sig : in std_logic;
	 ireq : in std_logic;
    t0 : out std_logic;
    t1 : out std_logic;
    t2 : out std_logic;
    t3 : out std_logic;
    t4 : out std_logic;
    t5 : out std_logic;
    t6 : out std_logic;
    t7 : out std_logic;
    t8 : out std_logic;
    t9 : out std_logic;
    t10 : out std_logic;
    t11 : out std_logic;
    t12 : out std_logic;
    t13 : out std_logic;
    t14 : out std_logic;
    t15 : out std_logic;
    r_sequencer : out std_logic;
    w_sequencer : out std_logic;
	 iack : out std_logic
    );
end sequencer;

architecture rtl of sequencer is

	type states is (Initial, Stop_Q, Run, Read_Q, Write_Q, Interrupt);
	signal current_state, next_state : states;
	signal t_counter, t_counter_next : unsigned(3 downto 0);
	signal Run_sig, Run_sig_next : std_logic;
	signal ie : std_logic;
	signal iack_internal : std_logic;
	signal ie_reset : std_logic;
	signal ie_clk : std_logic;
	
	
begin
  --This process models a JK Flip flop, where J = Start and K= Stop_Q_sig. The
  --purpose is to capture the rising edge of Start that starts the CPU and rising
  --edge of the Stop_Q_sig that Stop_Qs the CPU.
  run_signal_process : process(Clock,Reset)
  begin
			if(Reset = '1') then
                run_sig <= '0';
            elsif rising_edge(clock) then
                run_sig <= run_sig_next;
            end if;
  end process run_signal_process;
  
  --JK Flip flop: q+  = Jq' and K'q, J= Start , K = Stop_Q_sig
  Run_sig_next <= (Start and not (Run_sig)) or (not(Stop_sig) and Run_sig);

  --the following implements the fetch_execute FSM for the control unit.
  -- number of flip flops log_2(5) -> 3 flip flops
  current_state_fetch_execute: process (clock, reset)
  begin
            if(Reset = '1') then
                current_state<= Initial;
            elsif rising_edge(clock) then
                current_state <= next_state;
            end if;
  end process current_state_fetch_execute;
  
  next_state_fetch_execute : process(current_state, Run_sig, Done, Read_control, Write_control)
  begin
        case current_state is
            when Initial => 

                if(run_sig = '1') then
                    next_state <= Run;
                else
                    next_state <= Initial;
                end if;

            when Run => 

                if(run_sig = '0') then
                    next_state <= Stop_Q;
					 elsif (ireq = '0' and ie = '1' and t_counter ="0000") then
							next_state <= Interrupt;
                elsif(read_control = '1')then
                    next_state <= Read_Q;
                elsif (write_control = '1')then
                    next_state <= Write_Q;
                else 
                    next_state <= Run;
                end if;

            when Read_Q | Write_Q => 
					if(Done = '1') then
						next_state<=Run;
					else
						next_state <= current_state;
					end if;

            when Stop_Q => 

                next_state <= Stop_Q;
				when Interrupt =>
					if(t_counter = "0001") then
						next_state <= Run;
					else
						next_state<= Interrupt;
					end if;

        end case;
    end process next_state_fetch_execute;


    fetch_execute_output : process(current_state)
    begin 
        case current_state is

            when Initial =>
                r_sequencer <= '0';
                w_sequencer <= '0';
            when Run =>
                r_sequencer <= '0';
                w_sequencer <= '0';
            when Read_Q =>
                r_sequencer <= '1';
                w_sequencer <= '0';
            when Write_Q =>
                r_sequencer <= '0';
                w_sequencer <= '1';
            when Stop_Q =>
                r_sequencer <= '0';
                w_sequencer <= '0';
				when Interrupt =>
					r_sequencer <= '0';
               w_sequencer <= '0';
					iack_internal<='1';
				when others =>
					r_sequencer <= '0';
               w_sequencer <= '0';
					iack_internal<='0';
        end case;
    end process fetch_execute_output;
	 
	 iack<=iack_internal;

            --finally the following code impelments the counter that generates the T0-T15 sequence timing
    current_state_t_counter : process (Clock, Reset)
    begin
        if(Reset = '1') then
            t_counter<= (others => '0');
        elsif rising_edge(clock) then
            t_counter <= t_counter_next;
        end if;
    end process current_state_t_counter;

    next_state_t_counter : process ( t_counter, current_state, Run_sig, End_sig, Goto6, Wait_sig, Done)
    begin
         case current_state is
            when Run =>

                if(wait_sig = '1') then
                    t_counter_next <= t_counter;
                else
                    if(end_sig = '1') then
                        t_counter_next <= (others => '0');
                    elsif(goto6 = '1') then
                        t_counter_next <= "0110";
                    else 
                        t_counter_next <= t_counter + 1;
                    end if;
                end if;

            when Read_Q | Write_Q =>
					if(Done ='1') then
						if(end_sig = '1') then
							t_counter_next <= "0000";
						else
							t_counter_next<= t_counter +1;
						end if;
					else
						t_counter_next<=t_counter;
					end if;
				when Interrupt =>
					if(t_counter = "0001") then
						t_counter_next <= "0000";
					else
						t_counter_next<=t_counter+1;
					end if;

            when others =>

                t_counter_next <= t_counter;

        end case;
    end process next_state_t_counter;
	 
	 ie_current_state: process (ie_reset, ie_clk)
	 begin
		if(ie_reset = '1') then
			ie<='0';
		elsif(rising_edge(ie_clk)) then
			ie<='1';
		end if;
	end process ie_current_state;
	
	ie_clk<= een_sig or rfi_sig;
	ie_reset <= Reset or iack_internal or edi_sig; 

    --output logic
    --t0 <= '1' when t_counter = "0000" else "0"
    t0 <= not t_counter(3) and not t_counter(2) and not t_counter(1) and not t_counter(0);
    t1 <= not t_counter(3) and not t_counter(2) and not t_counter(1) and t_counter(0);
    t2 <= not t_counter(3) and not t_counter(2) and t_counter(1) and not t_counter(0);
    t3 <= not t_counter(3) and not t_counter(2) and t_counter(1) and t_counter(0);
    t4 <= not t_counter(3) and t_counter(2) and not t_counter(1) and not t_counter(0);
    t5 <= not t_counter(3) and t_counter(2) and not t_counter(1) and t_counter(0);
    t6 <= not t_counter(3) and t_counter(2) and t_counter(1) and not t_counter(0);
    t7 <= not t_counter(3) and t_counter(2) and t_counter(1) and t_counter(0);
    t8 <= t_counter(3) and not t_counter(2) and not t_counter(1) and not t_counter(0);
    t9 <= t_counter(3) and not t_counter(2) and not t_counter(1) and t_counter(0);
    t10 <= t_counter(3) and not t_counter(2) and t_counter(1) and not t_counter(0);
    t11 <= t_counter(3) and not t_counter(2) and t_counter(1) and t_counter(0);
    t12 <= t_counter(3) and t_counter(2) and not t_counter(1) and not t_counter(0);
    t13 <= t_counter(3) and t_counter(2) and not t_counter(1) and t_counter(0);
    t14 <= t_counter(3) and t_counter(2) and t_counter(1) and not t_counter(0);
    t15 <= t_counter(3) and t_counter(2) and t_counter(1) and t_counter(0);

    
end rtl;