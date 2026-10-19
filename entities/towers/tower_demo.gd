class_name TowerDemo
extends Node2D
## Root of a tower preview scene (shop card, tutorial). No Placer runs there, so this
## enables the scene's towers itself.


func _ready() -> void:
	for node in find_children("*", "", true, false):
		if node is Tower:
			node.enable()
