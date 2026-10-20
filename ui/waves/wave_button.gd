class_name NextWaveButton
extends PanelContainer

## Starts the next wave. Hidden while a wave runs; shown again when it is cleared.

@export var normal_color: Color
@export var hover_color: Color
@onready var content = %Content


func _ready():
	EventManager.wave_cleared.connect(show)
	EventManager.endless_started.connect(show)


func _on_button_pressed():
	hide()
	content.modulate = normal_color
	EventManager.next_wave_requested.emit()


func _on_mouse_entered():
	content.modulate = hover_color


func _on_mouse_exited():
	content.modulate = normal_color
