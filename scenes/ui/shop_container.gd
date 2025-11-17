extends VBoxContainer

@onready var shop_container = $"."
@onready var animation_player = $"../AnimationPlayer"

func _on_mouse_exited():
	if animation_player.is_playing():
		return
	animation_player.play("move_in")
	pass # Replace with function body.
