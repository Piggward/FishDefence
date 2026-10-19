extends PanelContainer

@export var enemy_path: CanvasItem
@onready var check_button: CheckButton = $HBoxContainer/CheckButton


func _ready():
	check_button.toggled.connect(func(on): enemy_path.visible = on)
