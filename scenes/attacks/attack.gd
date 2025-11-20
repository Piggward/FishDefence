class_name AttackAnimation
extends Node2D

@onready var animation_player = $AnimationPlayer
signal hit

func _ready():
	animation_player.play("attack_3")
	await animation_player.animation_finished
	self.queue_free()

func attack_hit():
	hit.emit()
