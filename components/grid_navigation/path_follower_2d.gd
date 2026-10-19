class_name PathFollower2D
extends CharacterBody2D
## Moves through a list of points with move_and_slide, never stepping past the next point.
## After the last point is reached it keeps holding that point until given a new path.

signal path_finished

## Pixels per second. Override get_move_speed() to compute it per frame instead.
@export var move_speed := 100.0
## Distance at which a point counts as reached.
@export var arrive_distance := 3.0
var path := PackedVector2Array()
var following := false
var _finished := false


func follow(new_path: PackedVector2Array) -> void:
	path = new_path
	following = not path.is_empty()
	_finished = false


func get_move_speed() -> float:
	return move_speed


func _physics_process(delta):
	if not following:
		return
	var target := path[0]
	var to_target := target - global_position
	velocity = to_target.normalized() * minf(get_move_speed(), to_target.length() / delta)
	move_and_slide()
	if global_position.distance_to(target) < arrive_distance:
		if path.size() > 1:
			path.remove_at(0)
		elif not _finished:
			_finished = true
			path_finished.emit()
