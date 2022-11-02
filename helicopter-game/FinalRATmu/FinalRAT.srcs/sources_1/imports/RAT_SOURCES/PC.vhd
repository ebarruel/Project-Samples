----------------------------------------------------------------------------------
-- Engineer: Kyle Wuerch & Chin Chao
-- 
-- Module Name: PC - Behavioral
-- Comments: This module is an high-level module designed to connect
-- the lower level components. These include: ProgramCounter, PC_MUX
-- and prog_rom.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PC is
    Port ( CLK         : in  STD_LOGIC;
           PC_INC      : in  STD_LOGIC;
           PC_LD       : in  STD_LOGIC;
           RST         : in  STD_LOGIC;
           PC_MUX_SEL  : in  STD_LOGIC_VECTOR (1 downto 0);
           FROM_IMMED  : in  STD_LOGIC_VECTOR (9 downto 0);
           FROM_STACK  : in  STD_LOGIC_VECTOR (9 downto 0);
           PC_COUNT    : out STD_LOGIC_VECTOR (9 downto 0));
end PC;

architecture Behavioral of PC is
signal MUX_OUT_sig  : STD_LOGIC_VECTOR (9 downto 0);

component ProgramCounter is
    Port ( D_IN     : in  STD_LOGIC_VECTOR(9 downto 0);
           CLK      : in  STD_LOGIC;
           PC_INC   : in  STD_LOGIC;
           PC_LD    : in  STD_LOGIC;
           RST      : in  STD_LOGIC;
           PC_COUNT : out STD_LOGIC_VECTOR(9 downto 0));
end component;

component PC_MUX is
    Port ( FROM_IMMED : in  STD_LOGIC_VECTOR (9 downto 0);
           FROM_STACK : in  STD_LOGIC_VECTOR (9 downto 0);
           MUX_SEL    : in  STD_LOGIC_VECTOR (1 downto 0);
           MUX_OUT    : out STD_LOGIC_VECTOR (9 downto 0));
end component;

begin

cnt : ProgramCounter
    Port Map(
        D_IN     => MUX_OUT_sig,
        CLK      => CLK,
        PC_INC   => PC_INC,
        PC_LD    => PC_LD,
        RST      => RST,
        PC_COUNT => PC_COUNT);

mux : PC_MUX
    Port Map(
        FROM_IMMED => FROM_IMMED,
        FROM_STACK => FROM_STACK,
        MUX_SEL    => PC_MUX_SEL,
        MUX_OUT    => MUX_OUT_sig);
        
end Behavioral;
