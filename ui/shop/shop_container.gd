class_name Shop
extends VBoxContainer

@onready var animation_player = $"../AnimationPlayer"
var open = false

func _on_mouse_exited():
	if animation_player.is_playing():
		return
	animation_player.play("move_in")
	change_open(false)

func change_open(v: bool):
	open = v
	EventManager.shop_opened.emit(v)
