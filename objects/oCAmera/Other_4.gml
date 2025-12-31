
if !instance_exists(oPlayer) exit;

var _camWidth = camera_get_view_width(view_camera[0]);
var _camHeight = camera_get_view_height(view_camera[0]);

_targetXPos = oPlayer.x - _camWidth / 2;
_targetYPos = oPlayer.y - _camHeight / 2;

camX = clamp(_targetXPos, 0, room_width - _camWidth);
camY = clamp(_targetYPos, 0, room_height - _camHeight);