-- Copyright (C) 2021  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 21.1.0 Build 842 10/21/2021 SJ Lite Edition"
-- CREATED		"Sun May  1 00:19:19 2022"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY control_unit IS 
	PORT
	(
		start :  IN  STD_LOGIC;
		done :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		clock :  IN  STD_LOGIC;
		opcode :  IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		c3_2_downto_0 :  IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		ireq :  IN  STD_LOGIC;
		
		cpu_bus :  INOUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		
		r_memory :  OUT  STD_LOGIC;
		w_memory :  OUT  STD_LOGIC;
		main :  OUT  STD_LOGIC;
		mdwr :  OUT  STD_LOGIC;
		mdbus :  OUT  STD_LOGIC;
		mdrd :  OUT  STD_LOGIC;
		mdout :  OUT  STD_LOGIC;
		pcout :  OUT  STD_LOGIC;
		pcin :  OUT  STD_LOGIC;
		irin :  OUT  STD_LOGIC;
		rin :  OUT  STD_LOGIC;
		rout :  OUT  STD_LOGIC;
		baout :  OUT  STD_LOGIC;
		gra :  OUT  STD_LOGIC;
		grb :  OUT  STD_LOGIC;
		grc :  OUT  STD_LOGIC;
		c1out :  OUT  STD_LOGIC;
		c2out :  OUT  STD_LOGIC;
		cin :  OUT  STD_LOGIC;
		cout :  OUT  STD_LOGIC;
		ain :  OUT  STD_LOGIC;
		incr4_op :  OUT  STD_LOGIC;
		add_op :  OUT  STD_LOGIC;
		sub_op :  OUT  STD_LOGIC;
		neg_op :  OUT  STD_LOGIC;
		and_op :  OUT  STD_LOGIC;
		or_op :  OUT  STD_LOGIC;
		not_op :  OUT  STD_LOGIC;
		shr_op :  OUT  STD_LOGIC;
		shra_op :  OUT  STD_LOGIC;
		shl_op :  OUT  STD_LOGIC;
		shc_op :  OUT  STD_LOGIC;
		ceqb_op :  OUT  STD_LOGIC;
		rfi_op :  OUT  STD_LOGIC;
		iack :  OUT  STD_LOGIC
	);
END control_unit;

ARCHITECTURE bdf_type OF control_unit IS 

