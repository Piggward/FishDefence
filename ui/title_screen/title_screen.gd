class_name TitleScreen
extends CanvasLayer
## Title menu: game title, start button, volume and expert mode.

signal start_pressed

@onready var start_button: Button = $StartGameButton/Button
@onready var expert_mode_button: CheckBoxButton = $ExpertModeButton


func _ready() -> void:
	start_button.pressed.connect(start_pressed.emit)
	expert_mode_button.toggled.connect(GameManager.set_expert_mode)
