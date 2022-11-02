----------------------------------------------------------------------------------
-- Module Name: Stack Pointer
-- Engineer: Kyle Wuerch & Chin Chao
-- Comments: This module is designed to store the address of the
--           element on the stack
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SP is
    Port ( RST : in STD_LOGIC;
           SP_LD : in STD_LOGIC;
           SP_INCR : in STD_LOGIC;
           SP_DECR : in STD_LOGIC;
           DATA_IN : in STD_LOGIC_VECTOR (7 downto 0);
           CLK : in STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0));
end SP;

architecture Behavioral of SP is

signal sp_sig : STD_LOGIC_VECTOR(7 downto 0) := x"00";

begin

counter: process(clk, RST)
begin
    if(RISING_EDGE(clk)) then
        if (RST = '1') then sp_sig <= x"00";
        elsif (SP_LD = '1') then sp_sig <= DATA_IN;
        elsif (SP_INCR = '1') then sp_sig <= sp_sig + 1;
        elsif (SP_DECR = '1') then sp_sig <= sp_sig - 1;
        end if;
    end if;
end process counter;

DATA_OUT <= sp_sig;

end Behavioral;
