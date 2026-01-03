setupControls();

depth = -30;

framesToProcess = 0;

// Sprites
idleSpr = sPlayerIdle;
walkSpr = sPlayerWalk;
runSpr = sPlayerRun;
jumpSpr = sPlayerJump;
danceSpr = sPlayerDance;

maskSpr = idleSpr;
mask_index = maskSpr;

// Moving 

moveSpd[0] = 2;
moveSpd[1] = 3.5;
moveIndex = 0;
moveDir = 0;
facingDir = 1;
xSpd = 0;
ySpd = 0;
xSubPixel = 0;
ySubPixel = 0;

// Jumping
grav = .25;
termVel = 4;
jumpMaxCount = 2;
jumpSpd[0] = -6;
jumpSpd[1] = -4;
coyoteHangMaxFrames = 2;
coyoteJumpMaxFrames = 5;

grounded = true;
jumpCount = 0;
coyoteHangTimer = 0;
coyoteJumpTimer = 0;

// Moving Platforms
movementParent = noone;
previousMovementParent = noone;
movementParentXSpd = 0;
movementParentMaxYSpd = termVel;


function setGrounded(_val = true)
{
	grounded = _val;
	if grounded 
	{
		jumpCount = 0; 
		jumpHoldTimer = 0;
		coyoteHangTimer = coyoteHangMaxFrames;
		coyoteJumpTimer = coyoteJumpMaxFrames;
	}
	else
	{
		movementParent = noone;
		coyoteHangTimer = 0;
		coyoteJumpTimer--;
		if jumpCount == 0 && coyoteJumpTimer <= 0
		{
			jumpCount = 1
		}
	}
}

function checkForSemiSolidPlatforms(_x, _y)
{
	var _returnValue = noone;
	if ySpd >= 0 && place_meeting(_x, _y, oSemiSolidPlatform)
	{
		var _objects = ds_list_create();
		var _objectCount = instance_place_list(_x, _y, oSemiSolidPlatform, _objects, false);
		
		for (var i = 0; i < _objectCount; ++i)
		{
			var _object = _objects[| i];
			if _object != previousMovementParent && bbox_bottom >= _object.bbox_top - _object.yDelta
			{
				_returnValue = _object;
				break;
			}
		}
		ds_list_destroy(_objects);
	}
	return _returnValue;
}