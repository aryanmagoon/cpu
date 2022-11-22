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
-- CREATED		"Sun May  1 00:23:38 2022"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY datapath IS 
	PORT
	(
		reset :  IN  STD_LOGIC;
		clock :  IN  STD_LOGIC;
		pcout :  IN  STD_LOGIC;
		pcin :  IN  STD_LOGIC;
		irin :  IN  STD_LOGIC;
		rin :  IN  STD_LOGIC;
		rout :  IN  STD_LOGIC;
		baout :  IN  STD_LOGIC;
		gra :  IN  STD_LOGIC;
		grb :  IN  STD_LOGIC;
		grc :  IN  STD_LOGIC;
		c1out :  IN  STD_LOGIC;
		c2out :  IN  STD_LOGIC;
		cin :  IN  STD_LOGIC;
		cout :  IN  STD_LOGIC;
		ain :  IN  STD_LOGIC;
		incr4_op :  IN  STD_LOGIC;
		add_op :  IN  STD_LOGIC;
		sub_op :  IN  STD_LOGIC;
		neg_op :  IN  STD_LOGIC;
		and_op :  IN  STD_LOGIC;
		or_op :  IN  STD_LOGIC;
		not_op :  IN  STD_LOGIC;
		shr_op :  IN  STD_LOGIC;
		shra_op :  IN  STD_LOGIC;
		shl_op :  IN  STD_LOGIC;
		shc_op :  IN  STD_LOGIC;
		ceqb_op :  IN  STD_LOGIC;
		rfi_op :  IN  STD_LOGIC;
		iack :  IN  STD_LOGIC;
		c3_2_downto_0 :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);
		opcode :  OUT  STD_LOGIC_VECTOR(4 DOWNTO 0);
		cpu_bus :  INOUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
		
	);
END datapath;

ARCHITECTURE bdf_type OF datapath IS 

COMPONENT register_file
	PORT(Reset : IN STD_LOGIC;
		 Clock : IN STD_LOGIC;
		 Rin : IN STD_LOGIC;
		 Rout : IN STD_LOGIC;
		 BAout : IN STD_LOGIC;
		 cpu_bus : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 register_select : IN STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT instruction_register
	PORT(Reset : IN STD_LOGIC;
		 Clock : IN STD_LOGIC;
		 IRin : IN STD_LOGIC;
		 c1out : IN STD_LOGIC;
		 c2out : IN STD_LOGIC;
		 Gra : IN STD_LOGIC;
		 Grb : IN STD_LOGIC;
		 Grc : IN STD_LOGIC;
		 cpu_bus : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 c3_2_downto_0 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 opcode : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 register_select : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT program_counter
	PORT(Reset : IN STD_LOGIC;
		 Clock : IN STD_LOGIC;
		 PCin : IN STD_LOGIC;
		 PCout : IN STD_LOGIC;
		 iack : IN STD_LOGIC;
		 rfi_op : IN STD_LOGIC;
		 cpu_bus : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT alu
	PORT(Reset : IN STD_LOGIC;
		 Clock : IN STD_LOGIC;
		 Ain : IN STD_LOGIC;
		 Cin : IN STD_LOGIC;
		 Cout : IN STD_LOGIC;
		 ADD_op : IN STD_LOGIC;
		 SUB_op : IN STD_LOGIC;
		 Neg_op : IN STD_LOGIC;
		 AND_op : IN STD_LOGIC;
		 OR_op : IN STD_LOGIC;
		 Not_op : IN STD_LOGIC;
		 SHR_op : IN STD_LOGIC;
		 SHRA_op : IN STD_LOGIC;
		 SHL_op : IN STD_LOGIC;
		 SHC_op : IN STD_LOGIC;
		 CeqB_op : IN STD_LOGIC;
		 INCR4_op : IN STD_LOGIC;
		 cpu_bus : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	register_select :  STD_LOGIC_VECTOR(4 DOWNTO 0);


BEGIN 



b2v_inst : register_file
PORT MAP(Reset => reset,
		 Clock => clock,
		 Rin => rin,
		 Rout => rout,
		 BAout => baout,
		 cpu_bus => cpu_bus,
		 register_select => register_select);


b2v_inst2 : instruction_register
PORT MAP(Reset => reset,
		 Clock => clock,
		 IRin => irin,
		 c1out => c1out,
		 c2out => c2out,
		 Gra => gra,
		 Grb => grb,
		 Grc => grc,
		 cpu_bus => cpu_bus,
		 c3_2_downto_0 => c3_2_downto_0,
		 opcode => opcode,
		 register_select => register_select);


b2v_inst3 : program_counter
PORT MAP(Reset => reset,
		 Clock => clock,
		 PCin => pcin,
		 PCout => pcout,
		 iack => iack,
		 rfi_op => rfi_op,
		 cpu_bus => cpu_bus);


b2v_inst4 : alu
PORT MAP(Reset => reset,
		 Clock => clock,
		 Ain => ain,
		 Cin => cin,
		 Cout => cout,
		 ADD_op => add_op,
		 SUB_op => sub_op,
		 Neg_op => neg_op,
		 AND_op => and_op,
		 OR_op => or_op,
		 Not_op => not_op,
		 SHR_op => shr_op,
		 SHRA_op => shra_op,
		 SHL_op => shl_op,
		 SHC_op => shc_op,
		 CeqB_op => ceqb_op,
		 INCR4_op => incr4_op,
		 cpu_bus => cpu_bus);


END bdf_type;