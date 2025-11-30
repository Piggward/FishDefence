class_name DemoEnemySpawner
extends Node2D

const TEST_ENEMY = preload("uid://wqreiq6q3r7x")
const SODA_COKE = preload("uid://me80oqeawbyf")
@export var direction: Vector2
@export var interval: float
func _ready():
	spawn_enemy()
	
func spawn_enemy():
	var e: Enemy = TEST_ENEMY.instantiate()
	e.texture = SODA_COKE
	e.demo = true
	e.speed = 35
	add_child(e)
	e.z_index = 99
	await get_tree().create_timer(interval).timeout
	spawn_enemy()
	
func _process(delta):
	for child in get_children():
		child.position += direction * child.speed * delta
