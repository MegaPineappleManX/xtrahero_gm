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
	if ySpd >= 0 && !place_meeting(x + trunc(xSpd), y + 1, oWall) && place_meeting(x + trunc(xSpd), y + abs(trunc(xSpd)) + 1, oWall)
	{
		while !place_meeting(x + trunc(xSpd), y + 1, oWall) 
		{
			y++;
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
			}
		}
		
	}
	
	// Down Y collision
	if place_meeting(x, y + trunc(ySpd) , oWall) 
	{
		while !place_meeting(x, y + sign(ySpd), oWall) 
		{
			y += sign(ySpd);
		}
		
		ySpd = 0;
	}
	else if ySpd > 0 && moveDir != 0 && place_meeting(x + moveDir, y + trunc(ySpd), oWall)
	{
		wallSliding = true;
	}
	
	if trunc(ySpd) >= 0 && place_meeting(x, y + 1, oWall) 
	{
		setGrounded(true);
	}
	
	// We only want to move in whole pixels
	ySubPixel = frac(ySpd);
	ySpd = trunc(ySpd);
	y += ySpd;
}
