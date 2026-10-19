class_name ClownDemo
extends TowerDemo
const CLOWN_TOWER = preload("uid://pv46cph2glos")
@onready var tower_2 = $Tower2


func _ready() -> void:
	super()
	await get_tree().create_timer(2).timeout
	var c = CLOWN_TOWER.instantiate()
	add_child(c)
	c.enable()
	c.buff_tower(tower_2)
