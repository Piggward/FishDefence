class_name GameStartButton
extends PanelContainer

signal pressed
@onready var volume_c_ontainer = $"../VolumeCOntainer"
@onready var expert_mode_button = $"../ExpertModeButton"

func _on_gui_input(event: InputEvent):
	if event.is_action_pressed("left_click"):
		pressed.emit()
		volume_c_ontainer.visible = false
		expert_mode_button.visible = false
	pass # Replace with function body.
