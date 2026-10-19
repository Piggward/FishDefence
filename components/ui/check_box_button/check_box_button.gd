class_name CheckBoxButton
extends PanelContainer
## Labelled checkbox; clicking the box toggles it.

signal toggled(checked: bool)

const CHECK_SQUARE_GREY = preload("uid://ccp8hbm6o8sq3")
const CHECK_SQUARE_GREY_CHECKMARK = preload("uid://cxbhbfpyljb53")
@onready var texture_rect = $MarginContainer/HBoxContainer/TextureRect
var checked = false


func _on_texture_rect_gui_input(event):
	if event.is_action_pressed("left_click"):
		checked = !checked
		texture_rect.texture = CHECK_SQUARE_GREY_CHECKMARK if checked else CHECK_SQUARE_GREY
		toggled.emit(checked)
