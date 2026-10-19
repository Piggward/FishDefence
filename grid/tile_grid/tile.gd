class_name Tile
extends Area2D
## One grid cell. TileGrid creates it and sets `tile_grid`, `pos`, `available` and
## `placeable` before adding it.

@onready var polygon_2d = $Polygon2D
@export var size: Vector2
var object: PlacedObject = null
## Enemies can walk here.
var available: bool = false
## Towers can be built here.
var placeable: bool = false
var pos := Vector2.ZERO
var tile_grid: TileGrid
@onready var collision_polygon_2d = $CollisionPolygon2D


func _ready():
	polygon_2d.scale = size * 0.95
	collision_polygon_2d.polygon = polygon_2d.polygon
	collision_polygon_2d.scale = size
	collision_polygon_2d.position += size / 2
	tile_grid.path_updated.connect(set_color)
	polygon_2d.reparent(tile_grid.tile_poly_container)
	set_color()


func set_color():
	polygon_2d.color = Color("#6bae36") if is_free() else Color("#da6175")


func has_object(o: PlacedObject):
	return object == o


func is_free():
	return available and placeable and object == null


func _on_mouse_entered():
	tile_grid.tile_hovered.emit(self)
