-- filepath: h:\ELE344\lab2\src\controller_tb.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controller_tb is
end controller_tb;

architecture Behavioral of controller_tb is
    -- Component declaration
    component controller is
        port (
            OP        : in  std_logic_vector(5 downto 0);
            Funct     : in  std_logic_vector(5 downto 0);
            MemtoReg  : out std_logic;
            MemWrite  : out std_logic;
            MemRead   : out std_logic;
            Branch    : out std_logic;
            AluSrc    : out std_logic;
            RegDst    : out std_logic;
            RegWrite  : out std_logic;
            Jump      : out std_logic;
            AluControl: out std_logic_vector(3 downto 0)
        );
    end component;

    -- Signals for connecting to the controller
    signal OP        : std_logic_vector(5 downto 0) := (others => '0');
    signal Funct     : std_logic_vector(5 downto 0) := (others => '0');
    signal OPtype    : string(1 to 3);
    signal MemtoReg  : std_logic;
    signal MemWrite  : std_logic;
    signal MemRead   : std_logic;
    signal Branch    : std_logic;
    signal AluSrc    : std_logic;
    signal RegDst    : std_logic;
    signal RegWrite  : std_logic;
    signal Jump      : std_logic;
    signal AluControl: std_logic_vector(3 downto 0);
    signal s_control : std_logic_vector(9 downto 0);

    constant R_TYPE_CONTROL : std_logic_vector(9 downto 0) := "1100000100";
    constant LW_CONTROL     : std_logic_vector(9 downto 0) := "1010101000";
    constant SW_CONTROL     : std_logic_vector(9 downto 0) := "0-1001-000";
    constant BEQ_CONTROL    : std_logic_vector(9 downto 0) := "0-0100-010";
    constant ADDI_CONTROL   : std_logic_vector(9 downto 0) := "1010000000";
    constant J_CONTROL      : std_logic_vector(9 downto 0) := "0---00---1";
    constant DEFAULT_CONTROL: std_logic_vector(9 downto 0) := "0000000000";

begin
    uut: controller
        port map (
            OP        => OP,
            Funct     => Funct,
            MemtoReg  => MemtoReg,
            MemWrite  => MemWrite,
            MemRead   => MemRead,
            Branch    => Branch,
            AluSrc    => AluSrc,
            RegDst    => RegDst,
            RegWrite  => RegWrite,
            Jump      => Jump,
            AluControl=> AluControl
        );

    -- Add this process after your signal declarations and before your main test process
    process(AluControl)
    begin
        case AluControl is
            when "0000" => OPtype <= "AND";
            when "0001" => OPtype <= "OR ";
            when "0010" => OPtype <= "ADD";
            when "0110" => OPtype <= "SUB";
            when "0111" => OPtype <= "SLT";
            when others => OPtype <= "---";
        end case;
    end process;

    process(OP)
    begin
        case OP is
            when "000000" => s_control <= R_TYPE_CONTROL;
            when "100011" => s_control <= LW_CONTROL;
            when "101011" => s_control <= SW_CONTROL;
            when "000100" => s_control <= BEQ_CONTROL;
            when "001000" => s_control <= ADDI_CONTROL;
            when "000010" => s_control <= J_CONTROL;
            when others   => s_control <= DEFAULT_CONTROL;
        end case;
    end process;

    stim_proc: process
    begin
        -- R-type: add
        OP    <= "000000"; Funct <= "100000";
        wait for 10 ns;
        -- R-type: sub
        OP    <= "000000"; Funct <= "100010";
        wait for 10 ns;
        -- R-type: and
        OP    <= "000000"; Funct <= "100100";
        wait for 10 ns;
        -- R-type: or
        OP    <= "000000"; Funct <= "100101";
        wait for 10 ns;
        -- R-type: slt
        OP    <= "000000"; Funct <= "101010";
        wait for 10 ns;
        -- lw
        OP    <= "100011"; Funct <= "000000";
        wait for 10 ns;
        -- sw
        OP    <= "101011"; Funct <= "000000";
        wait for 10 ns;
        -- beq
        OP    <= "000100"; Funct <= "000000";
        wait for 10 ns;
        -- addi
        OP    <= "001000"; Funct <= "000000";
        wait for 10 ns;
        -- j
        OP    <= "000010"; Funct <= "000000";
        wait for 10 ns;
        -- Stop simulation
        wait;
    end process;
end Behavioral;