COMPONENT sequencer
	PORT(Reset : IN STD_LOGIC;
		 Clock : IN STD_LOGIC;
		 Start : IN STD_LOGIC;
		 Done : IN STD_LOGIC;
		 End_sig : IN STD_LOGIC;
		 Goto6 : IN STD_LOGIC;
		 Read_control : IN STD_LOGIC;
		 Write_control : IN STD_LOGIC;
		 Wait_sig : IN STD_LOGIC;
		 Stop_sig : IN STD_LOGIC;
		 rfi_sig : IN STD_LOGIC;
		 een_sig : IN STD_LOGIC;
		 edi_sig : IN STD_LOGIC;
		 ireq : IN STD_LOGIC;
		 t0 : OUT STD_LOGIC;
		 t1 : OUT STD_LOGIC;
		 t2 : OUT STD_LOGIC;
		 t3 : OUT STD_LOGIC;
		 t4 : OUT STD_LOGIC;
		 t5 : OUT STD_LOGIC;
		 t6 : OUT STD_LOGIC;
		 t7 : OUT STD_LOGIC;
		 t8 : OUT STD_LOGIC;
		 t9 : OUT STD_LOGIC;
		 t10 : OUT STD_LOGIC;
		 t11 : OUT STD_LOGIC;
		 t12 : OUT STD_LOGIC;
		 t13 : OUT STD_LOGIC;
		 t14 : OUT STD_LOGIC;
		 t15 : OUT STD_LOGIC;
		 r_sequencer : OUT STD_LOGIC;
		 w_sequencer : OUT STD_LOGIC;
		 iack : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT shift_control
	PORT(Reset : IN STD_LOGIC;
		 Clock : IN STD_LOGIC;
		 ld_shift : IN STD_LOGIC;
		 decr : IN STD_LOGIC;
		 cpu_bus : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Neq0 : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT con_logic
	PORT(Reset : IN STD_LOGIC;
		 Clock : IN STD_LOGIC;
		 CONin : IN STD_LOGIC;
		 c3_2_downto_0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 cpu_bus : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 CON : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT control_signals_logic
	PORT(t0 : IN STD_LOGIC;
		 t1 : IN STD_LOGIC;
		 t2 : IN STD_LOGIC;
		 t3 : IN STD_LOGIC;
		 t4 : IN STD_LOGIC;
		 t5 : IN STD_LOGIC;
		 t6 : IN STD_LOGIC;
		 t7 : IN STD_LOGIC;
		 t8 : IN STD_LOGIC;
		 t9 : IN STD_LOGIC;
		 t10 : IN STD_LOGIC;
		 t11 : IN STD_LOGIC;
		 t12 : IN STD_LOGIC;
		 t13 : IN STD_LOGIC;
		 t14 : IN STD_LOGIC;
		 t15 : IN STD_LOGIC;
		 neq0 : IN STD_LOGIC;
		 con : IN STD_LOGIC;
		 iack : IN STD_LOGIC;
		 opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 irin : OUT STD_LOGIC;
		 c1out : OUT STD_LOGIC;
		 c2out : OUT STD_LOGIC;
		 gra : OUT STD_LOGIC;
		 grb : OUT STD_LOGIC;
		 grc : OUT STD_LOGIC;
		 main : OUT STD_LOGIC;
		 mdbus : OUT STD_LOGIC;
		 mdrd : OUT STD_LOGIC;
		 mdout : OUT STD_LOGIC;
		 pcin : OUT STD_LOGIC;
		 pcout : OUT STD_LOGIC;
		 ain : OUT STD_LOGIC;
		 cin : OUT STD_LOGIC;
		 cout : OUT STD_LOGIC;
		 add_op : OUT STD_LOGIC;
		 sub_op : OUT STD_LOGIC;
		 neg_op : OUT STD_LOGIC;
		 and_op : OUT STD_LOGIC;
		 or_op : OUT STD_LOGIC;
		 not_op : OUT STD_LOGIC;
		 shr_op : OUT STD_LOGIC;
		 shra_op : OUT STD_LOGIC;
		 shl_op : OUT STD_LOGIC;
		 shc_op : OUT STD_LOGIC;
		 ceqb_op : OUT STD_LOGIC;
		 incr4_op : OUT STD_LOGIC;
		 rfi_op : OUT STD_LOGIC;
		 baout : OUT STD_LOGIC;
		 rin : OUT STD_LOGIC;
		 rout : OUT STD_LOGIC;
		 end_sig : OUT STD_LOGIC;
		 stop_sig : OUT STD_LOGIC;
		 read_control : OUT STD_LOGIC;
		 write_control : OUT STD_LOGIC;
		 wait_sig : OUT STD_LOGIC;
		 goto6 : OUT STD_LOGIC;
		 rfi_sig : OUT STD_LOGIC;
		 een_sig : OUT STD_LOGIC;
		 edi_sig : OUT STD_LOGIC;
		 conin : OUT STD_LOGIC;
		 ld_shift : OUT STD_LOGIC;
		 decr : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	con :  STD_LOGIC;
SIGNAL	iack_ALTERA_SYNTHESIZED :  STD_LOGIC;
SIGNAL	neq0 :  STD_LOGIC;
SIGNAL	t0 :  STD_LOGIC;
SIGNAL	t1 :  STD_LOGIC;
SIGNAL	t2 :  STD_LOGIC;
SIGNAL	t3 :  STD_LOGIC;
SIGNAL	t4 :  STD_LOGIC;
SIGNAL	t5 :  STD_LOGIC;
SIGNAL	t6 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_19 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_21 :  STD_LOGIC;


BEGIN 
w_memory <= SYNTHESIZED_WIRE_21;
mdwr <= SYNTHESIZED_WIRE_21;



b2v_inst : sequencer
PORT MAP(Reset => reset,
		 Clock => clock,
		 Start => start,
		 Done => done,
		 End_sig => SYNTHESIZED_WIRE_0,
		 Goto6 => SYNTHESIZED_WIRE_1,
		 Read_control => SYNTHESIZED_WIRE_2,
		 Write_control => SYNTHESIZED_WIRE_3,
		 Wait_sig => SYNTHESIZED_WIRE_4,
		 Stop_sig => SYNTHESIZED_WIRE_5,
		 rfi_sig => SYNTHESIZED_WIRE_6,
		 een_sig => SYNTHESIZED_WIRE_7,
		 edi_sig => SYNTHESIZED_WIRE_8,
		 ireq => ireq,
		 t0 => t0,
		 t1 => t1,
		 t2 => t2,
		 t3 => t3,
		 t4 => t4,
		 t5 => t5,
		 t6 => t6,
		 t7 => SYNTHESIZED_WIRE_12,
		 t8 => SYNTHESIZED_WIRE_13,
		 t9 => SYNTHESIZED_WIRE_14,
		 t10 => SYNTHESIZED_WIRE_15,
		 t11 => SYNTHESIZED_WIRE_16,
		 t12 => SYNTHESIZED_WIRE_17,
		 t13 => SYNTHESIZED_WIRE_18,
		 t14 => SYNTHESIZED_WIRE_19,
		 t15 => SYNTHESIZED_WIRE_20,
		 r_sequencer => r_memory,
		 w_sequencer => SYNTHESIZED_WIRE_21,
		 iack => iack_ALTERA_SYNTHESIZED);


b2v_inst2 : shift_control
PORT MAP(Reset => reset,
		 Clock => clock,
		 ld_shift => SYNTHESIZED_WIRE_9,
		 decr => SYNTHESIZED_WIRE_10,
		 cpu_bus => cpu_bus,
		 Neq0 => neq0);


b2v_inst3 : con_logic
PORT MAP(Reset => reset,
		 Clock => clock,
		 CONin => SYNTHESIZED_WIRE_11,
		 c3_2_downto_0 => c3_2_downto_0,
		 cpu_bus => cpu_bus,
		 CON => con);


b2v_inst4 : control_signals_logic
PORT MAP(t0 => t0,
		 t1 => t1,
		 t2 => t2,
		 t3 => t3,
		 t4 => t4,
		 t5 => t5,
		 t6 => t6,
		 t7 => SYNTHESIZED_WIRE_12,
		 t8 => SYNTHESIZED_WIRE_13,
		 t9 => SYNTHESIZED_WIRE_14,
		 t10 => SYNTHESIZED_WIRE_15,
		 t11 => SYNTHESIZED_WIRE_16,
		 t12 => SYNTHESIZED_WIRE_17,
		 t13 => SYNTHESIZED_WIRE_18,
		 t14 => SYNTHESIZED_WIRE_19,
		 t15 => SYNTHESIZED_WIRE_20,
		 neq0 => neq0,
		 con => con,
		 iack => iack_ALTERA_SYNTHESIZED,
		 opcode => opcode,
		 irin => irin,
		 c1out => c1out,
		 c2out => c2out,
		 gra => gra,
		 grb => grb,
		 grc => grc,
		 main => main,
		 mdbus => mdbus,
		 mdrd => mdrd,
		 mdout => mdout,
		 pcin => pcin,
		 pcout => pcout,
		 ain => ain,
		 cin => cin,
		 cout => cout,
		 add_op => add_op,
		 sub_op => sub_op,
		 neg_op => neg_op,
		 and_op => and_op,
		 or_op => or_op,
		 not_op => not_op,
		 shr_op => shr_op,
		 shra_op => shra_op,
		 shl_op => shl_op,
		 shc_op => shc_op,
		 ceqb_op => ceqb_op,
		 incr4_op => incr4_op,
		 rfi_op => rfi_op,
		 baout => baout,
		 rin => rin,
		 rout => rout,
		 end_sig => SYNTHESIZED_WIRE_0,
		 stop_sig => SYNTHESIZED_WIRE_5,
		 read_control => SYNTHESIZED_WIRE_2,
		 write_control => SYNTHESIZED_WIRE_3,
		 wait_sig => SYNTHESIZED_WIRE_4,
		 goto6 => SYNTHESIZED_WIRE_1,
		 rfi_sig => SYNTHESIZED_WIRE_6,
		 een_sig => SYNTHESIZED_WIRE_7,
		 edi_sig => SYNTHESIZED_WIRE_8,
		 conin => SYNTHESIZED_WIRE_11,
		 ld_shift => SYNTHESIZED_WIRE_9,
		 decr => SYNTHESIZED_WIRE_10);

iack <= iack_ALTERA_SYNTHESIZED;

END bdf_type;