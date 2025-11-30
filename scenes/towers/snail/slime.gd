class_name Slime
extends Area2D
@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("slime")
