class_name Shop
extends VBoxContainer

@onready var shop_container = $"."
@onready var animation_player = $"../AnimationPlayer"
var open = false
signal open_updated(v: bool)

func _on_mouse_exited():
	if animation_player.is_playing():
		return
	animation_player.play("move_in")
	change_open(false)
	pass # Replace with function body.

func change_open(v: bool):
	open = v
	open_updated.emit(v)
