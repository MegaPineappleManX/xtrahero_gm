
framesToProcess  += getFramesSinceLastStep();
xDelta = 0;
yDelta = 0;

// Do the movement for each game frame that has elapsed since the last real frame
// Game frames are 60 FPS but the game may deviate. This will cause all movement to be accurate
while framesToProcess  >= 1 
{
	framesToProcess --;
	

	dir += rotSpd;


	var _targetX = xstart + lengthdir_x(radius, dir);
	var _targetY = ystart + lengthdir_y(radius, dir);

	xSpd = _targetX - x + xSubPixel;
	ySpd = _targetY - y + ySubPixel;

	xSubPixel = frac(xSpd);
	ySubPixel = frac(ySpd);
	xSpd -= xSubPixel
	ySpd -= ySubPixel;
	//x += xSpd;
	y += ySpd;
	//xDelta += xSpd;
	yDelta += ySpd;
}