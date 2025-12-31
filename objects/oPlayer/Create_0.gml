setupControls();

// Sprites
idleSpr = sPlayerIdle;
walkSpr = sPlayerWalk;
runSpr = sPlayerRun;
jumpSpr = sPlayerJump;

maskSpr = idleSpr;
mask_index = maskSpr;

// Moving 
framesToMove = 0;

moveSpd[0] = 2;
moveSpd[1] = 3.5;
moveIndex = 0;
moveDir = 0;
facingDir = 1;
xSpd = 0;
ySpd = 0;

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
		coyoteHangTimer = 0;
		coyoteJumpTimer--;
		if jumpCount == 0 && coyoteJumpTimer <= 0
		{
			jumpCount = 1
		}
	}
}