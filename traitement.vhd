library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity traitement is

port( 
	clk, raz_n, start_stop, continu    : in std_logic ;
	in_freq_anemometre  : in std_logic;
	data_valid : out std_logic ; 
	data_anemometre : out std_logic_vector(7 downto 0)
);

end entity;

architecture arch_anemometre of traitement is
type etats is (ST_A, ST_B);
signal etat_actuelle, etat_suivante    : etats;
signal start : std_logic;
signal stop : std_logic;
signal enable2 : std_logic;
signal raz : std_logic;
signal S2 : std_logic;
signal out_cpt1 : std_logic_vector(25 downto 0);
signal out_cpt2 : std_logic_vector (7 downto 0);
signal out_comp : std_logic;
signal lim : std_logic_vector (25 downto 0);



component detc_front is
port( 
	-- Entree & sortie
	clk, sig : in std_logic;
	front: out std_logic
	);
end component;

component compteur is
generic
 (
	N : INTEGER:= 26
 );
port( 
	-- Entree & sortie
	clk,raz_n, enable : in std_logic;
	cmp: out std_logic_vector(N-1 downto 0)
	);
end component;

component comparateur is
generic
	(
	N : INTEGER:= 26
	);
port(   A,B  :      in  std_logic_vector(N-1 downto 0);
    result :      out     std_logic);
	
end component;

component sys_registre is
	
generic
	(
	N : INTEGER:= 8
	);
	port( 
		-- Entree & sortie
		clk, enable, raz_n : in std_logic;
		entree : in  std_logic_vector(N-1 downto 0);
		sortie : out std_logic_vector(N-1 downto 0)
		);
		
end component;

begin




s2 <= start and enable2;
 
 raz <= (not raz_n) or out_comp;

lim <= "10111110101111000001111111";

 
compteur1:  compteur generic map (N =>26)
			 port map (clk =>clk,raz_n => raz  ,enable => enable2 ,cmp => out_cpt1);

compa : comparateur port map (A => out_cpt1 , B => lim , result => out_comp);

detecteur :  detc_front port map (clk => clk ,sig => in_freq_anemometre ,front => start);

compteur2:  compteur generic map (N =>8)
			 port map (clk => clk, raz_n => raz ,enable => start and enable2, cmp => out_cpt2);
			 
registre1 : sys_registre port map (clk => clk, enable => out_comp ,raz_n => not raz_n ,entree => out_cpt2, sortie =>data_anemometre); 


pblocF : process  (etat_actuelle, continu, start_stop, out_comp)
begin
case etat_actuelle is
when ST_A =>
					if (continu = '1' or start_stop = '0') then etat_suivante <= ST_B;
					else etat_suivante <= etat_actuelle;
					end if;
when ST_B =>    
					if (continu = '0' and out_comp = '1') then etat_suivante <= ST_A;
					else etat_suivante <= etat_actuelle;
					end if;
when others =>
end case;

end process pblocF;

pblocM : process (clk)
begin

if clk'event and clk = '1' then
        
            etat_actuelle <= etat_suivante;
            
        end if;
end process pBlocM;

	enable2 <= '1' when etat_actuelle = ST_B else '0';           
	data_valid <= '1' when etat_actuelle = ST_A;			  
end arch_anemometre;

