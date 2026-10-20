class_name CheckBoxButton
extends PanelContainer
## Labelled checkbox; clicking the box toggles it. A flat toggle Button over the box
## takes the clicks. Instance check_box_button.tscn and set `text` and Tooltip Text.

signal toggled(checked: bool)

const CHECK_SQUARE_GREY = preload("uid://ccp8hbm6o8sq3")
const CHECK_SQUARE_GREY_CHECKMARK = preload("uid://cxbhbfpyljb53")
@export var text: String
@onready var label: Label = $MarginContainer/HBoxContainer/Label
@onready var texture_rect: TextureRect = $MarginContainer/HBoxContainer/TextureRect
@onready var button: Button = $MarginContainer/HBoxContainer/TextureRect/Button
var checked: bool:
	get:
		return button.button_pressed


func _ready() -> void:
	label.text = text
	# The label takes the mouse, so it shows this node's tooltip too.
	label.tooltip_text = tooltip_text


func _on_button_toggled(on: bool) -> void:
	texture_rect.texture = CHECK_SQUARE_GREY_CHECKMARK if on else CHECK_SQUARE_GREY
	toggled.emit(on)
