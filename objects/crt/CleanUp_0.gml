/// @description Free video memory

if surface_exists(game_surface) {
	surface_free(game_surface);
}