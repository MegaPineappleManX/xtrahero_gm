getControls();

framesToProcess  += getFramesSinceLastStep();

// Do the movement for each game frame that has elapsed since the last real frame
// Game frames are 60 FPS but the game may deviate. This will cause all movement to be accurate
while framesToProcess  >= 1 
{
	framesToProcess --;
	
	
// X Movement
	moveDir = rightKey - leftKey;
	facingDir = moveDir != 0 ? moveDir : facingDir;

	moveIndex = dashKey;
	xSpd = moveDir * moveSpd[moveIndex] + xSubPixel;

	// TODO: Maybe rework this to check each pixel for speeds greater than tile size?
	if place_meeting(x + trunc(xSpd), y, oWall) 
	{
		// Up Slopes
		if !place_meeting(x + trunc(xSpd), y - abs(trunc(xSpd)) , oWall) 
		{
			while place_meeting(x + trunc(xSpd), y, oWall) 
			{
				y--;
			}
		}
		// Normal Movement
		else 
		{
			// Ceiling Slope
			if !place_meeting(x + trunc(xSpd), y + abs(trunc(xSpd)), oWall)
			{
				while place_meeting(x + trunc(xSpd), y, oWall) 
				{
					y++;
				}
			}
			else 
			{
				while !place_meeting(x + sign(xSpd), y, oWall) 
				{
					x += sign(xSpd);
				}
	
				xSpd = 0;
			}
		}
	}
	//Down Slopes
	if ySpd >= 0 && !place_meeting(x + trunc(xSpd), y + 1, oWall) 
	&& place_meeting(x + trunc(xSpd), y + abs(trunc(xSpd)) + 1, oWall)
	{
		var _platform = checkForSemiSolidPlatforms(x + trunc(xSpd), y + abs(trunc(xSpd)))
		
		if !instance_exists(_platform) 
		{
			while !place_meeting(x + trunc(xSpd), y + 1, oWall) 
			{
				y++;
			}
		}
	}
	
	// We only want to move in whole pixels
	xSubPixel = frac(xSpd);
	xSpd = trunc(xSpd);
	x += xSpd;


// Y Movement
	if coyoteHangTimer > 0
	{
		coyoteHangTimer--;
	}
	else 
	{
		ySpd += grav + ySubPixel;
		if grav > termVel { ySpd = termVel; };
		setGrounded(false);
	}

	
	// Jump
	if jumpKeyBuffered && !downKey && jumpCount < jumpMaxCount
	{
		setGrounded(false);
		jumpKeyBuffered = false;
		jumpKeyBufferTimer = 0;
		distanceToJump = 0;
		jumpRemainder = 0;
		
		jumpCount++;
		
		ySpd = jumpSpd[jumpCount-1];
	}
	
	if !jumpKey && trunc(ySpd) < 0
	{
		ySpd = 0;
	}
	
	// Up Y Collision
	if ySpd < 0 && place_meeting( x, y + trunc(ySpd), oWall)
	{
		// jump into upleft slope ceil
		if moveDir == 0 && !place_meeting( x - abs(trunc(ySpd)) - 1, y + trunc(ySpd), oWall) {
			while place_meeting(x, y + trunc(ySpd), oWall) 
			{
				x--;
			}
		}
		// jump into upright slope ceil
		else if moveDir == 0 && !place_meeting( x + abs(trunc(ySpd)) + 1, y + trunc(ySpd), oWall) {
			while place_meeting(x, y + trunc(ySpd), oWall) 
			{
				x++;
			}
		}
		//normal y up collision
		else
		{
			// Ceiling bonk 
			if trunc(ySpd) < 0
			{
				jumpHoldTimer = 0;	
				ySpd = 0;
			}
		}
	}
	
	show_debug_message(movementParent);
	
	if downKey && jumpKeyPressed && instance_exists(movementParent)
	{
		if movementParent.object_index == oSemiSolidPlatform || object_is_ancestor(movementParent.object_index, oSemiSolidPlatform)
		{
			var _yCheck = max(1, movementParent.yDelta + 1);
			if !place_meeting(x, y + _yCheck, oWall)
			{
				y++;
				ySpd = _yCheck;
				previousMovementParent = movementParent;
				setGrounded(false);
			}
		}
	}
	
	// We only want to move in whole pixels
	ySubPixel = frac(ySpd);
	ySpd = trunc(ySpd);
	y += ySpd;
	
	if instance_exists(previousMovementParent) && !place_meeting(x, y, previousMovementParent)
	{
		previousMovementParent = noone;	
	}
	
#region oldCode
	// Down Y collision
	/* old down collision
 	if place_meeting(x, y + trunc(ySpd) , oWall) 
	{
		while !place_meeting(x, y + sign(ySpd), oWall) 
		{
			y += sign(ySpd);
		}
		
		ySpd = 0;
	}
	
	if trunc(ySpd) >= 0 && place_meeting(x, y + 1, oWall) 
	{
		setGrounded(true);
	}
	*/
#endregion


	//check for solid/semisolid platforms under me
	var _yCheckRange = max (0, ySpd);
	var _objects = ds_list_create();
	var _validObjects = [ oWall, oSemiSolidMovablePlatform, oSemiSolidPlatform ];
	var _objectCount = instance_place_list(x, y + 1 + _yCheckRange + movementParentMaxYSpd, _validObjects, _objects, false);
	
	var _yCheck = y + 1 + _yCheckRange;
	if instance_exists(movementParent) { _yCheck += max(0, movementParent.yDelta); }
	var _checkedPlatform = checkForSemiSolidPlatforms(x, _yCheck);
	
	for (var i = 0; i < _objectCount; ++i) 
	{
		var _object = _objects[| i];
		if _object != previousMovementParent
		&& (_object.yDelta <= ySpd || instance_exists(movementParent)) 
		&& (_object.yDelta > 0 || place_meeting(x, y + 1 + _yCheckRange, _object))
		|| (_object == _checkedPlatform)
		{
			
			if _object.object_index == oWall
			|| object_is_ancestor(_object.object_index, oWall)
			|| floor(bbox_bottom) <= _object.bbox_top - _object.yDelta
			{
				// return highest valid object
				if !instance_exists(movementParent)
				|| _object.bbox_top + _object.yDelta <= movementParent.bbox_top + movementParent.yDelta
				|| _object.bbox_top + _object.yDelta <= bbox_bottom
				{
					movementParent = _object;
					break;
				}
			}
		}
	}
	ds_list_destroy(_objects);
	
	if instance_exists(movementParent) && !place_meeting(x, y + ySpd + movementParentMaxYSpd, movementParent) 
	{
		movementParent = noone;	
	}
	
	if instance_exists(movementParent) 
	{
		while !place_meeting(x, y + 1, movementParent) && !place_meeting(x, y, oWall)
		{
			
			y++;
		}
		
		if movementParent.object_index == oSemiSolidPlatform || object_is_ancestor(movementParent.object_index, oSemiSolidPlatform)
		{
			while place_meeting(x, y, movementParent) 
			{
				y--;	
			}
		}
		
		 ySpd = 0;
		 setGrounded(true);
	}
}


