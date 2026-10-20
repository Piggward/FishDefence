extends PanelContainer
## The "Shop" tab at the screen edge; hovering it opens the shop.

@export var shop: Shop


func _on_mouse_entered():
	shop.set_open(true)
