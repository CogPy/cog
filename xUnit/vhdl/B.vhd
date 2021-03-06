-------------------------------------------------------------------------------
-- Title      : B
-- Project    : 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity B is
  port (
    Clk : in std_logic;
    Clr : in std_logic;

    B_A : in std_logic_vector(3 downto 0);
    B_B : in std_logic_vector(3 downto 0);

    B_AB : out std_logic_vector(4 downto 0)
    );
end entity B;

-------------------------------------------------------------------------------

architecture str of B is

  signal Cents_A  : std_logic_vector(3 downto 0);
  signal Cents_B  : std_logic_vector(3 downto 0);
  signal Cents_AB : std_logic_vector(4 downto 0);
  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal AB : unsigned(B_AB'range);
    
begin  -- architecture str

  -----------------------------------------------------------------------------
  -- Output assignments
  -----------------------------------------------------------------------------
  B_AB <= std_logic_vector(AB);
  
  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------
  p_addAandB: process (Clk) is
  begin  -- process p_addAandB
    if Clk'event and Clk = '1' then     -- rising clock edge
      if Clr = '1' then
        AB <= to_unsigned(0, AB'length);
      else
        AB <= resize(unsigned(B_A), AB'length) + resize(unsigned(B_B), AB'length);
      end if;
    end if;
  end process p_addAandB;

  i_Cents_1: entity work.Cents
    port map (
      Clk      => Clk,
      Clr      => Clr,
      Cents_A  => Cents_A,
      Cents_B  => Cents_B,
      Cents_AB => Cents_AB);
  
end architecture str;

-------------------------------------------------------------------------------
