class_name PlacedObject
extends Area2D

@export var object: Tower


func set_object_enabled(value: bool):
	if value:
		object.enable()
	else:
		object.disable()


func rotate_object():
	if object.can_rotate:
		GameManager.has_rotated = true
		set_object_rotation(object.rotation_degrees + 90)


func set_object_rotation(degrees: float):
	object.rotation_degrees = wrapf(degrees, 0, 360)
	object.sprite_2d.scale.y = -1 if is_equal_approx(object.rotation_degrees, 180) else 1
