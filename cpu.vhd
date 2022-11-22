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
-- CREATED		"Sun May  1 01:12:41 2022"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY cpu IS 
	PORT
	(
		clock :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		done :  IN  STD_LOGIC;
		start :  IN  STD_LOGIC;
		memstrobe :  IN  STD_LOGIC;
		ireq :  IN  STD_LOGIC;
		data_bus :  INOUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		r :  OUT  STD_LOGIC;
		w :  OUT  STD_LOGIC;
		iack :  OUT  STD_LOGIC;
		addr_bus :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END cpu;

ARCHITECTURE bdf_type OF cpu IS 

COMPONENT memory_interface
	PORT(Reset : IN STD_LOGIC;
		 Clock : IN STD_LOGIC;
		 memstrobe : IN STD_LOGIC;
		 MAin : IN STD_LOGIC;
		 MDwr : IN STD_LOGIC;
		 MDbus : IN STD_LOGIC;
		 MDrd : IN STD_LOGIC;
		 MDout : IN STD_LOGIC;
		 cpu_bus : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Data_Bus : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Addr_Bus : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT control_unit
	PORT(start : IN STD_LOGIC;
		 done : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 ireq : IN STD_LOGIC;
		 c3_2_downto_0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 cpu_bus : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 r_memory : OUT STD_LOGIC;
		 w_memory : OUT STD_LOGIC;
		 main : OUT STD_LOGIC;
		 mdwr : OUT STD_LOGIC;
		 mdbus : OUT STD_LOGIC;
		 mdrd : OUT STD_LOGIC;
		 mdout : OUT STD_LOGIC;
		 pcout : OUT STD_LOGIC;
		 pcin : OUT STD_LOGIC;
		 irin : OUT STD_LOGIC;
		 rin : OUT STD_LOGIC;
		 rout : OUT STD_LOGIC;
		 baout : OUT STD_LOGIC;
		 gra : OUT STD_LOGIC;
		 grb : OUT STD_LOGIC;
		 grc : OUT STD_LOGIC;
		 c1out : OUT STD_LOGIC;
		 c2out : OUT STD_LOGIC;
		 cin : OUT STD_LOGIC;
		 cout : OUT STD_LOGIC;
		 ain : OUT STD_LOGIC;
		 incr4_op : OUT STD_LOGIC;
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
		 rfi_op : OUT STD_LOGIC;
		 iack : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT datapath
	PORT(reset : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 pcout : IN STD_LOGIC;
		 pcin : IN STD_LOGIC;
		 irin : IN STD_LOGIC;
		 rin : IN STD_LOGIC;
		 rout : IN STD_LOGIC;
		 baout : IN STD_LOGIC;
		 gra : IN STD_LOGIC;
		 grb : IN STD_LOGIC;
		 grc : IN STD_LOGIC;
		 c1out : IN STD_LOGIC;
		 c2out : IN STD_LOGIC;
		 cin : IN STD_LOGIC;
		 cout : IN STD_LOGIC;
		 ain : IN STD_LOGIC;
		 incr4_op : IN STD_LOGIC;
		 add_op : IN STD_LOGIC;
		 sub_op : IN STD_LOGIC;
		 neg_op : IN STD_LOGIC;
		 and_op : IN STD_LOGIC;
		 or_op : IN STD_LOGIC;
		 not_op : IN STD_LOGIC;
		 shr_op : IN STD_LOGIC;
		 shra_op : IN STD_LOGIC;
		 shl_op : IN STD_LOGIC;
		 shc_op : IN STD_LOGIC;
		 ceqb_op : IN STD_LOGIC;
		 rfi_op : IN STD_LOGIC;
		 iack : IN STD_LOGIC;
		 cpu_bus : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 c3_2_downto_0 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 opcode : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	gdfx_temp0 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
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
SIGNAL	SYNTHESIZED_WIRE_22 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_23 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_24 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_25 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_26 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_27 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_28 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_29 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_30 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_31 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_32 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_33 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_34 :  STD_LOGIC;


BEGIN 
iack <= SYNTHESIZED_WIRE_34;



b2v_inst : memory_interface
PORT MAP(Reset => reset,
		 Clock => clock,
		 memstrobe => memstrobe,
		 MAin => SYNTHESIZED_WIRE_0,
		 MDwr => SYNTHESIZED_WIRE_1,
		 MDbus => SYNTHESIZED_WIRE_2,
		 MDrd => SYNTHESIZED_WIRE_3,
		 MDout => SYNTHESIZED_WIRE_4,
		 cpu_bus => gdfx_temp0,
		 Data_Bus => data_bus,
		 Addr_Bus => addr_bus);


b2v_inst5 : control_unit
PORT MAP(start => start,
		 done => done,
		 reset => reset,
		 clock => clock,
		 ireq => ireq,
		 c3_2_downto_0 => SYNTHESIZED_WIRE_5,
		 cpu_bus => gdfx_temp0,
		 opcode => SYNTHESIZED_WIRE_6,
		 r_memory => r,
		 w_memory => w,
		 main => SYNTHESIZED_WIRE_0,
		 mdwr => SYNTHESIZED_WIRE_1,
		 mdbus => SYNTHESIZED_WIRE_2,
		 mdrd => SYNTHESIZED_WIRE_3,
		 mdout => SYNTHESIZED_WIRE_4,
		 pcout => SYNTHESIZED_WIRE_7,
		 pcin => SYNTHESIZED_WIRE_8,
		 irin => SYNTHESIZED_WIRE_9,
		 rin => SYNTHESIZED_WIRE_10,
		 rout => SYNTHESIZED_WIRE_11,
		 baout => SYNTHESIZED_WIRE_12,
		 gra => SYNTHESIZED_WIRE_13,
		 grb => SYNTHESIZED_WIRE_14,
		 grc => SYNTHESIZED_WIRE_15,
		 c1out => SYNTHESIZED_WIRE_16,
		 c2out => SYNTHESIZED_WIRE_17,
		 cin => SYNTHESIZED_WIRE_18,
		 cout => SYNTHESIZED_WIRE_19,
		 ain => SYNTHESIZED_WIRE_20,
		 incr4_op => SYNTHESIZED_WIRE_21,
		 add_op => SYNTHESIZED_WIRE_22,
		 sub_op => SYNTHESIZED_WIRE_23,
		 neg_op => SYNTHESIZED_WIRE_24,
		 and_op => SYNTHESIZED_WIRE_25,
		 or_op => SYNTHESIZED_WIRE_26,
		 not_op => SYNTHESIZED_WIRE_27,
		 shr_op => SYNTHESIZED_WIRE_28,
		 shra_op => SYNTHESIZED_WIRE_29,
		 shl_op => SYNTHESIZED_WIRE_30,
		 shc_op => SYNTHESIZED_WIRE_31,
		 ceqb_op => SYNTHESIZED_WIRE_32,
		 rfi_op => SYNTHESIZED_WIRE_33,
		 iack => SYNTHESIZED_WIRE_34);


b2v_inst6 : datapath
PORT MAP(reset => reset,
		 clock => clock,
		 pcout => SYNTHESIZED_WIRE_7,
		 pcin => SYNTHESIZED_WIRE_8,
		 irin => SYNTHESIZED_WIRE_9,
		 rin => SYNTHESIZED_WIRE_10,
		 rout => SYNTHESIZED_WIRE_11,
		 baout => SYNTHESIZED_WIRE_12,
		 gra => SYNTHESIZED_WIRE_13,
		 grb => SYNTHESIZED_WIRE_14,
		 grc => SYNTHESIZED_WIRE_15,
		 c1out => SYNTHESIZED_WIRE_16,
		 c2out => SYNTHESIZED_WIRE_17,
		 cin => SYNTHESIZED_WIRE_18,
		 cout => SYNTHESIZED_WIRE_19,
		 ain => SYNTHESIZED_WIRE_20,
		 incr4_op => SYNTHESIZED_WIRE_21,
		 add_op => SYNTHESIZED_WIRE_22,
		 sub_op => SYNTHESIZED_WIRE_23,
		 neg_op => SYNTHESIZED_WIRE_24,
		 and_op => SYNTHESIZED_WIRE_25,
		 or_op => SYNTHESIZED_WIRE_26,
		 not_op => SYNTHESIZED_WIRE_27,
		 shr_op => SYNTHESIZED_WIRE_28,
		 shra_op => SYNTHESIZED_WIRE_29,
		 shl_op => SYNTHESIZED_WIRE_30,
		 shc_op => SYNTHESIZED_WIRE_31,
		 ceqb_op => SYNTHESIZED_WIRE_32,
		 rfi_op => SYNTHESIZED_WIRE_33,
		 iack => SYNTHESIZED_WIRE_34,
		 cpu_bus => gdfx_temp0,
		 c3_2_downto_0 => SYNTHESIZED_WIRE_5,
		 opcode => SYNTHESIZED_WIRE_6);


END bdf_type;