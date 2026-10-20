class_name DemoEnemySpawner
extends Node2D
## Spawns enemies that walk in a straight line, for tower demos and the tower arena.
## Enemies that survive past `max_distance` are freed, so a demo left open doesn't pile
## them up.

signal enemy_spawned(enemy: Enemy)
## An enemy walked past `max_distance` alive.
signal enemy_leaked(enemy: Enemy)

const ENEMY = preload("uid://wqreiq6q3r7x")
const SODA_COKE = preload("uid://me80oqeawbyf")
const DEMO_SPEED := 35.0
@export var direction: Vector2
@export var interval: float
## Pixels from the spawner after which an enemy is removed.
@export var max_distance := 120.0
## 0: demo enemies that die on the first hit. 1 and up: that wave's trash, health and
## speed from waves.csv.
@export var wave := 0
var _wave: Wave
var _until_spawn := 0.0


func _ready():
	if wave > 0:
		_wave = GameData.create_waves()[wave - 1]


func _process(delta):
	_until_spawn -= delta
	if _until_spawn <= 0:
		_until_spawn = interval
		spawn_enemy()
	for child in get_children():
		child.position += direction * child.speed * delta
		if child.position.length() > max_distance and not child.is_queued_for_deletion():
			enemy_leaked.emit(child)
			child.queue_free()


func spawn_enemy():
	var e: Enemy = ENEMY.instantiate()
	e.demo = true
	if _wave:
		e.texture = GameData.TRASH[_wave.trash_type]["texture"]
		e.health = _wave.health
		# waves.csv speeds are pixels per minute.
		e.speed = _wave.speed / 60.0
	else:
		e.texture = SODA_COKE
		e.speed = DEMO_SPEED
	add_child(e)
	e.z_index = 99
	enemy_spawned.emit(e)
