Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity chipselect is
	port(
		start_c : in std_logic;
		clk_1M : in std_logic;
		raz_n : in std_logic;
		cs : out std_logic);
end chipselect;

architecture arch_chipselect of chipselect is
signal stop : std_logic;

begin 

process(clk_1M, raz_n) is
variable cnt1 : integer range 0 to 32:=0;
variable cnt2 : integer range 0 to 16:=0;


begin
if start_c = '0' then
	stop <= '0';
else stop <='1';
end if;
if raz_n ='0' then
	cnt1 := 0 ;
elsif stop = '0' then
	if rising_edge(clk_1M) then
		cnt1 := cnt1 + 1;
		if cnt1 >= 15 then
			cs <= '0';
			cnt2 := cnt2 + 1;
			if cnt2 = 16 then
				cs <= '1';
				cnt1 := 0;
				cnt2 := 0;
			end if;
		end if;
	end if;
end if;
end process;

end architecture arch_chipselect;
