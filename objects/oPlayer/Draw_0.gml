sprite_index = moveDir != 0  ? walkSpr : idleSpr;
sprite_index = moveIndex && moveDir == 0 ? danceSpr : sprite_index;
sprite_index = moveIndex && moveDir != 0 ? runSpr : sprite_index;
sprite_index = !grounded ? jumpSpr : sprite_index;

draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * facingDir, image_yscale, image_angle, image_blend, image_alpha);