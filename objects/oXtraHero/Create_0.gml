initialState = PlayerStates.IdleState;
state = initialState;

frame = 0;
framesSinceLastStep = 0;

moveDir = 0;
facingDir = 1;
wallSlideDir = 0;
dashingDir = 0;
// Used to stop the dash if a player stops inputting movement or changes moveDir...
// on a dash that started with movement input
// on a wallslide
cachedMoveDir = 0;

moveSpeed = 1.46875;
dashSpeed = 3.45703125;
jumpSpeed = -5.32421875;
yTerminalVelocity = 5.75;
gravityPerFrame = .25;
jumpVelocityPerFrame = 0;

DashFramesRemaining = 0;
DashTimeFrames = 60;

dashKeyBuffered = false;
dashKeyBufferTimer = 0;
jumpKeyBuffered = false;
jumpKeyBufferTimer = 0;
bufferTime = 3;

xVelocity = 0;
yVelocity = 0;
xSubPixel = 0;
ySubPixel = 0;

coyoteFramesRemaining = 0;
coyoteTimeFrames = 2;

wallJumpFramesRemaining = 0;
wallJumpTimeFrames = 10;
wallDashJumpTimeFrames = 10;

// Sprites
idleSpr = sXtraHero;
dashSpr  = sXtraHeroDashing;
runSpr = sXtraHeroRunning;
jumpSpr = sXtraHeroJumping;
danceSpr = sPlayerDance;
wallSlideSpr = sXtraHeroWallSliding;

maskSpr = idleSpr;
mask_index = maskSpr;


enum PlayerStates { 
	CoyoteTimeState			   				, // 0
	DashCoyoteTimeState		   				, // 1
	DashJumpingFallingState	   				, // 2
	DashJumpingState						, // 3 
	DashState								, // 4
	FallingState							, // 5
	IdleState								, // 6
	JumpingState							, // 7
	SlowWalkingState						, // 8
	WalkingState							, // 9
	WallDashJumpingState					, // 10
	WallJumpingState						, // 11
	WallSlidingState						, // 12
}

function removeSubpixels() {
	xSubPixel = frac(xVelocity);
	ySubPixel = frac(yVelocity);
	xVelocity -= xSubPixel;
	yVelocity -= ySubPixel;
	//show_debug_message("xSubPixel {0} | ySubPixel {1} | xVelocity {2} | yVelocity {3}", xSubPixel, ySubPixel, xVelocity, yVelocity);
}
	
function changeState(_value) {
	show_debug_message("Entering State: {0}", _value);
	var _previousState = state;
	state = _value;
		switch (state) {
		#region CoyoteTimeState
		case PlayerStates.CoyoteTimeState			   		:
			if _previousState != PlayerStates.DashCoyoteTimeState {
				coyoteFramesRemaining = coyoteTimeFrames;
			}
			break;
		#endregion
		#region DashCoyoteTimeState
		case PlayerStates.DashCoyoteTimeState		   		:
			if _previousState != PlayerStates.CoyoteTimeState {
				coyoteFramesRemaining = coyoteTimeFrames;
			}
			break;
		#endregion
		#region DashJumpingFallingState
		case PlayerStates.DashJumpingFallingState:
			sprite_index = jumpSpr;
			yVelocity = 0;
			break;
		#endregion
		#region DashJumpingState
		case PlayerStates.DashJumpingState:
			sprite_index = jumpSpr;
			if _previousState != PlayerStates.WallJumpingState && _previousState != PlayerStates.WallDashJumpingState {
				jumpVelocityPerFrame =  jumpSpeed;
			}
			break;
		#endregion
		#region DashState
		case PlayerStates.DashState:
			sprite_index = dashSpr;
			dashingDir = facingDir;
			cachedMoveDir = moveDir;
			DashFramesRemaining = DashTimeFrames;
			break;
		#endregion
		#region FallingState
		case PlayerStates.FallingState:
			sprite_index = jumpSpr;
			yVelocity = 0;
			break;
		#endregion
		#region IdleState
		case PlayerStates.IdleState:
			sprite_index = idleSpr;
			break;
		#endregion
		#region JumpingState
		case PlayerStates.JumpingState:
			sprite_index = jumpSpr;
			if _previousState != PlayerStates.WallJumpingState && _previousState != PlayerStates.WallDashJumpingState {
				jumpVelocityPerFrame =  jumpSpeed;
			}
			break;
		#endregion
		#region SlowWalkingState
		case PlayerStates.SlowWalkingState:
			break;
		#endregion
		#region WalkingState
		case PlayerStates.WalkingState:
			sprite_index = runSpr;
			break;
		#endregion
		#region WallDashJumpingState
		case PlayerStates.WallDashJumpingState:
			sprite_index = jumpSpr;
			wallJumpFramesRemaining = wallDashJumpTimeFrames;
			jumpVelocityPerFrame = jumpSpeed;
			break;
		#endregion
		#region WallJumpingState
		case PlayerStates.WallJumpingState:
			sprite_index = jumpSpr;
			wallJumpFramesRemaining = wallJumpTimeFrames;
			jumpVelocityPerFrame = jumpSpeed;
			break;
		#endregion
		#region WallSlidingState
		case PlayerStates.WallSlidingState:
			sprite_index = wallSlideSpr;
			wallSlideDir = -facingDir;
			cachedMoveDir = moveDir;
			break;
		#endregion
		default:
			break;
	}
	//processState();
}

