class_name ClownDemo
extends Node2D
const CLOWN_TOWER = preload("uid://pv46cph2glos")
@onready var tower_2 = $Tower2


func _ready():
	await get_tree().create_timer(2).timeout
	var c = CLOWN_TOWER.instantiate()
	c.demo = true
	add_child(c)
	c.buff_tower(tower_2)
