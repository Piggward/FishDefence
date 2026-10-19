class_name TileGrid
extends Node2D

const TILE = preload("uid://8st3a1p0w0df")

@export var grid_size: Vector2 = Vector2(35, 18)
@export var tile_size := 8
@export var goal: Marker2D
@export var start: Marker2D
@export var enemy_container: EnemyContainer
## Shapes marking where enemies can walk.
@export var navigation_area: Area2D
## Shapes where nothing can walk or be built, even inside navigation_area.
@export var obstacle_area: Area2D
## Shapes marking where towers can be built.
@export var placeable_area: Area2D
var grid_array = []
var pathfinder: GridPathfinder
## World position of cell (0, 0): the top-left corner of TileArea's rectangle.
var origin: Vector2
var finish_position = Vector2i(16, 16)
var start_tile: Tile
var goal_tile: Tile
## Enemy -> its new path, recomputed whenever the grid changes; read on path_updated.
var new_enemy_paths = {}
signal path_updated
## The mouse moved onto a tile.
signal tile_hovered(tile: Tile)
@onready var tile_area = $TileArea/CollisionShape2D
@onready var tile_poly_container = $TilePolyContainer


func _ready():
	var area_rect: Rect2 = tile_area.shape.get_rect()
	origin = tile_area.global_transform * area_rect.position
	var gridsize = area_rect.size / tile_size
	grid_size = Vector2(int(gridsize.x), int(gridsize.y))
	pathfinder = GridPathfinder.new(Vector2i(grid_size), Vector2(tile_size, tile_size), origin)

	for i in grid_size.y:
		var row = []
		for j in grid_size.x:
			var tile: Tile = TILE.instantiate()
			tile.position = to_local(origin) + Vector2(j * tile_size, i * tile_size)
			tile.size = Vector2(tile_size, tile_size)
			tile.pos = Vector2(int(j), int(i))
			tile.tile_grid = self
			var world := origin + Vector2(j, i) * tile_size
			if is_inside_area(world, obstacle_area):
				tile.available = false
				tile.placeable = false
			else:
				tile.available = is_inside_area(world, navigation_area)
				tile.placeable = is_inside_area(world, placeable_area)
			add_child(tile)
			row.append(tile)
		grid_array.append(row)
	start_tile = get_tile_at(start.global_position)
	set_solid_cells()
	goal_tile = get_tile_at(goal.global_position)
	finish_position = Vector2(goal_tile.pos)


func remove_object(o: PlacedObject):
	o.set_object_enabled(false)
	for row in grid_array:
		for tile in row:
			if o == tile.object:
				tile.object = null
				tile.set_color()
				pathfinder.set_solid(Vector2i(tile.pos), false)
	# Opening cells can't block anyone; this only lets enemies take the shorter route.
	_compute_enemy_paths()
	path_updated.emit()


## The 2x2 cells a tower placed on `tile` covers, or [] if it doesn't fit inside the grid.
func _footprint(tile: Tile) -> Array:
	if tile.pos.x + 1 >= grid_size.x or tile.pos.y + 1 >= grid_size.y:
		return []
	return [
		tile,
		grid_array[tile.pos.y][tile.pos.x + 1],
		grid_array[tile.pos.y + 1][tile.pos.x],
		grid_array[tile.pos.y + 1][tile.pos.x + 1],
	]


func _set_solid(cells: Array, solid: bool):
	for c in cells:
		pathfinder.set_solid(Vector2i(c.pos), solid)


## Checks that a tower on `tile` keeps a path open for the spawn and every enemy.
## On success the cells stay solid and new_enemy_paths holds the paths to switch to.
func can_place(tile: Tile) -> bool:
	var cells := _footprint(tile)
	if cells.is_empty() or not cells.all(func(c): return c.is_free()):
		return false

	_set_solid(cells, true)
	if get_start_to_finish().size() == 0 or not _compute_enemy_paths():
		_set_solid(cells, false)
		return false
	return true


## Recomputes paths for enemies on the grid into new_enemy_paths. Returns false if some
## enemy has no path to the goal.
func _compute_enemy_paths() -> bool:
	new_enemy_paths.clear()
	for enemy: Enemy in enemy_container.alive_enemies:
		if not enemy.start_reached:
			continue
		# Keep the enemy's current heading so it doesn't turn just because its path was redone.
		var heading := Vector2i(enemy.velocity.normalized().round())
		var new_path := find_path(get_closest_tile(enemy.global_position).pos, finish_position, heading)
		if new_path.is_empty():
			return false
		new_enemy_paths[enemy] = new_path
	return true


## True if the world `point` lies in one of `area`'s shapes, wherever the area and shapes sit.
func is_inside_area(point: Vector2, area: Area2D) -> bool:
	for collision_shape in area.get_children():
		if collision_shape is CollisionShape2D and collision_shape.shape:
			var local: Vector2 = collision_shape.global_transform.affine_inverse() * point
			if collision_shape.shape.get_rect().has_point(local):
				return true
	return false


func get_start_to_finish() -> PackedVector2Array:
	return find_path(start_tile.pos, finish_position)


func find_path(from_cell: Vector2, to_cell: Vector2, heading := Vector2i.ZERO) -> PackedVector2Array:
	return pathfinder.find_path(Vector2i(from_cell), Vector2i(to_cell), heading)


## The world position path points use for this tile.
func cell_position(tile: Tile) -> Vector2:
	return pathfinder.cell_to_point(Vector2i(tile.pos))


func set_solid_cells():
	for row in grid_array:
		for tile in row:
			if not tile.available:
				pathfinder.set_solid(Vector2i(tile.pos))
				tile.modulate = Color.ANTIQUE_WHITE


func place(o: PlacedObject, tile: Tile):
	for cell in _footprint(tile):
		cell.object = o
		pathfinder.set_solid(Vector2i(cell.pos))
	o.set_object_enabled(true)
	path_updated.emit()


func can_pickup(tile: Tile):
	return tile != null and tile.object != null


func show_tiles(value: bool):
	tile_poly_container.visible = value


## The tile whose path point is nearest to `point`. Used for enemies, which walk on path points.
func get_closest_tile(point: Vector2) -> Tile:
	return _tile_at_cell(((point - origin) / tile_size).round())


## The tile whose hover area contains `point`. Used for the start and goal markers.
func get_tile_at(point: Vector2) -> Tile:
	return _tile_at_cell(((point - origin) / tile_size).floor())


func _tile_at_cell(cell: Vector2) -> Tile:
	var x: int = clamp(int(cell.x), 0, grid_array[0].size() - 1)
	var y: int = clamp(int(cell.y), 0, grid_array.size() - 1)
	return grid_array[y][x]
