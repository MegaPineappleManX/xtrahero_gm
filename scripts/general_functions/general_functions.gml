function isDebug() {
	return true;
}

function setupControls()
{
	bufferTime = 3;
	
	jumpKeyBuffered = 0;
	jumpKeyBufferTimer = 0;
}

function getControls()
{

	if keyboard_check(vk_alt) { game_set_speed(30, gamespeed_fps); };
	if keyboard_check(vk_control) { game_set_speed(60, gamespeed_fps); };
	if keyboard_check(vk_f1) { game_set_speed(10, gamespeed_fps); };
	
	dashKey = keyboard_check(vk_shift) || gamepad_button_check(0, gp_face3);
	
	rightKey = keyboard_check(ord("D")) || gamepad_button_check(0, gp_padr);
	leftKey = keyboard_check(ord("A")) || gamepad_button_check(0, gp_padl);

	jumpKeyPressed = keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1);
	jumpKey = keyboard_check(vk_space) || gamepad_button_check(0, gp_face1);
	
	// Input Buffering Jump
	if jumpKeyPressed
	{
		jumpKeyBufferTimer = bufferTime;
	}
	if jumpKeyBufferTimer > 0
	{
		jumpKeyBuffered = 1;
		jumpKeyBufferTimer--;
	}
	else
	{
		jumpKeyBuffered = 0;
	}
}

function getFramesSinceLastStep()
{
	var _target_delta = 1/60;
	
	var _actual_delta = delta_time/1000000;
	var _frames = _actual_delta/_target_delta;
	return _frames;
}

// Math
function trunc(_value)
{
	var fraction = frac(_value);
	return _value - fraction;
}