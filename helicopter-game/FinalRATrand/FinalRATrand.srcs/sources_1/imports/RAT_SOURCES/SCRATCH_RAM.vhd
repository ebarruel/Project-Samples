----------------------------------------------------------------------------------: 
-- Engineer: Kyle Wuerch & Chin Chao
-- 
-- Module Name: SCRATCH_RAM
-- Additional Comments: This module is designed to
-- work as temporary storage for calculations by the
-- RAT MCU
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SCRATCH_RAM is
    Port ( CLK   : IN  STD_LOGIC;
           WE    : IN  STD_LOGIC;
           ADDR  : IN  STD_LOGIC_VECTOR(7 downto 0);
           DATA_IN  : IN  STD_LOGIC_VECTOR(9 downto 0);
           DATA_OUT : OUT STD_LOGIC_VECTOR(9 downto 0));
end SCRATCH_RAM;

architecture Behavioral of SCRATCH_RAM is
    TYPE MEM is array (0 to 255) of std_logic_vector(9 downto 0);
    SIGNAL REG: MEM := (others=>(others=>'0'));
begin

    read_write : process(CLK)
    begin
        if(RISING_EDGE(CLK)) then
            if(WE = '1') then
                REG(CONV_INTEGER(ADDR)) <= DATA_IN;
            else 
            end if;
        end if;
    end process read_write;
    
    DATA_OUT <= REG(CONV_INTEGER(ADDR));
end Behavioral;
