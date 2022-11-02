
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Flags is
    Port ( CLK         : in STD_LOGIC;
           FLG_C_SET   : in STD_LOGIC;
           FLG_C_CLR   : in STD_LOGIC;
           FLG_C_LD    : in STD_LOGIC;
           FLG_Z_LD    : in STD_LOGIC;
           FLG_LD_SEL  : in STD_LOGIC;
           FLG_SHAD_LD : in STD_LOGIC;
           C           : in STD_LOGIC;
           Z           : in STD_LOGIC;
           C_FLAG      : out STD_LOGIC;
           Z_FLAG      : out STD_LOGIC);
end Flags;

architecture Behavioral of Flags is
component FlagReg
    Port ( IN_FLAG  : in  STD_LOGIC; --flag input
           LD       : in  STD_LOGIC; --load the out_flag with the in_flag value
           SET      : in  STD_LOGIC; --set the flag to '1'
           CLR      : in  STD_LOGIC; --clear the flag to '0'
           CLK      : in  STD_LOGIC; --system clock
           OUT_FLAG : out  STD_LOGIC);
end component FlagReg;

signal s_z_out : STD_LOGIC;
signal s_z_in  : STD_LOGIC;

signal s_c_out : STD_LOGIC;
signal s_c_in  : STD_LOGIC;

signal s_shad_c_out : STD_LOGIC;
signal s_shad_z_out : STD_LOGIC;


begin
Z_REG : FlagReg
    port map(
        IN_FLAG  => s_z_in,
        LD       => FLG_Z_LD,
        SET      => '0',
        CLR      => '0',
        CLK      => CLK,
        OUT_FLAG => s_z_out);
        
C_REG : FlagReg
    port map(
        IN_FLAG  => s_c_in,
        LD       => FLG_C_LD,
        SET      => FLG_C_SET,
        CLR      => FLG_C_CLR,
        CLK      => CLK,
        OUT_FLAG => s_c_out);
        
SHAD_Z : FlagReg
    port map(
        IN_FLAG  => s_z_out,
        LD       => FLG_SHAD_LD,
        SET      => '0',
        CLR      => '0',
        CLK      => CLK,
        OUT_FLAG => s_shad_z_out);
        
SHAD_C : FlagReg
    port map(
        IN_FLAG  => s_c_out,
        LD       => FLG_SHAD_LD,
        SET      => '0',
        CLR      => '0',
        CLK      => CLK,
        OUT_FLAG => s_shad_c_out);
        
s_c_in <= C when FLG_LD_SEL = '0' else
          s_shad_c_out when FLG_LD_SEL = '1' else
          '0';

s_z_in <= Z when FLG_LD_SEL = '0' else
          s_shad_z_out when FLG_LD_SEL = '1' else
          '0';
          
Z_FLAG <= s_z_out;
C_FLAG <= s_c_out;
        			
end Behavioral;