// Moving Platform bullshit
movementParentXSpd = 0;
if instance_exists(movementParent) { movementParentXSpd = movementParent.xDelta; }

if place_meeting(x + movementParentXSpd, y, oWall)
{
	while !place_meeting(x + sign(movementParentXSpd), y, oWall)
	{
		x += sign(movementParentXSpd);	
	}
	movementParentXSpd = 0;
}
x += movementParentXSpd;

// Shouldnt be needed snaps to platform
if instance_exists(movementParent) && movementParent.yDelta != 0
{
	if !place_meeting(x, movementParent.bbox_top, oWall)
	&& movementParent.bbox_top >= bbox_bottom - movementParentMaxYSpd
	{
		y = movementParent.bbox_top;
	}
	
	if movementParent.yDelta < 0 && place_meeting(x, y + movementParent.yDelta, oWall)
	{
		if movementParent.object_index == oSemiSolidPlatform
		|| object_is_ancestor(movementParent.object_index, oSemiSolidPlatform)
		{
			while place_meeting(x, y + movementParent.yDelta, oWall)
			{
				y++;
			}
			
			while place_meeting(x, y , oWall)
			{
				y--;
			}
			
			setGrounded(false);
		}
	}
}

if place_meeting(x, y, oWall) { 
	
	//while place_meeting(x, y - ySpd, oWall) { y ++; }
	//while place_meeting(x, y + ySpd, oWall) { y --; }
	//else { /*kill player*/ }
}