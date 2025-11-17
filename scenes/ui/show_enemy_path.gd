extends PanelContainer

@onready var check_button: CheckButton = $HBoxContainer/CheckButton

func _ready():
	var path = get_tree().get_first_node_in_group("EnemyPath")
	check_button.toggled.connect(func(a): path.visible = a);
