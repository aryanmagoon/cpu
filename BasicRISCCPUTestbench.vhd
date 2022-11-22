-- Copyright (C) 2020  Intel Corporation. All rights reserved.
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
-- VERSION		"Version 20.1.1 Build 720 11/11/2020 SJ Lite Edition"
-- CREATED		"Tue Jul 06 09:43:33 2021"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY BasicRISCCPUTestbench IS 
END BasicRISCCPUTestbench;

ARCHITECTURE bdf_type OF BasicRISCCPUTestbench IS 

  COMPONENT ram_6116
    PORT(OE : IN STD_LOGIC;
         CE : IN STD_LOGIC;
         WE : IN STD_LOGIC;
         Addr : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
         Data : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0)
         );
  END COMPONENT;

  COMPONENT clock_reset_start
    PORT(		 start : OUT STD_LOGIC;
                         reset : OUT STD_LOGIC;
                         clock : OUT STD_LOGIC;
                         clock_UART : OUT STD_LOGIC
                         );
  END COMPONENT;

  COMPONENT rom_27c64
    GENERIC (filename : STRING
             );
    PORT(OE : IN STD_LOGIC;
         CE : IN STD_LOGIC;
         Addr : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
         Data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
         );
  END COMPONENT;

  COMPONENT cpu
    PORT(start : IN STD_LOGIC;
         done : IN STD_LOGIC;
         reset : IN STD_LOGIC;
         clock : IN STD_LOGIC;
         memstrobe : IN STD_LOGIC;
         ireq : IN STD_LOGIC;
         data_bus : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         r : OUT STD_LOGIC;
         w : OUT STD_LOGIC;
         iack : OUT STD_LOGIC;
         addr_bus : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
         );
  END COMPONENT;

  COMPONENT memory_bus_controller
    PORT(Clock : IN STD_LOGIC;
         Reset : IN STD_LOGIC;
         R : IN STD_LOGIC;
         W : IN STD_LOGIC;
         addr_bus : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         done : OUT STD_LOGIC;
         memstrobe : OUT STD_LOGIC;
         RAM_OE : OUT STD_LOGIC;
         RAM_CS : OUT STD_LOGIC;
         RAM_WE : OUT STD_LOGIC;
         ROM_OE : OUT STD_LOGIC;
         ROM_CS : OUT STD_LOGIC
         );
  END COMPONENT;

  COMPONENT miniuart
    PORT(ProcClk : IN STD_LOGIC;
         SysClk : IN STD_LOGIC;
         Reset : IN STD_LOGIC;
         RD : IN STD_LOGIC;
         WR : IN STD_LOGIC;
         RxD : IN STD_LOGIC;
         iack : IN STD_LOGIC;
         Addr_Bus : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         Data_Bus : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         Done : OUT STD_LOGIC;
         Memstrobe : OUT STD_LOGIC;
         TxD : OUT STD_LOGIC;
         IntRx_N : OUT STD_LOGIC;
         IntTx_N : OUT STD_LOGIC
         );
  END COMPONENT;

  SIGNAL	addr_bus :  STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL	data_bus :  STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL	done :  STD_LOGIC;
  SIGNAL	iack :  STD_LOGIC;
  SIGNAL	int_RxD_n :  STD_LOGIC;
  SIGNAL	int_TxD_n :  STD_LOGIC;
  SIGNAL	ireq :  STD_LOGIC;
  SIGNAL	main_clock :  STD_LOGIC;
  SIGNAL	memstrobe :  STD_LOGIC;
  SIGNAL	r :  STD_LOGIC;
  SIGNAL	ram_cs :  STD_LOGIC;
  SIGNAL	ram_oe :  STD_LOGIC;
  SIGNAL	ram_we :  STD_LOGIC;
  SIGNAL	reset :  STD_LOGIC;
  SIGNAL	rom_ce :  STD_LOGIC;
  SIGNAL	rom_oe :  STD_LOGIC;
  SIGNAL	start :  STD_LOGIC;
  SIGNAL	TxD2RxDWire :  STD_LOGIC;
  SIGNAL	UARTClock :  STD_LOGIC;
  SIGNAL	w :  STD_LOGIC;


