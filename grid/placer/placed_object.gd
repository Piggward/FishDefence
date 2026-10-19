class_name PlacedObject
extends Area2D
## Holds a tower while it is carried or placed. A carried tower is drawn as a see-through
## ghost above everything else, with its range shown.

const GHOST_TINT := Color(0.5, 0.5, 0.5, 0.35)
## Draws a tower being moved over the placed ones.
const GHOST_Z_INDEX := 999

@export var object: Tower


func set_object_enabled(value: bool) -> void:
	modulate = Color.WHITE if value else GHOST_TINT
	z_index = 0 if value else GHOST_Z_INDEX
	object.show_range(not value)
	if value:
		object.enable()
	else:
		object.disable()


func rotate_object() -> void:
	if object.can_rotate:
		GameManager.has_rotated = true
		set_object_rotation(object.rotation_degrees + 90)


func set_object_rotation(degrees: float) -> void:
	object.rotation_degrees = wrapf(degrees, 0, 360)
	object.sprite_2d.scale.y = -1 if is_equal_approx(object.rotation_degrees, 180) else 1
