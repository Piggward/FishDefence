extends Node2D
const BUBBLE_PARTICLES = preload("uid://dq2iwrtbcm1d6")
const TEST_NAVIGATION_WITH_TILESET = preload("uid://drkhpej01r8vi")

func _ready():
	for child in get_children():
		if child is GPUParticles2D:
			child.emitting = true
			
	await get_tree().create_timer(1).timeout
	
	get_tree().change_scene_to_file("res://scenes/test_navigation_with_tileset.tscn")
