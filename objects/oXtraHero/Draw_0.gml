
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * facingDir, image_yscale, image_angle, image_blend, image_alpha);

/*

draw_line(bbox_left, bbox_bottom - 1, bbox_right - 1, bbox_bottom - 1);
draw_line(bbox_left, bbox_top, bbox_left, bbox_bottom - 1);
draw_line(bbox_left, bbox_top, bbox_right - 1, bbox_top);
draw_line(bbox_right - 1, bbox_top, bbox_right - 1, bbox_bottom - 1);

*/

	
if sprite_index == jumpSpr {
	if state == PlayerStates.FallingState || state == PlayerStates.DashJumpingFallingState {
		if image_index > image_number - 2	{
			image_index = image_number - 1;
			image_speed = 0;
		}
	}
	else {
		if yVelocity < 0 {
			image_index = image_number - 3	
		}
		if (image_index == image_number - 1)
		{
			image_index = image_number - 1;
			image_speed = 0;
		}
	}
	
} else if sprite_index == dashSpr {
	if (image_index == image_number - 1)
	{
		image_index = image_number - 1;
		image_speed = 0;
	}
} else if sprite_index == wallSlideSpr {
	if (image_index == image_number - 1)
	{
		image_index = image_number - 1;
		image_speed = 0;
	} 
} else {
		image_speed = 1;
}

