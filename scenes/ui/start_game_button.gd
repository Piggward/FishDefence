class_name GameStartButton
extends PanelContainer

signal pressed

func _on_gui_input(event: InputEvent):
	if event.is_action_pressed("left_click"):
		pressed.emit()
	pass # Replace with function body.
