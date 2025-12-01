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
var new_enemy_paths = {}
signal path_updated
@onready var tile_area = $TileArea/CollisionShape2D
@onready var tile_poly_container = $TilePolyContainer
@onready var tile_poly_container2 = $"../CanvasLayer2/Node2D"

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
			var tile: Tile = TILE.instantiate()
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
	
	var start_to_fin = start_to_finish()
	if start_to_fin.size() == 0:
		print("WOULD BLOCK START TO FINISH")
		_astar.set_point_solid(Vector2i(tile.pos), false)
		_astar.set_point_solid(Vector2i(right.pos), false)
		_astar.set_point_solid(Vector2i(down.pos), false)
		_astar.set_point_solid(Vector2i(down_right.pos), false)
		return false
	
	new_enemy_paths.clear()
	
	var valid_paths: Array[PackedVector2Array]
	valid_paths.append(start_to_fin)
	
	var enemies = enemy_container.alive_enemies
	enemies.reverse()
	for enemy: Enemy in enemies:
		if not enemy.start_reached:
			continue
		var close_tile = get_closest_tile(enemy.global_position)
		var close_pos = close_tile.pos * close_tile.size
		var found = false
		for p in valid_paths:
			var i = p.find(close_pos)
			if i == -1:
				continue
			if p.has(close_pos):
				new_enemy_paths[enemy] = p.slice(i)
				found = true
				break;
		if found:
			continue;
			
		# None of the known paths contained the enemy's tile. 
		# Check the enemy's tile for a valid path
		
		var new_path = _astar.get_point_path(Vector2i(close_tile.pos), Vector2i(finish_position)) 
		if new_path.size() == 0:
			print("THIS WOULD BLOCK")
			_astar.set_point_solid(Vector2i(tile.pos), false)
			_astar.set_point_solid(Vector2i(right.pos), false)
			_astar.set_point_solid(Vector2i(down.pos), false)
			_astar.set_point_solid(Vector2i(down_right.pos), false)
			return false
		else:
			new_enemy_paths[enemy] = new_path
			valid_paths.append(new_path)
	return true
	
func can_find_path():
	var close_tile = get_closest_tile(self.global_position)
	return _astar.get_point_path(Vector2i(close_tile.pos), Vector2i(finish_position)).size() > 0
	
func start_to_finish():
	return _astar.get_point_path(Vector2i(start_tile.pos), Vector2i(finish_position))
	
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
	
	o.reparent(get_tree().root)
	
	path_updated.emit()
	

func set_object_to_tile(o: PlacedObject, tile: Tile):
	tile.object = o
	_astar.set_point_solid(Vector2i(tile.pos), true)
	
func can_pickup(tile: Tile):
	return tile.object != null
	
func show_tiles(value: bool):
	tile_poly_container.visible = value

func get_closest_tile(point: Vector2) -> Tile:
	var x: int = clamp(round(point.x) / 8, 0, grid_array[0].size()-1)
	var y: int = clamp(round(point.y) / 8, 0, grid_array.size()-1)
	return grid_array[y][x]
	#var closest = grid_array[0][0]
	#var closest_dist = abs((grid_array[0][0].global_position - point).length())
	#for i in grid_size.y:
		#for j in grid_size.x:
			#var tile = grid_array[i][j]
			#var dist = abs((tile.global_position - point).length())
			#if dist < closest_dist:
				#closest = tile
				#closest_dist = dist
	#return closest
