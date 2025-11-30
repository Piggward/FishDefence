class_name Tile
extends Area2D

@onready var polygon_2d = $Polygon2D
@export var size: Vector2
var placed_object: PlacedObject = null
var object: PlacedObject = null
var available: bool = false
var placeable: bool = false
var pos := Vector2.ZERO 
var tile_grid: TileGrid
@onready var collision_polygon_2d = $CollisionPolygon2D

func _ready():
	polygon_2d.scale = size * 0.95;
	collision_polygon_2d.polygon = polygon_2d.polygon
	collision_polygon_2d.scale = size
	collision_polygon_2d.position += size/2
	if tile_inside_area(self.global_position, get_tree().get_first_node_in_group("ObstacleArea")):
		available = false
		placeable = false
	else:
		available = tile_inside_area(self.global_position, 	get_tree().get_first_node_in_group("NavigationArea"))
		placeable = tile_inside_area(self.global_position, get_tree().get_first_node_in_group("PlaceableArea"))
	tile_grid = get_tree().get_first_node_in_group("TileGrid")
	tile_grid.path_updated.connect(set_color)
	polygon_2d.reparent(tile_grid.tile_poly_container)
	set_color()
	
func set_color():
	polygon_2d.color = Color("#6bae36") if is_free() else Color("#da6175") 

func tile_inside_area(point: Vector2, area: Area2D) -> bool:
	for e in area.get_children():
		var collision_shape = e
		var p = point
		var shape = collision_shape.shape
		var rect = shape.get_rect().abs()
		p -= collision_shape.position
		if rect.has_point(p):
			return true
			 
	return false
		
func has_object(o: PlacedObject):
	return object == o
	
func is_free():
	return available and placeable and object == null

func _on_mouse_entered():
	PlaceManager.mouse_entered_tile(self)
	pass # Replace with function body.
