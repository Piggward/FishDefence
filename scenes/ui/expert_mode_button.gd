class_name ExpertModeButton
extends PanelContainer

@onready var texture_rect = $MarginContainer/HBoxContainer/TextureRect

const CHECK_SQUARE_GREY = preload("uid://ccp8hbm6o8sq3")
const CHECK_SQUARE_GREY_CHECKMARK = preload("uid://cxbhbfpyljb53")
var checked = false


func _on_texture_rect_gui_input(event):
	if event.is_action_pressed("left_click"):
		checked = !checked
		GameManager.easy_mode = checked
		update_texture()
	pass # Replace with function body.
	
func update_texture():
	if checked:
		texture_rect.texture = CHECK_SQUARE_GREY_CHECKMARK
	else: 
		texture_rect.texture = CHECK_SQUARE_GREY
	
