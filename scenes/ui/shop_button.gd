extends PanelContainer
@onready var shop_container = $"../ShopContainer"

@onready var animation_player = $"../AnimationPlayer"

func _on_mouse_entered():
	if animation_player.is_playing():
		return
	animation_player.play_backwards("move_in")
	shop_container.change_open(true)
	pass # Replace with function body.
