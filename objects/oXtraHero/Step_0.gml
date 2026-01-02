
	if keyboard_check(vk_alt) { game_set_speed(30, gamespeed_fps); };
	if keyboard_check(vk_control) { game_set_speed(60, gamespeed_fps); };
	if keyboard_check(vk_f1) { game_set_speed(10, gamespeed_fps); };
	
	dashKeyPressed = keyboard_check_pressed(vk_shift) || gamepad_button_check_pressed(0, gp_face2);
	dashKeyHeld = keyboard_check(vk_shift) || gamepad_button_check(0, gp_face2);
	
	rightKey = keyboard_check(ord("D")) || gamepad_button_check(0, gp_padr);
	leftKey = keyboard_check(ord("A")) || gamepad_button_check(0, gp_padl);

	jumpKeyPressed = keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1);
	jumpKey = keyboard_check(vk_space) || gamepad_button_check(0, gp_face1);
	
#region Input Buffering
	if jumpKeyPressed {
		jumpKeyBufferTimer = bufferTime;
	}
	if jumpKeyBufferTimer > 0 {
		jumpKeyBuffered = true;
		jumpKeyBufferTimer--;
	} else {
		jumpKeyBuffered = false;
	}
	
	if dashKeyPressed {
		dashKeyBufferTimer = bufferTime;
	}
	if dashKeyBufferTimer > 0 {
		dashKeyBuffered = true;
		dashKeyBufferTimer--;
	} else {
		dashKeyBuffered = false;
	}
#endregion
	
	moveDir = rightKey - leftKey;
	facingDir = moveDir != 0 ? moveDir : facingDir;
	
framesSinceLastStep += getFramesSinceLastStep();

while framesSinceLastStep > 1 {
	framesSinceLastStep--;
	processState();
	frame++;
}


//show_debug_message("X Pos: {0} | Y Pos: {1} | xVelocity {2} | yVelocity {3} | xSubPixel {4} | ySubPixel {5} | Frame: {6}", x, y, xVelocity, yVelocity, xSubPixel, ySubPixel, frame);