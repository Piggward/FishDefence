extends Node2D

func _ready():
	for child in get_children():
		if child is GPUParticles2D:
			child.emitting = true
			
	await get_tree().create_timer(1).timeout
	
	get_tree().change_scene_to_file("res://main/level/level.tscn")
