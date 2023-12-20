library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Gestion_PWM is
  port (
    Raz_N : in std_logic;
    Enable_PWM : in std_logic;
    PWM : out std_logic
  );
end Gestion_PWM;

architecture Behavioral of Gestion_PWM is
  constant Freq : integer := 50000000;  -- Fréquence en Hz (50 MHz par exemple)
  constant Duty : integer := 25000000; -- 50% de devoir (50% duty cycle)

  signal pwm_count : integer range 0 to Freq - 1 := 0;
  signal pwm_state : std_logic := '0';

begin
  -- Processus pour diviser la fréquence
  divide : process (Raz_N)
  begin
    if rising_edge(Raz_N) then
      pwm_count <= 0;
    elsif rising_edge(clk) then
      if Enable_PWM = '1' then
        pwm_count <= pwm_count + 1;
        if pwm_count = Freq - 1 then
          pwm_count <= 0;
        end if;
      else
        pwm_count <= 0;
      end if;
    end if;
  end process;

  -- Processus pour comparer et générer le signal PWM
  compare : process (pwm_count, Enable_PWM)
  begin
    if Enable_PWM = '1' then
      if pwm_count < Duty then
        pwm_state <= '1';
      else
        pwm_state <= '0';
      end if;
    else
      pwm_state <= '0';
    end if;
  end process compare;

  -- Sortie du signal PWM
  PWM <= pwm_state;

end Behavioral;
