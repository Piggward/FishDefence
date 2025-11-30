class_name WaveAnimation
extends Sprite2D

signal wave_reached
@onready var animation_player = $Wave/AnimationPlayer
@onready var enemies_node = $EnemiesNode
@onready var wave = $Wave

func play_wave():
	animation_player.play("wave")
	await get_tree().create_timer(1).timeout
	wave_reached.emit()

func add_enemy(e: Enemy):
	enemies_node.add_child(e)
	
func get_enemies():
	return enemies_node.get_children()

func _process(delta):
	#TODO: not each frame
	enemies_node.position = wave.position - Vector2(10, 100)
