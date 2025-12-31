getControls();

framesToMove += getFramesElapsed();

// Do the movement for each game frame that has elapsed since the last real frame
// Game frames are 60 FPS but the game may deviate. This will cause all movement to be accurate
while framesToMove >= 1 
{
	framesToMove--;
	
	
// X Movement
	moveDir = rightKey - leftKey;
	facingDir = moveDir != 0 ? moveDir : facingDir;

	moveIndex = dashKey;
	xSpd = moveDir * moveSpd[moveIndex];

	var _subPixel = 1;
	// TODO: Maybe rework this to check each pixel for speeds greater than tile size?
	if place_meeting(x + xSpd, y, oWall) 
	{
		// Up Slops
		if !place_meeting(x + xSpd, y - abs(xSpd) - 1 , oWall) 
		{
			while place_meeting(x + xSpd, y, oWall) 
			{
				y -= _subPixel;
			}
		}
		// Normal Movement
		else 
		{
			// Ceiling Slope
			if !place_meeting(x + xSpd, y + abs(xSpd) + 1, oWall)
			{
				while place_meeting(x + xSpd, y, oWall) 
				{
					y += _subPixel;
				}
			}
			else 
			{
				var _pixelCheck = _subPixel * sign(xSpd);
	
				while !place_meeting(x + _pixelCheck, y, oWall) 
				{
					x += _pixelCheck;
				}
	
				xSpd = 0;
			}
		}
	}
	//Down Slopes
	if ySpd >= 0 && !place_meeting(x + xSpd, y + 1, oWall) && place_meeting(x + xSpd, y + abs(xSpd) + 1, oWall)
	{
		while !place_meeting(x + xSpd, y + _subPixel, oWall) 
		{
			y += _subPixel;
		}
	}
	

	x += xSpd;


// Y Movement
	if coyoteHangTimer > 0
	{
		coyoteHangTimer--;
	}
	else 
	{
		ySpd += grav;
		setGrounded(false);
	}

	if grav > termVel { ySpd = termVel; };
	
	
	// Jump
	if jumpKeyBuffered && jumpCount < jumpMaxCount
	{
		setGrounded(false);
		jumpKeyBuffered = false;
		jumpKeyBufferTimer = 0;
		distanceToJump = 0;
		jumpRemainder = 0;
		
		jumpCount++;
		
		ySpd = jumpSpd[jumpCount-1];
	}
	
	if !jumpKey && ySpd < 0
	{
		ySpd = 0;
	}
	
	//var _subPixel = .5;
	var spotToCheck = ySpd >= 0 ? y + ySpd : y + ySpd; 
	if place_meeting(x, spotToCheck , oWall) 
	{
		show_debug_message("AHHHH {0}", x);
		var _pixelCheck = _subPixel * sign(ySpd);
		while !place_meeting(x, y + _pixelCheck, oWall) 
		{
			y += _pixelCheck;
		}
		
		// Ceiling bonk 
		if ySpd < 0
		{
			jumpHoldTimer = 0;	
		}
		
		ySpd = 0;
	}
	
	if ySpd >= 0 && place_meeting(x, y + 1, oWall) 
	{
		setGrounded(true);
	}
	
	y += ySpd;
}
