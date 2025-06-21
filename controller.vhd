-- filepath: h:\ELE344\lab2\src\controller.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controller is
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
end controller;

architecture Behavioral of controller is
    -- Signal declaration for AluOp
    signal AluOp : std_logic_vector(1 downto 0);

    -- Control pattern constants (10 bits, '-' is a valid std_logic value but NOT a true don't care)
    constant R_TYPE_CONTROL : std_logic_vector(9 downto 0) := "1100000100"; -- R-Type
    constant LW_CONTROL     : std_logic_vector(9 downto 0) := "1010101000"; -- Lw
    constant SW_CONTROL     : std_logic_vector(9 downto 0) := "0-1001-000"; -- Sw
    constant BEQ_CONTROL    : std_logic_vector(9 downto 0) := "0-0100-010"; -- Beq
    constant ADDI_CONTROL   : std_logic_vector(9 downto 0) := "1010000000"; -- Addi
    constant J_CONTROL      : std_logic_vector(9 downto 0) := "0---00---1"; -- J
    constant DEFAULT_CONTROL: std_logic_vector(9 downto 0) := "0000000000"; -- default

    signal s_control : std_logic_vector(9 downto 0);

begin
    process(OP)
    begin
        case OP is
            when "000000" => s_control <= R_TYPE_CONTROL;   -- R-type
            when "100011" => s_control <= LW_CONTROL;       -- lw
            when "101011" => s_control <= SW_CONTROL;       -- sw
            when "000100" => s_control <= BEQ_CONTROL;      -- beq
            when "001000" => s_control <= ADDI_CONTROL;     -- addi
            when "000010" => s_control <= J_CONTROL;        -- j
            when others   => s_control <= DEFAULT_CONTROL;
        end case;
    end process;

    -- Assign control signals from s_control
    RegWrite  <= s_control(9);
    RegDst    <= s_control(8);
    AluSrc    <= s_control(7);
    Branch    <= s_control(6);
    MemRead   <= s_control(5);
    MemWrite  <= s_control(4);
    MemtoReg  <= s_control(3);
    AluOp     <= s_control(2 downto 1);
    Jump      <= s_control(0);

    process(ALUOp, Funct)
    begin
        case ALUOp is
            when "00" => AluControl <= "0010"; -- add (for lw/sw)
            when "01" => AluControl <= "0110"; -- sub (for beq)
            when "10" => -- R-type
                case Funct is
                    when "100000" => AluControl <= "0010"; -- add
                    when "100010" => AluControl <= "0110"; -- sub
                    when "100100" => AluControl <= "0000"; -- and
                    when "100101" => AluControl <= "0001"; -- or
                    when "101010" => AluControl <= "0111"; -- slt
                    when others   => AluControl <= "0000"; -- default to AND for unknown funct
                end case;
            when others => AluControl <= "0000"; -- default to AND for unknown ALUOp
        end case;
    end process;

end Behavioral;