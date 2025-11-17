class_name EnemyContainer
extends Node2D

const TEST_ENEMY = preload("uid://wqreiq6q3r7x")

@export var waves: Array[Wave]
@export var start: Marker2D
var alive_enemies : Array[Enemy] = []
signal wave_cleared

func _ready(): 
	spawn_wave(waves[0])
		
func spawn_wave(wave):
	for i in wave.amount:
		var enemy = TEST_ENEMY.instantiate()
		set_enemy_stats(wave, enemy)
		set_enemy_position(enemy)
		add_child(enemy)
		alive_enemies.append(enemy)
		enemy.died.connect(_on_enemy_died)
		await get_tree().create_timer(0.01).timeout
		
func set_enemy_position(enemy: Enemy):
	var offset = randi_range(100, 200)
	offset *= 1 if randi_range(0, 1) == 1 else -1
	enemy.position.y += offset
		
func set_enemy_stats(wave: Wave, enemy: Enemy):
	enemy.speed = wave.speed
	enemy.health = wave.health
	enemy.start = start.global_position
		
func _on_enemy_died(e: Enemy):
	alive_enemies.erase(e)
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
	spawn_wave(waves[0])
