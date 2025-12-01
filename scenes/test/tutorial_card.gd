class_name TutorialCard
extends Control

@onready var sub_viewport_container = $SubViewportContainer
@export var title: String
@export var text: String
@export var last: bool = false
@export var has_viewport: bool
@export var packed_scene: PackedScene = null 
@export var zoom: Vector2
@onready var tutorial_name = $PanelContainer/VBoxContainer/TitleContainer/Name
@onready var description_label = $PanelContainer/VBoxContainer/MarginContainer/BodyContainer/VBoxContainer/PanelContainer/MarginContainer/DescriptionLabel
@onready var next_button = $PanelContainer/VBoxContainer/MarginContainer2/Control/NextButton
@onready var margin_container_2 = $PanelContainer/VBoxContainer/MarginContainer2
@onready var label = $PanelContainer/VBoxContainer/MarginContainer2/Control2/Label
@onready var texture_rect = $PanelContainer/VBoxContainer/MarginContainer/BodyContainer/VBoxContainer/TextureContainer/TextureRect

const DEMO_VIEWPORT = preload("uid://besqxivag63uh")
signal next

func _ready():
	description_label.text = text
	tutorial_name.text = title 
	if has_viewport:
		var sub_viewport = DEMO_VIEWPORT.instantiate()
		sub_viewport.add_child(packed_scene.instantiate())
		sub_viewport.zoom = zoom
		sub_viewport_container.add_child(sub_viewport)
		texture_rect.texture.set_viewport_path_in_scene("SubViewportContainer/SubViewport")
	else:
		texture_rect.visible = false
	if last:
		label.text = "Start"
	


func _on_texture_rect_gui_input(event):
	if event.is_action_pressed("left_click"):
		next.emit()
	pass # Replace with function body.
	

func _on_margin_container_2_mouse_entered():
	margin_container_2.modulate = Color("ff8e58")
	pass # Replace with function body.


func _on_margin_container_2_mouse_exited():
	margin_container_2.modulate = Color.WHITE
	pass # Replace with function body.
