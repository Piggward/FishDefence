class_name TutorialCard
extends Control
## One tutorial step: title, text, an optional live demo and a Next/Start button.

@export var title: String
@export var text: String
@export var last: bool = false
@export var packed_scene: PackedScene = null
@onready var tutorial_name = %NameLabel
@onready var description_label = %DescriptionLabel
@onready var next_row = %NextRow
@onready var next_label = %NextLabel
@onready var icon_container = %IconContainer
@onready var preview: ScenePreview = %ScenePreview

signal next


func _ready():
	description_label.text = text
	tutorial_name.text = title
	icon_container.visible = false
	if packed_scene:
		preview.show()
		preview.show_scene(packed_scene)
	if last:
		next_label.text = "Start"


func _on_next_button_pressed():
	next.emit()


func _on_next_button_mouse_entered():
	next_row.modulate = Color("ff8e58")


func _on_next_button_mouse_exited():
	next_row.modulate = Color.WHITE
