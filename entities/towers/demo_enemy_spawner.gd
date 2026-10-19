class_name DemoEnemySpawner
extends Node2D
## Spawns enemies that walk in a straight line through a tower demo. Enemies that survive
## past `max_distance` are freed, so a demo left open doesn't pile them up.

const ENEMY = preload("uid://wqreiq6q3r7x")
const SODA_COKE = preload("uid://me80oqeawbyf")
@export var direction: Vector2
@export var interval: float
## Pixels from the spawner after which an enemy is removed.
@export var max_distance := 120.0
var _until_spawn := 0.0


func _process(delta):
	_until_spawn -= delta
	if _until_spawn <= 0:
		_until_spawn = interval
		spawn_enemy()
	for child in get_children():
		child.position += direction * child.speed * delta
		if child.position.length() > max_distance:
			child.queue_free()


func spawn_enemy():
	var e: Enemy = ENEMY.instantiate()
	e.texture = SODA_COKE
	e.demo = true
	e.speed = 35
	add_child(e)
	e.z_index = 99
