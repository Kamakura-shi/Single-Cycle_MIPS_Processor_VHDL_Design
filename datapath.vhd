-- filepath: h:\ELE344\lab2\src\datapath.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Datapath is
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        Instruction: in  std_logic_vector(31 downto 0);
        ReadData   : in  std_logic_vector(31 downto 0);
        RegDst     : in  std_logic;
        Jump       : in  std_logic;
        Branch     : in  std_logic;
        MemtoReg   : in  std_logic;
        AluSrc     : in  std_logic;
        RegWrite   : in  std_logic;
        MemReadIn  : in  std_logic;
        MemWriteIn : in  std_logic;
        AluControl : in  std_logic_vector(3 downto 0);
        PC         : out std_logic_vector(31 downto 0);
        WriteData  : out std_logic_vector(31 downto 0);
        AluResult  : out std_logic_vector(31 downto 0);
        MemReadOut : out std_logic;
        MemWriteOut: out std_logic
    );
end entity;

architecture rtl of Datapath is
    -- Internal signals
    signal PC_reg        : std_logic_vector(31 downto 0);
    signal AluResult_reg : std_logic_vector(31 downto 0);
    signal Zero          : std_logic;
    signal PCNext, PCPlus4, PCBranch, PCJump : std_logic_vector(31 downto 0);
    signal SignImm, SignImmSh : std_logic_vector(31 downto 0);
    signal RegWriteData, Result : std_logic_vector(31 downto 0);
    signal SrcA, SrcB : std_logic_vector(31 downto 0);
    signal WriteReg : std_logic_vector(4 downto 0);
    signal RegDst_mux : std_logic_vector(4 downto 0);
    signal RegFile_rd1, RegFile_rd2 : std_logic_vector(31 downto 0);

begin
    -- Sign extension
    SignImm <= std_logic_vector(resize(signed(Instruction(15 downto 0)), 32));

    -- PC logic
    PCPlus4 <= std_logic_vector(unsigned(PC_reg) + 4);
    PCBranch <= std_logic_vector(unsigned(PCPlus4) + unsigned(SignImmSh));
    PCJump <= PCPlus4(31 downto 28) & Instruction(25 downto 0) & "00";

    -- PCSrc mux
    PCNext <= PCBranch when (Branch = '1' and Zero = '1') else PCPlus4;
    -- Jump mux
    PC <= PC_reg when Jump = '1' else PCNext;

    -- PC register
    process(clk, reset)
    begin
        if reset = '1' then
            PC_reg <= (others => '0');
        elsif rising_edge(clk) then
            PC_reg <= PCNext;
        end if;
    end process;

    -- Register destination mux
    RegDst_mux <= Instruction(15 downto 11) when RegDst = '1' else Instruction(20 downto 16);

    -- Register file instance
    regfile_inst: entity work.regfile
        port map (
            clk => clk,
            we  => RegWrite,
            ra1 => Instruction(25 downto 21),
            ra2 => Instruction(20 downto 16),
            wa  => RegDst_mux,
            wd  => RegWriteData,
            rd1 => RegFile_rd1,
            rd2 => RegFile_rd2
        );

    -- ALU source mux
    SrcB <= SignImm when AluSrc = '1' else RegFile_rd2;

    -- ALU instantiation (match your ALU entity)
    ALU_inst: entity work.ALU
        generic map (
            N => 32
        )
        port map (
            ualControl => AluControl,      -- Control signal from controller
            srcA       => RegFile_rd1,     -- First ALU input
            srcB       => SrcB,            -- Second ALU input
            result     => AluResult_reg,   -- Internal result signal
            cout       => open,            -- Carry out (unused)
            zero       => Zero             -- Zero flag
        );

    -- WriteData output
    WriteData <= RegFile_rd2;

    -- MemtoReg mux
    Result <= ReadData when MemtoReg = '1' else AluResult_reg;

    -- Write-back data
    RegWriteData <= Result;

    -- Outputs for memory
    MemReadOut  <= MemReadIn;
    MemWriteOut <= MemWriteIn;

    -- Final output assignments
    PC <= PC_reg;
    AluResult <= AluResult_reg;

end architecture;