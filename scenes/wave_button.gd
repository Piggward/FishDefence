class_name NextWaveButton
extends PanelContainer

signal pressed
@export var normal_color: Color
@export var hover_color: Color
@onready var v_box_container = $MarginContainer/HBoxContainer/VBoxContainer

func _ready():
	EventManager.endless_started.connect(func():self.visible = true)

func _on_gui_input(event: InputEvent):
	if event.is_action_pressed("left_click"):
		pressed.emit()
		v_box_container.modulate = normal_color
	pass # Replace with function body.


func _on_mouse_entered():
	v_box_container.modulate = hover_color
	pass # Replace with function body.

func _on_mouse_exited():
	v_box_container.modulate = normal_color
	pass # Replace with function body.
	
