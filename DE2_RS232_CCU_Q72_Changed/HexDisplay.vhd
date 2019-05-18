-- HexDisplay
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY HexDisplay IS
	PORT
	(
-- This varaible is the four bit input number to this seven segment display
		N		:IN		STD_LOGIC_VECTOR(3 DOWNTO 0);
-- This pulse acts as a clock with a one second period
		clk		:IN		STD_LOGIC;
-- This variable represents each segment of the seven segment display, refer to the DE2 board specification to adjust display properties
		Display	:OUT	STD_LOGIC_VECTOR(0 TO 6)
	);
END HexDisplay;

ARCHITECTURE Behavior OF HexDisplay IS
BEGIN
	PROCESS ( clk )
	BEGIN
-- This clock pulse allows the seven segment display to change only after one second (effectivly changing the output to the number of counts per second)
		IF clk'EVENT AND clk = '1' THEN
			Display(0) <= ( NOT (N(3)) AND NOT (N(2)) AND NOT (N(1)) AND N(0) ) OR ( NOT (N(3)) AND N(2) AND NOT (N(1)) AND NOT (N(0)) ) OR ( N(3) AND NOT (N(2)) AND N(1) AND N(0) ) OR ( N(3) AND N(2) AND NOT (N(1)) AND N(0) );
			Display(1) <= ( NOT (N(3)) AND N(2) AND NOT (N(1)) AND N(0) ) OR ( NOT (N(3)) AND N(2) AND N(1) AND NOT (N(0)) ) OR ( N(3) AND NOT (N(2)) AND N(1) AND N(0) ) OR ( N(3) AND N(2) AND NOT (N(1)) AND NOT (N(0)) ) OR ( N(3) AND N(2) AND N(1) AND NOT (N(0)) ) OR ( N(3) AND N(2) AND N(1) AND N(0) );
			Display(2) <= ( NOT (N(3)) AND NOT (N(2)) AND N(1) AND NOT (N(0)) ) OR ( N(3) AND N(2) AND NOT (N(1)) AND NOT (N(0)) ) OR ( N(3) AND N(2) AND N(1) AND NOT (N(0)) ) OR ( N(3) AND N(2) AND N(1) AND N(0) );
			Display(3) <= ( NOT (N(3)) AND NOT (N(2)) AND NOT (N(1)) AND N(0) ) OR ( NOT (N(3)) AND N(2) AND NOT (N(1)) AND NOT (N(0)) ) OR ( NOT (N(3)) AND N(2) AND N(1) AND N(0) ) OR ( N(3) AND NOT (N(2)) AND N(1) AND NOT (N(0)) ) OR ( N(3) AND N(2) AND N(1) AND N(0) );
			Display(4) <= ( NOT (N(3)) AND NOT (N(2)) AND NOT (N(1)) AND N(0) ) OR ( NOT (N(3)) AND NOT (N(2)) AND N(1) AND N(0) ) OR ( NOT (N(3)) AND N(2) AND NOT (N(1)) AND NOT (N(0)) ) OR ( NOT (N(3)) AND N(2) AND NOT (N(1)) AND N(0) ) OR ( NOT (N(3)) AND N(2) AND N(1) AND N(0) ) OR ( N(3) AND NOT (N(2)) AND NOT (N(1)) AND N(0) );
			Display(5) <= (	NOT (N(3)) AND NOT (N(2)) AND NOT (N(1)) AND N(0) ) OR ( NOT (N(3)) AND NOT (N(2)) AND N(1) AND NOT (N(0)) ) OR ( NOT (N(3)) AND NOT (N(2)) AND N(1) AND N(0) ) OR ( NOT (N(3)) AND N(2) AND N(1) AND N(0) ) OR ( N(3) AND N(2) AND NOT (N(1)) AND N(0) );
			Display(6) <= ( NOT (N(3)) AND NOT (N(2)) AND NOT (N(1)) AND NOT (N(0)) ) OR ( NOT (N(3)) AND NOT (N(2)) AND NOT (N(1)) AND N(0) ) OR ( NOT (N(3)) AND N(2) AND N(1) AND N(0) ) OR ( N(3) AND N(2) AND NOT (N(1)) AND NOT (N(0)) );
		END IF;
	END PROCESS;
END Behavior;