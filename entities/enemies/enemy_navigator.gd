class_name EnemyNavigator
extends PathFollower2D
## Swims from the spawn to the start tile, then follows the TileGrid's path to the goal.

## Pixels per minute.
@export var speed: float
@export var start: Vector2
## Set by whoever spawns the enemy, before adding it to the tree.
var tile_grid: TileGrid
var start_reached = false
var start_tile: Tile
var queue_number: int
var before_start_speed: float


func _ready() -> void:
	if not tile_grid.is_node_ready():
		await tile_grid.ready
	if start != Vector2.ZERO:
		start_tile = tile_grid.get_tile_at(start)
	else:
		start_reached = true
		start_tile = tile_grid.get_closest_tile(global_position)
	tile_grid.path_updated.connect(_on_path_updated)
	path_finished.connect(_on_path_finished)


## Starts the swim to the start tile. Enemies further back in the queue swim slower,
## which spreads the wave out.
func start_moving():
	var start_point := tile_grid.cell_position(start_tile)
	before_start_speed = (global_position - start_point).length() / queue_number
	follow(PackedVector2Array([start_point]))


func get_move_speed() -> float:
	var per_minute = speed if start_reached else before_start_speed * 100
	return per_minute / 60.0


func _on_path_updated():
	if start_reached and tile_grid.new_enemy_paths.has(self):
		follow(tile_grid.new_enemy_paths[self])


func _on_path_finished():
	if not start_reached:
		on_start_reached()


func on_start_reached():
	start_reached = true
	var new_path := tile_grid.find_path(start_tile.pos, tile_grid.finish_position)
	# Skip the first point if we're already closer to the second.
	if new_path.size() > 1 and (new_path[1] - global_position).length() < (new_path[0] - new_path[1]).length():
		new_path.remove_at(0)
	follow(new_path)
