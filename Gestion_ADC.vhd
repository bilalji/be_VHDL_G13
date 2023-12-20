library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Gestion_ADC is
  port (
    clk : in std_logic;
    Raz_n : in std_logic;
    Data_in : in std_logic;
    Angle_barre : out std_logic_vector(11 downto 0);
    Clk_adc : out std_logic;
    Cs_n : out std_logic
  );
end Gestion_ADC;

architecture Behavioral of Gestion_ADC is
  signal s_clk_adc : std_logic;
  signal conv_state : std_logic;
  signal start_conv : std_logic;
  signal s_data : std_logic_vector(11 downto 0);
  type State_Type is (Idle, Reading);
  signal State : State_Type;
  signal tmp: std_logic := '0';

begin
  -- Processus pour générer clk_1M
  process (clk) is
    variable cnt: integer := 0;
  begin
    if Raz_n = '0' then
      cnt := 0;
    elsif rising_edge(clk) then
      cnt := cnt + 1 ;
      if cnt = 25  then
        tmp <= not tmp;
        cnt := 0;
      end if;
    end if;

    s_clk_adc <= tmp;
  end process;

  -- Processus pour générer start_conv
  process (s_clk_adc, Raz_n)
    variable count_conv : integer range 0 to 50000;
  begin
    if Raz_n = '1' then
      count_conv := 0;
      start_conv <= '0';
    elsif rising_edge(s_clk_adc) then
      if count_conv = 50000 then
        start_conv <= '1';
        count_conv := 0;
      else
        start_conv <= '0';
        count_conv := count_conv + 1;
      end if;
    end if;
  end process;

  -- Processus pour la machine à état
  process (clk, Raz_n)
  begin
    if Raz_n = '1' then
      State <= Idle;
    elsif rising_edge(clk) then
      case State is
        when Idle =>
          if start_conv = '1' then
            State <= Reading;
          else
            State <= Idle;
          end if;
        when Reading =>
          if conv_state = '0' then
            State <= Idle;
          else
            State <= Reading;
          end if;
      end case;
    end if;
  end process;

  -- Processus pour
  -- Processus pour le comptage des fronts d'horloge
  process (s_clk_adc, Raz_n)
    variable count_fronts : integer range 0 to 14;
  begin
    if Raz_n = '1' then
      count_fronts := 0;
    elsif rising_edge(s_clk_adc) then
      if count_fronts = 14 then
        count_fronts := 0;
        conv_state <= '0';
      else
        count_fronts := count_fronts + 1;
        conv_state <= '1';
      end if;
    end if;
  end process;

  -- Processus pour le registre à décalage
  process (s_clk_adc, Raz_n)
  begin
    if Raz_n = '1' then
      s_data <= (others => '0');
    elsif rising_edge(s_clk_adc) then
      if conv_state = '1' then
        for i in s_data'high-1 downto 0 loop
          s_data(i + 1) <= s_data(i);
        end loop;
        s_data(0) <= Data_in;
      end if;
    end if;
    if conv_state = '0' then
      Angle_barre <= s_data;
    end if;
  end process;

  -- Processus pour générer le signal CS_n
  process (s_clk_adc, Raz_n)
  begin
    if Raz_n = '1' then
      Cs_n <= '1';
    elsif rising_edge(s_clk_adc) then
      Cs_n <= '0';
    end if;
  end process;

  -- Sortie du signal Clk_adc
  Clk_adc <= s_clk_adc;

end Behavioral;

