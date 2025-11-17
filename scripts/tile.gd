class_name Tile
extends Area2D

@onready var polygon_2d = $Polygon2D
@export var size: Vector2
var placed_object: PlacedObject = null
var object: PlacedObject = null
var available: bool = false
var pos := Vector2.ZERO 
@onready var collision_polygon_2d = $CollisionPolygon2D
@onready var label = $Label

func _ready():
	polygon_2d.scale = size * 0.95;
	collision_polygon_2d.polygon = polygon_2d.polygon
	collision_polygon_2d.scale = size
	collision_polygon_2d.position += size/2
	available = tile_inside_area(self.global_position)
	set_color()
	
func set_color():
	self.modulate = Color(0, 1, 0, 1) if is_free() else Color(1, 0, 0, 1)

func tile_inside_area(point: Vector2) -> bool:
	var placable_area = get_tree().get_first_node_in_group("PlacableArea")
	var collision_shape = placable_area.get_child(0)
	var shape = collision_shape.shape
	var rect = shape.get_rect().abs()
	point -= collision_shape.position
	return rect.has_point(point)
		
func has_object(o: PlacedObject):
	return object == o
	
func is_free():
	return available and object == null

func _on_mouse_entered():
	PlaceManager.mouse_entered_tile(self)
	pass # Replace with function body.
