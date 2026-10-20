extends PanelContainer
## "Show enemy path" toggle. The path lives in the level, so it is told through EventManager.

@onready var check_button: CheckButton = $HBoxContainer/CheckButton


func _ready():
	check_button.toggled.connect(EventManager.enemy_path_toggled.emit)
