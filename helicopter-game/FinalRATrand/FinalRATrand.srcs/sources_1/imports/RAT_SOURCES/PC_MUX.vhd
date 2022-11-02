----------------------------------------------------------------------------------
-- Engineer: Kyle Wuerch & Chin Chao
--
-- Module Name: PC_MUX - Behavioral
-- Comments: This module selects either its FROM_IMMED, FROM_STACK,
-- or "0x3FF" signal to output based of the given MUX_SELECT input 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PC_MUX is
    Port ( MUX_SEL    : in  STD_LOGIC_VECTOR (1 downto 0);
           FROM_IMMED : in  STD_LOGIC_VECTOR (9 downto 0);
           FROM_STACK : in  STD_LOGIC_VECTOR (9 downto 0);
           MUX_OUT    : out STD_LOGIC_VECTOR (9 downto 0));
end PC_MUX;

architecture Behavioral of PC_MUX is

begin

with MUX_SEL select
    MUX_OUT <= FROM_IMMED   when "00",
               FROM_STACK   when "01",
               "11" & x"FF" when "10",
               "00" & x"00" when others;

end Behavioral;
