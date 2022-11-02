----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/12/2016 10:27:12 AM
-- Design Name: 
-- Module Name: ALU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( SEL : in STD_LOGIC_VECTOR (3 downto 0);
           A   : in STD_LOGIC_VECTOR (7 downto 0);
           B   : in STD_LOGIC_VECTOR (7 downto 0);
           CIN : in STD_LOGIC;
           C   : out STD_LOGIC;
           Z   : out STD_LOGIC;
           RESULT : out STD_LOGIC_VECTOR (7 downto 0));
end ALU;

architecture Behavioral of ALU is
signal result_sig : STD_LOGIC_VECTOR(8 downto 0);
signal a_nine_sig : STD_LOGIC_VECTOR(8 downto 0);
signal a_min_b_sig: STD_LOGIC_VECTOR(8 downto 0);
begin

muxing : process(A, B, CIN, SEL, a_nine_sig, a_min_b_sig)
begin
 case(SEL) is
    when "0000" => result_sig <= a_nine_sig + B;                        -- ADD
    when "0001" => result_sig <= a_nine_sig + B + CIN;                  -- ADDC
    when "0010" => result_sig <= a_min_b_sig;                           -- SUB
    when "0011" => result_sig <= a_min_b_sig - CIN;                     -- SUBC
    when "0100" => result_sig <= a_min_b_sig;                           -- CMP
    when "0101" => result_sig <= '0' & (A AND B);                       -- AND
    when "0110" => result_sig <= '0' & (A OR  B);                       -- OR
    when "0111" => result_sig <= '0' & (A XOR B);                       -- EXOR
    when "1000" => result_sig <= '0' & (A AND B);                       -- TEST
    when "1001" => result_sig <= A(7) & A(6 downto 0) & CIN;            -- LSL
    when "1010" => result_sig <= A(0 ) & CIN & A(7 downto 1);           -- LSR
    when "1011" => result_sig <= A(7) &  A(6 downto 0) & A(7 downto 7); -- ROL
    when "1100" => result_sig <= A(0) & A(0) & A(7 downto 1);           -- ROR
    when "1101" => result_sig <= A(0) & A(7) & A(7 downto 1);           -- ASR
    when "1110" => result_sig <= CIN & B;                               -- MOV
    when others => result_sig <= '0' & x"00";                           -- UNUSED
end case;
    
    
end process muxing;

a_nine_sig <= '0' & A;
a_min_b_sig <= a_nine_sig - B;


RESULT <= result_sig(7 downto 0);
C <= result_sig(8);

Z <= '1' when (result_sig(7 downto 0) = x"00") else -- Assign z
     '0';

end Behavioral;