BEGIN 



  ireq <= int_TxD_n AND int_RxD_n;


  b2v_ram0 : ram_6116
    PORT MAP(
      OE => ram_oe,
      CE => ram_cs,
      WE => ram_we,
      Addr => addr_bus(12 DOWNTO 2),
      Data => data_bus(7 DOWNTO 0)
      );


  b2v_ram1 : ram_6116
    PORT MAP(
      OE => ram_oe,
      CE => ram_cs,
      WE => ram_we,
      Addr => addr_bus(12 DOWNTO 2),
      Data => data_bus(15 DOWNTO 8)
      );


  b2v_ram2 : ram_6116
    PORT MAP(
      OE => ram_oe,
      CE => ram_cs,
      WE => ram_we,
      Addr => addr_bus(12 DOWNTO 2),
      Data => data_bus(23 DOWNTO 16)
      );


  b2v_ram3 : ram_6116
    PORT MAP(
      OE => ram_oe,
      CE => ram_cs,
      WE => ram_we,
      Addr => addr_bus(12 DOWNTO 2),
      Data => data_bus(31 DOWNTO 24)
      );


  b2v_ResetStartClock : clock_reset_start
    PORT MAP(
      start => start,
      reset => reset,
      clock => main_clock,
      clock_UART => UARTClock
      );


  b2v_rom0 : rom_27c64
    GENERIC MAP(filename => "programs/byte0_romfile")
    PORT MAP(
      OE => rom_oe,
      CE => rom_ce,
      Addr => addr_bus(14 DOWNTO 2),
      Data => data_bus(7 DOWNTO 0)
      );


  b2v_rom1 : rom_27c64
    GENERIC MAP(filename => "programs/byte1_romfile")
    PORT MAP(
      OE => rom_oe,
      CE => rom_ce,
      Addr => addr_bus(14 DOWNTO 2),
      Data => data_bus(15 DOWNTO 8)
      );


  b2v_rom2 : rom_27c64
    GENERIC MAP(filename => "programs/byte2_romfile")
    PORT MAP(
      OE => rom_oe,
      CE => rom_ce,
      Addr => addr_bus(14 DOWNTO 2),
      Data => data_bus(23 DOWNTO 16)
      );


  b2v_rom3 : rom_27c64
    GENERIC MAP(filename => "programs/byte3_romfile")
    PORT MAP(
      OE => rom_oe,
      CE => rom_ce,
      Addr => addr_bus(14 DOWNTO 2),
      Data => data_bus(31 DOWNTO 24)
      );


  b2v_BasicRISCCPU : cpu
    PORT MAP(
      start => start,
      done => done,
      reset => reset,
      clock => main_clock,
      memstrobe => memstrobe,
      ireq => ireq,
      data_bus => data_bus,
      r => r,
      w => w,
      iack => iack,
      addr_bus => addr_bus
      );


  b2v_SystemMemoryBusController : memory_bus_controller
    PORT MAP(
      Clock => main_clock,
      Reset => reset,
      R => r,
      W => w,
      addr_bus => addr_bus,
      done => done,
      memstrobe => memstrobe,
      RAM_OE => ram_oe,
      RAM_CS => ram_cs,
      RAM_WE => ram_we,
      ROM_OE => rom_oe,
      ROM_CS => rom_ce
      );


  b2v_SystemUART : miniuart
    PORT MAP(
      ProcClk => main_clock,
      SysClk => UARTClock,
      Reset => reset,
      RD => r,
      WR => w,
      RxD => TxD2RxDWire,
      iack => iack,
      Addr_Bus => addr_bus,
      Data_Bus => data_bus,
      Done => done,
      Memstrobe => memstrobe,
      TxD => TxD2RxDWire,
      IntRx_N => int_RxD_n,
      IntTx_N => int_TxD_n
      );


END bdf_type;