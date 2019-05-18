-- Puts the pulse through AND gates to delay the signal
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY pulse_ander IS
	PORT
	(
-- This is the input pulse
		pulse			:IN		STD_LOGIC;
-- This is SW(17), which will be ANDed with the input pulse
		KEY				:IN		STD_LOGIC;
-- This pulse is connected in succession to the next 'pulse_ander',
-- i.e. PA1:pulse_out will be the input to PA2:pulse
		pulse_out		:OUT	STD_LOGIC
	);
END pulse_ander;

ARCHITECTURE Behavior OF pulse_ander IS
	SIGNAL delayedpulse: STD_LOGIC;

BEGIN
	delayedpulse <= pulse AND KEY;
	pulse_out <= delayedpulse;
END Behavior;