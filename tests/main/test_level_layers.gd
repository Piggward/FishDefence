extends TestCase
## Draw order in the level that the visuals depend on.


## Absolute z of a CanvasItem: its own z plus its parents' while z is relative.
func _z(item: CanvasItem) -> int:
	var z := item.z_index
	var node := item
	while node.z_as_relative and node.get_parent() is CanvasItem:
		node = node.get_parent()
		z += node.z_index
	return z


## The underwater overlay samples the screen drawn before it and draws it back distorted.
## The placement grid must draw after it, so the grid stays straight and untinted.
func test_placement_grid_draws_above_the_underwater_overlay():
	await load_level()
	var overlay: CanvasItem = tree.current_scene.get_node("Camera2D/UnderwaterOverlay")
	check(overlay.material.shader.code.contains("hint_screen_texture"), "overlay is the screen-reading water shader")
	var grid: CanvasItem = tile_grid().tile_poly_container
	check(_z(grid) > _z(overlay), "grid z %d above overlay z %d" % [_z(grid), _z(overlay)])
