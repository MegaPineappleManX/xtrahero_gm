if keyboard_check_pressed(vk_f8)
{
	window_set_fullscreen(!window_get_fullscreen())
}

if !instance_exists(targetObject) exit;

var _camWidth = camera_get_view_width(view_camera[0]);
var _camHeight = camera_get_view_height(view_camera[0]);

var _targetXPos = targetObject.x - _camWidth / 2;
var _targetYPos = targetObject.y - _camHeight / 2;

// constrain to room
_targetXPos = clamp(_targetXPos, 0, room_width - _camWidth);
_targetYPos = clamp(_targetYPos, 0, room_height - _camHeight);

// camera smoothing
camX += (_targetXPos - camX) * trailSpeed;
camY += (_targetYPos - camY) * trailSpeed;

camera_set_view_pos(view_camera[0], camX, camY);