library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity detc_front is 
port( 
	clk, sig : in std_logic;
	front : out std_logic
	);
end detc_front;

architecture bhv of detc_front is 
signal A,B: std_logic;

begin
process (clk)

begin
 if (clk'event AND clk = '1') then
 A <= sig;
 B <= not A;
end if; 
end process;

front <= (B and A);

end bhv;