function processState() {
	//show_debug_message("frame {4}, x {5} | y {6} | xVelocity {2} | yVelocity {3} | subPixel {0} | ySubPixel {1} ", xSubPixel, ySubPixel, xVelocity, yVelocity, frame, x, y);
	show_debug_message("frame {0}, jumpKeyBuffered {1}  ", frame, jumpKeyBuffered);
	switch (state) {
		#region CoyoteTimeState
		case PlayerStates.CoyoteTimeState:
			if dashKeyBuffered { changeState(PlayerStates.DashCoyoteTimeState); 
			} else if jumpKeyPressed { changeState(PlayerStates.JumpingState); 
			} else if coyoteFramesRemaining <= 0 {
				coyoteFramesRemaining = 0;
				changeState(PlayerStates.FallingState);
			} else {
				coyoteFramesRemaining--;
				xVelocity = moveSpeed * moveDir + xSubPixel;
				yVelocity = 0;
				
				removeSubpixels();
				
				//basicMovement();
				
				for (var i = abs(xVelocity); i > 0; i--) {
					if place_meeting(x + sign(xVelocity), y , oWall) {
						xVelocity = 0; 
					} else {
						x += sign(xVelocity);
					}
				}
			}
			break;
		#endregion
		#region DashCoyoteTimeState
		case PlayerStates.DashCoyoteTimeState:
			if coyoteFramesRemaining <= 0 {
				coyoteFramesRemaining = 0;
				changeState(PlayerStates.DashJumpingFallingState);
			} else {
				coyoteFramesRemaining--;
				xVelocity = dashSpeed * dashingDir + xSubPixel;
				yVelocity = 0;
				
				//basicMovement();
				
				removeSubpixels();
				for (var i = abs(xVelocity); i > 0; i--) {
					if place_meeting(x + sign(xVelocity), y , oWall) {
						xVelocity = 0; 
					} else {
						x += sign(xVelocity);
					}
				}
			}
			break;
		#endregion
		#region DashJumpingFallingState
		case PlayerStates.DashJumpingFallingState:
			if place_meeting(x, y + 1, oWall) { changeState(PlayerStates.IdleState); 
			} else {
				xVelocity = dashSpeed * moveDir + xSubPixel;
				yVelocity = yVelocity + ySubPixel + gravityPerFrame >= 
					yTerminalVelocity ? yTerminalVelocity : 
					yVelocity + ySubPixel + gravityPerFrame;
				
				removeSubpixels();
				
				basicMovement();
				
				for (var i = abs(yVelocity); i > 0; i--) {
					if place_meeting(x + moveDir, y , oWall) && !place_meeting(x, y - 1, oWall) && yVelocity > 0 {
						changeState(PlayerStates.WallSlidingState); 
					} else if place_meeting(x , y + sign(yVelocity), oWall) { 
						changeState(PlayerStates.IdleState); 
					} else {
						y += sign(yVelocity);	
					}
				}
			}
			break;
		#endregion
		#region DashJumpingState
		case PlayerStates.DashJumpingState:
			if !jumpKey { changeState(PlayerStates.DashJumpingFallingState); 
			} else if jumpVelocityPerFrame >= 0 { changeState(PlayerStates.DashJumpingFallingState); 
			} else {
				xVelocity = dashSpeed * moveDir + xSubPixel;
				yVelocity = jumpVelocityPerFrame + ySubPixel;
				jumpVelocityPerFrame += gravityPerFrame;
				
				removeSubpixels();
				
				basicMovement();
				
				for (var i = abs(yVelocity); i > 0; i--) {
					if place_meeting(x + moveDir, y , oWall) && 
					  !place_meeting(x, y - 1, oWall) &&
					  yVelocity != 0 &&
					  jumpKeyBuffered {
						changeState(PlayerStates.WallJumpingState); 
					} else if place_meeting(x, y + sign(yVelocity), oWall) {
						yVelocity = 0;
						changeState(PlayerStates.DashJumpingFallingState); 
						return;
					}
					y += sign(yVelocity);
				}
			}
			break;
		#endregion
		#region DashState
		case PlayerStates.DashState:
			if DashFramesRemaining < 0 { changeState(PlayerStates.IdleState); 
			} else if !place_meeting(x, y + 1, oWall) { changeState(PlayerStates.DashCoyoteTimeState); 
			} else if facingDir != dashingDir || (moveDir != cachedMoveDir && cachedMoveDir != 0) { 
				changeState(PlayerStates.IdleState); 
			} else if jumpKeyBuffered { changeState(PlayerStates.DashJumpingState); 
			} else {
				xVelocity = dashSpeed * dashingDir + xSubPixel;
				yVelocity = 0;
				DashFramesRemaining--;
				
				removeSubpixels();
				basicMovement();
			}
			break;
		#endregion
		#region FallingState
		case PlayerStates.FallingState:
			if place_meeting(x, y + 1, oWall) { changeState(PlayerStates.IdleState); 
			} else {
				xVelocity = moveSpeed * moveDir + xSubPixel;
				yVelocity = yVelocity + ySubPixel + gravityPerFrame >= 
					yTerminalVelocity ? yTerminalVelocity : 
					yVelocity + ySubPixel + gravityPerFrame;
				
				removeSubpixels();
				
				basicMovement();
				
				for (var i = abs(yVelocity); i > 0; i--) {
					if place_meeting(x + moveDir, y , oWall) && 
					  !place_meeting(x, y - 1, oWall) && 
					  yVelocity > 0 {
						changeState(PlayerStates.WallSlidingState); 
					} else if place_meeting(x , y + sign(yVelocity), oWall) { 
						changeState(PlayerStates.IdleState); 
					} else {
						y += sign(yVelocity);	
					}
				}
			}
			break;
		#endregion
		#region IdleState
		case PlayerStates.IdleState:
			if dashKeyBuffered { changeState(PlayerStates.DashState); 
			} else if moveDir != 0 { changeState(PlayerStates.WalkingState); 
			} else if jumpKeyBuffered { changeState(PlayerStates.JumpingState); 
			} else if !place_meeting(x, y + 1, oWall) { changeState(PlayerStates.CoyoteTimeState); 
			} else {
				xVelocity = 0;
				yVelocity = 0;
			}
			break;
		#endregion
		#region JumpingState
		case PlayerStates.JumpingState:
			if !jumpKey { changeState(PlayerStates.FallingState); 
			} else if jumpVelocityPerFrame >= 0 { changeState(PlayerStates.FallingState); 
			} else {
				xVelocity = moveSpeed * moveDir + xSubPixel;
				yVelocity = jumpVelocityPerFrame + ySubPixel;
				jumpVelocityPerFrame += gravityPerFrame;
				
				removeSubpixels();
				
				basicMovement();
				
				for (var i = abs(yVelocity); i > 0; i--) {
					if place_meeting(x + moveDir, y , oWall) && 
					  !place_meeting(x, y - 1, oWall) &&
					  yVelocity != 0 &&
					  jumpKeyBuffered {
						changeState(PlayerStates.WallJumpingState); 
					} else if place_meeting(x, y + sign(yVelocity), oWall) {
						yVelocity = 0;
						changeState(PlayerStates.FallingState); 
						return;
					}
					y += sign(yVelocity);
				}
			}
			break;
		#endregion
		#region SlowWalkingState
		case PlayerStates.SlowWalkingState:
			if !place_meeting(x, y + 1, oWall) { changeState(PlayerStates.CoyoteTimeState); }
			break;
		#endregion
		#region WalkingState
		case PlayerStates.WalkingState:
			if moveDir == 0 { changeState(PlayerStates.IdleState); 
			} else if dashKeyBuffered { changeState(PlayerStates.DashState); 
			} else if jumpKeyBuffered { changeState(PlayerStates.JumpingState); 
			} else {
				xVelocity = moveSpeed * moveDir + xSubPixel;
				yVelocity = 0;
				removeSubpixels();
				basicMovement();
			}
			break;
		#endregion
		#region WallDashJumpingState
		case PlayerStates.WallDashJumpingState:
			wallJumpFramesRemaining--;
			
			if !jumpKey { changeState(PlayerStates.DashJumpingFallingState); 
			} else {
				xVelocity = dashSpeed * wallSlideDir + xSubPixel;
				yVelocity = jumpVelocityPerFrame + ySubPixel;
				jumpVelocityPerFrame += gravityPerFrame;
				
				removeSubpixels();
				
				basicMovement();
				
				for (var i = abs(yVelocity); i > 0; i--) {
					if place_meeting(x, y + sign(yVelocity), oWall) {
						yVelocity = 0;
						changeState(PlayerStates.DashJumpingFallingState); 
						return;
					}
					y += sign(yVelocity);
				}
			}
			
			
			if wallJumpFramesRemaining <= 0 {
				wallJumpFramesRemaining = 0;
				if jumpKey { 
					changeState(PlayerStates.DashJumpingState);
				} else {
					changeState(PlayerStates.DashJumpingFallingState);
				}
			}
			break;
		#endregion
		#region WallJumpingState
		case PlayerStates.WallJumpingState:
			wallJumpFramesRemaining--;
			
			if !jumpKey { changeState(PlayerStates.FallingState); 
			} else {
				xVelocity = moveSpeed * wallSlideDir + xSubPixel;
				yVelocity = jumpVelocityPerFrame + ySubPixel;
				jumpVelocityPerFrame += gravityPerFrame;
				
				removeSubpixels();
				
				basicMovement();
				
				for (var i = abs(yVelocity); i > 0; i--) {
					if place_meeting(x, y + sign(yVelocity), oWall) {
						yVelocity = 0;
						changeState(PlayerStates.FallingState); 
						return;
					}
					y += sign(yVelocity);
				}
			}
			
			
			if wallJumpFramesRemaining <= 0 {
				wallJumpFramesRemaining = 0;
				if jumpKey { 
					changeState(PlayerStates.JumpingState);
				} else {
					changeState(PlayerStates.FallingState);
				}
			}
			break;
		#endregion
		#region WallSlidingState
		case PlayerStates.WallSlidingState:
			if place_meeting(x, y + 1, oWall) { changeState(PlayerStates.IdleState); 
			} else if moveDir != cachedMoveDir { changeState(PlayerStates.FallingState); 
			} else if jumpKeyBuffered && dashKeyHeld { changeState (PlayerStates.WallDashJumpingState); 
			} else if jumpKeyBuffered { changeState (PlayerStates.WallJumpingState); 
			} else {
				yVelocity = 0.5 + ySubPixel;
				
				removeSubpixels();
				
				basicMovement();
				
				for (var i = abs(yVelocity); i > 0; i--) {
					if !place_meeting(x + moveDir, y , oWall) {
						changeState(PlayerStates.FallingState); 
					} else if place_meeting(x , y + sign(yVelocity), oWall) { 
						changeState(PlayerStates.IdleState); 
					} else {
						y += sign(yVelocity);	
					}
				}
			}
			break;
		default:
			break;
		#endregion
	}
}

function basicMovement () {
	#region X Movement
	for (var i = abs(xVelocity); i > 0; i--) {
		// Down Slopes
		if !place_meeting(x + sign(xVelocity), y + 1, oWall) {
			if place_meeting(x + sign(xVelocity), y + 2, oWall) {
				y++;
			} else if	
			state != PlayerStates.FallingState &&
			state != PlayerStates.DashJumpingFallingState &&
			state != PlayerStates.WallDashJumpingState &&
			state != PlayerStates.WallJumpingState &&
			state != PlayerStates.JumpingState &&
			state != PlayerStates.DashJumpingState {
				if state == PlayerStates.DashState {
					changeState(PlayerStates.DashCoyoteTimeState); 
				} else {
					changeState(PlayerStates.CoyoteTimeState); 
				}
				return;
			}
		}
		// Up Slopes / Wall Collision
		else if place_meeting(x + sign(xVelocity), y , oWall) {
			if !place_meeting(x + sign(xVelocity), y - 1, oWall) {
				y--;
			} else {
				xVelocity = 0;
			}
		}
		x += sign(xVelocity);
	}
	#endregion
}