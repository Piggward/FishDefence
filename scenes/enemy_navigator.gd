class_name EnemyNavigator
extends CharacterBody2D

@export var speed: float
@export var start: Vector2
var tile_grid: TileGrid
var _path = PackedVector2Array()
var _next_point = Vector2()
var _velocity = Vector2()
var path_set = false
var start_reached  = false
var start_tile: Tile

func _ready() -> void:
	tile_grid = get_tree().get_first_node_in_group("TileGrid")
	if not tile_grid.is_node_ready():
		await tile_grid.ready
	#_path = find_path(Vector2(0, 0), tile_grid.finish_position)
	if start != Vector2.ZERO:
		start_tile = tile_grid.get_closest_tile(start)
	else:
		start_reached = true
		start_tile = tile_grid.get_closest_tile(self.global_position)
	_path = find_path(Vector2i(start_tile.pos), Vector2i(tile_grid.finish_position))
	path_set = true
	tile_grid.path_updated.connect(_on_path_updated)
	
func _on_path_updated():
	var close_tile = tile_grid.get_closest_tile(self.global_position)
	find_path(Vector2i(close_tile.pos), Vector2i(tile_grid.finish_position))
	
func find_path(local_start_point, local_end_point):
	#clear_path()
	if not start_reached and path_set:
		return
	_path = tile_grid._astar.get_point_path(Vector2i(local_start_point), Vector2i(local_end_point))
	if _path.size() > 1:
		if abs((_path[1] - global_position).length()) < abs((_path[0] - _path[1]).length()):
			_path.remove_at(0)
	if _path.size() > 0:
		_next_point = _path[0]
	return _path.duplicate()
	
func can_find_path():
	var close_tile = tile_grid.get_closest_tile(self.global_position)
	return tile_grid._astar.get_point_path(Vector2i(close_tile.pos), Vector2i(tile_grid.finish_position)).size() > 0
	
func clear_path():
	if not _path.is_empty():
		_path.clear()
		
func _move_to(local_position):
	var desired_velocity = (local_position - global_position).normalized() * speed
	_velocity = desired_velocity
	global_position += _velocity * get_process_delta_time()
	rotation = _velocity.angle()
	return global_position.distance_to(local_position) < 5


func _physics_process(delta):
	if not path_set:
		return
	var arrived_to_next_point = _move_to(_next_point)
	if arrived_to_next_point:
		if not start_reached:
			start_reached = true
			_path = find_path(Vector2i(start_tile.pos), Vector2i(tile_grid.finish_position))
			return
		_path.remove_at(0)
		if _path.is_empty():
			return
		_next_point = _path[0]

	
