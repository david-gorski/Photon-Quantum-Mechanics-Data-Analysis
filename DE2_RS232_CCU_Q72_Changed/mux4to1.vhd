-- 4 to 1 multiplexer; chooses one of three delayed and shortened signals or leaves original signal unchanged
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux4to1 IS
	PORT
	(
-- This pulse has the shortest delay, ~5 ns
		delayedpulse_0	:IN		STD_LOGIC;
-- This pulse has a moderate delay, ~10 ns
		delayedpulse_1	:IN		STD_LOGIC;
-- This pulse has the longest delay, ~15 ns
		delayedpulse_2	:IN		STD_LOGIC;
-- This is the original pulse output by the photon detector
		pulse			:IN		STD_LOGIC;
-- These switches determine which pulse is output
		SW				:IN		STD_LOGIC_VECTOR(1 DOWNTO 0);
-- This is the output pulse
		pulseout		:OUT	STD_LOGIC
	);
END mux4to1;

ARCHITECTURE Behavior OF mux4to1 IS
BEGIN
	PROCESS(SW)
	BEGIN
-- If both switches are on, then the output pulse is the same as the input pulse
		IF SW(1) = '1' AND SW(0) = '1' THEN
			pulseout <= pulse;
-- If only SW(1) is on, then the output pulse will be shortened to ~10 ns
		ELSIF SW(1) = '1' AND SW(0) = '0' THEN
			pulseout <= pulse AND NOT delayedpulse_2;
-- If only SW(0) is on, then the output pulse will be shortened to ~ 5 ns
		ELSIF SW(1) = '0' AND SW(0) = '1' THEN
			pulseout <= pulse AND NOT delayedpulse_1;
-- If both SW(0) and SW(1) are off, then the output pulse will be shortened to ~1 ns
		ELSIF SW(1) = '0' AND SW(0) = '0' THEN
			pulseout <= pulse AND NOT delayedpulse_0;
		END IF;
	END PROCESS;
END Behavior;
