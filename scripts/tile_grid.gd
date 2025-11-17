class_name TileGrid
extends Node2D

const TILE = preload("uid://8st3a1p0w0df")

@export var grid_size: Vector2 = Vector2(35, 18)
@export var tile_size := 8;
@export var goal: Marker2D
@export var start: Marker2D
var grid_array = [];
var _astar: AStarGrid2D
var finish_position = Vector2i(16, 16)
var start_tile: Tile
var enemy_container: Node2D
signal path_updated
@onready var tile_area = $TileArea/CollisionShape2D

func _ready():
	enemy_container = get_tree().get_first_node_in_group("EnemyContainer")
	_astar = AStarGrid2D.new()
	var gridsize = tile_area.shape.get_rect().size / 8
	
	grid_size = Vector2(int(gridsize.x), int(gridsize.y))
	_astar.size = grid_size
	_astar.cell_size = Vector2i(tile_size, tile_size)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER 
	_astar.update()
	PlaceManager.pick_up.connect(_on_remove_object)
	
	for i in grid_size.y:
		var row = []
		for j in grid_size.x:
			var tile = TILE.instantiate()
			tile.position = Vector2(j * tile_size, i * tile_size);
			tile.size = Vector2(tile_size, tile_size);
			tile.pos = Vector2(int(j), int(i))
			add_child(tile)
			row.append(tile)
		grid_array.append(row)
	PlaceManager.tile_grid = self
	start_tile = get_closest_tile(start.global_position)
	set_solid_cells()
	var goal_tile = get_closest_tile(goal.global_position)
	finish_position = Vector2(goal_tile.pos)
	PlaceManager.hover_tile = goal_tile
	
func _on_remove_object(o: PlacedObject):
	o.set_object_enabled(false)
	for i in grid_size.y:
		for j in grid_size.x:
			var tile = grid_array[i][j]
			if o == tile.object:
				tile.object = null
				tile.set_color()
				_astar.set_point_solid(Vector2i(tile.pos), false)
	path_updated.emit()

func can_place(o: PlacedObject, tile: Tile) -> bool:
	if tile.pos.x + 1 == grid_size.x || tile.pos.y + 1 == grid_size.y:
		return false
		
	var right = grid_array[tile.pos.y][tile.pos.x + 1]
	var down = grid_array[tile.pos.y + 1][tile.pos.x]
	var down_right = grid_array[tile.pos.y + 1][tile.pos.x + 1]
	
	if not (right.is_free() and down.is_free() and down_right.is_free() and tile.is_free()):
		return false
	
	_astar.set_point_solid(Vector2i(tile.pos), true)
	_astar.set_point_solid(Vector2i(right.pos), true)
	_astar.set_point_solid(Vector2i(down.pos), true)
	_astar.set_point_solid(Vector2i(down_right.pos), true)
	
	if start_to_finish_blocked():
		print("WOULD BLOCK START TO FINISH")
		_astar.set_point_solid(Vector2i(tile.pos), false)
		_astar.set_point_solid(Vector2i(right.pos), false)
		_astar.set_point_solid(Vector2i(down.pos), false)
		_astar.set_point_solid(Vector2i(down_right.pos), false)
		return false
	
	for enemy: Enemy in enemy_container.get_children():
		if not enemy.can_find_path():
			print("THIS WOULD BLOCK")
			_astar.set_point_solid(Vector2i(tile.pos), false)
			_astar.set_point_solid(Vector2i(right.pos), false)
			_astar.set_point_solid(Vector2i(down.pos), false)
			_astar.set_point_solid(Vector2i(down_right.pos), false)
			return false
			
	return true
	
func start_to_finish_blocked():
	return _astar.get_point_path(Vector2i(start_tile.pos), Vector2i(finish_position)).size() == 0
	
func get_start_to_finish():
	return _astar.get_point_path(Vector2i(start_tile.pos), Vector2i(finish_position))

func set_solid_cells():
	for i in grid_size.y:
		for j in grid_size.x:
			var tile = grid_array[i][j]
			if not tile.is_node_ready():
				await tile.ready
			if not tile.available:
				_astar.set_point_solid(Vector2i(tile.pos), true)
				tile.modulate = Color.ANTIQUE_WHITE

func place(o: PlacedObject, tile: Tile):
	o.set_object_enabled(true)
	var right = grid_array[tile.pos.y][tile.pos.x + 1]
	var down = grid_array[tile.pos.y + 1][tile.pos.x]
	var down_right = grid_array[tile.pos.y + 1][tile.pos.x + 1]
	
	set_object_to_tile(o, tile)
	set_object_to_tile(o, right)
	set_object_to_tile(o, down)
	set_object_to_tile(o, down_right)
	
	for i in grid_size.y:
		for j in grid_size.x:
			var t = grid_array[i][j]
			t.set_color()
	path_updated.emit()

func set_object_to_tile(o: PlacedObject, tile: Tile):
	tile.object = o
	_astar.set_point_solid(Vector2i(tile.pos), true)
	
func can_pickup(tile: Tile):
	return tile.object != null
	
func show_tiles(value: bool):
	for i in grid_size.y:
		for j in grid_size.x:
			var tile = grid_array[i][j]
			tile.polygon_2d.visible = value

func get_closest_tile(point: Vector2) -> Tile:
	var closest = grid_array[0][0]
	var closest_dist = abs((grid_array[0][0].global_position - point).length())
	for i in grid_size.y:
		for j in grid_size.x:
			var tile = grid_array[i][j]
			var dist = abs((tile.global_position - point).length())
			if dist < closest_dist:
				closest = tile
				closest_dist = dist
	return closest
