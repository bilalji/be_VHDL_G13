library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Gestion_Butee is
  generic (
    N_1 : integer := 12;
    N_2 : integer := 16
  );
  port (
    pwm_state : in std_logic;
    sens : in std_logic;
    enable : in std_logic;
    angle : in std_logic_vector(N_1 - 1 downto 0);
    butee_gauche, butee_droite : in std_logic_vector (N_2 - 1 downto 0);
    pwm_out, extremite_gauche_out, extremite_droite_out, sens_out : out std_logic
  );
end Gestion_Butee;

architecture Behavioral of Gestion_Butee is
  signal fin_course_droite : std_logic;
  signal fin_course_gauche : std_logic;

begin
  controle_butee : process (pwm_state, sens, enable, angle, butee_gauche, butee_droite)
  begin
    if (enable = '1') then
      if (pwm_state = '1') then
        if (sens = '1') then
          if (angle >= butee_droite) then
            pwm_out <= '1';
            sens_out <= '0';
            fin_course_droite <= '1';
          else
            pwm_out <= '0';
            sens_out <= '1';
            fin_course_droite <= '0';
          end if;
        elsif (sens = '0') then
          if (angle >= butee_gauche) then
            pwm_out <= '1';
            sens_out <= '0';
            fin_course_gauche <= '1';
          else
            pwm_out <= '0';
            sens_out <= '0';
            fin_course_gauche <= '0';
          end if;
        end if;
      end if;
    else
      pwm_out <= '0';
      sens_out <= '0';
      fin_course_gauche <= '0';
      pwm_out <= '0';
      sens_out <= '1';
      fin_course_droite <= '0';
      extremite_gauche_out <= fin_course_gauche;
      extremite_droite_out <= fin_course_droite;
    end if;
    extremite_gauche_out <= fin_course_gauche;
    extremite_droite_out <= fin_course_droite;
  end process;
end Behavioral;