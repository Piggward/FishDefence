class_name GameStartButton
extends PanelContainer

signal pressed


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		pressed.emit()
