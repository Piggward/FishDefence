class_name EnemyContainer
extends Node2D

const TEST_ENEMY = preload("uid://wqreiq6q3r7x")

@export var waves: Array[Wave]
@export var start: Marker2D
var alive_enemies : Array[Enemy] = []
var unstarted_enemies : Array[Enemy] = []
var current_wave: int = 0
signal wave_cleared
@onready var enemy_spawn_rect = $EnemySpawnArea/CollisionShape2D

func _ready(): 
	spawn_wave(waves[current_wave])
		
func spawn_wave(wave: Wave):
	var total_enemis = wave.batches.reduce(func(accum, batch): return accum + batch.amount, 0);

	for i in total_enemis:
		var enemy: Enemy = TEST_ENEMY.instantiate()
		set_enemy_stats(wave, enemy)
		set_enemy_position(enemy)
		add_child(enemy)
		alive_enemies.append(enemy)
		unstarted_enemies.append(enemy)
		enemy.died.connect(_on_enemy_died)
		
	for j in wave.batches.size():
		var batch: Batch = wave.batches[j]
		for k in batch.amount:
			unstarted_enemies[0].can_start = true
			unstarted_enemies = unstarted_enemies.slice(1)
		await get_tree().create_timer(batch.time_before_next_batch).timeout
		
func set_enemy_position(enemy: Enemy):
	var rect = enemy_spawn_rect.shape.get_rect().size
	var length = rect.x
	var height = rect.y
	
	var rand_x = randf_range(0, length)
	var rand_y = randf_range(0, height)

	enemy.position = Vector2(rand_x, rand_y)
		
func set_enemy_stats(wave: Wave, enemy: Enemy):
	enemy.speed = wave.speed
	enemy.health = wave.health
	enemy.start = start.global_position
		
func _on_enemy_died(e: Enemy, killed: bool = true):
	alive_enemies.erase(e)
	if killed:
		GameManager.add_bounty(e.bounty)
	if alive_enemies.size() == 0:
		wave_cleared.emit()
		on_wave_cleared()
		
func on_wave_cleared():
	print("Well done! Spawning next wave in 3")
	await get_tree().create_timer(1).timeout
	print("2")
	await get_tree().create_timer(1).timeout
	print("1")
	await get_tree().create_timer(1).timeout
	current_wave += 1 
	spawn_wave(waves[current_wave])
