class_name RangeCollision
extends CollisionShape2D
@onready var range_polygon = $RangePolygon

func toggle_show(value: bool):
	range_polygon.visible = value
