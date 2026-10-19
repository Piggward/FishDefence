class_name EnemyContainer
extends Node2D

const ENEMY = preload("uid://wqreiq6q3r7x")
const ENDLESS_HEALTH_GROWTH := 1.07

@export var start: Marker2D
@export var tile_grid: TileGrid
@export var wave_animation: WaveAnimation
var waves: Array[Wave] = []
var alive_enemies : Array[Enemy] = []
var current_wave: int = -1
@onready var enemy_spawn_rect = $EnemySpawnArea/CollisionShape2D
var endless_mode = false
@onready var wave_clear = $WaveClear
var last_wave_health: int = 0


func _ready():
	EventManager.next_wave_requested.connect(_on_next_wave_requested)
	waves = GameData.create_waves()
	EventManager.endless_started.connect(_on_endless_started)


func _on_endless_started():
	endless_mode = true
	last_wave_health = waves[waves.size() - 1].health


func spawn_endless_wave():
	var wave = waves[wrap(current_wave, 0, waves.size())]
	var waves_over = current_wave + 1 - waves.size()
	wave.health = last_wave_health * pow(ENDLESS_HEALTH_GROWTH, waves_over)
	spawn_wave(wave)


func spawn_wave(wave: Wave):
	for i in wave.amount:
		var enemy: Enemy = ENEMY.instantiate()
		enemy.queue_number = i + 1
		enemy.tile_grid = tile_grid
		set_enemy_stats(wave, enemy)
		set_enemy_position(enemy)
		wave_animation.add_enemy(enemy)
		alive_enemies.append(enemy)
		enemy.died.connect(_on_enemy_died)

	wave_animation.play_wave()
	await wave_animation.wave_reached
	for child in wave_animation.get_enemies():
		if child is Enemy:
			child.reparent(self)
			child.start_moving()


func set_enemy_position(enemy: Enemy):
	var rect = enemy_spawn_rect.shape.get_rect().size
	enemy.position = Vector2(randf_range(0, rect.x), randf_range(0, rect.y))


func set_enemy_stats(wave: Wave, enemy: Enemy):
	var trash: Dictionary = GameData.TRASH[wave.trash_type]
	enemy.speed = wave.speed
	enemy.health = wave.health
	enemy.start = start.global_position
	enemy.texture = trash["texture"]
	enemy.recycle_material = trash["material"]
	enemy.bounty = wave.enemy_bounty
	if GameManager.easy_mode:
		enemy.health *= 0.7
		enemy.speed *= 0.8


func _on_enemy_died(e: Enemy, killed: bool = true):
	alive_enemies.erase(e)
	if killed:
		GameManager.add_bounty(e.bounty)
	# After a loss the game over screen owns the flow; no win or next wave.
	if alive_enemies.size() == 0 and not GameManager.is_lost():
		on_wave_cleared()


func on_wave_cleared():
	if current_wave == waves.size() - 1 and not endless_mode:
		EventManager.win.emit()
		return
	wave_clear.play()
	EventManager.wave_cleared.emit()
	GameManager.add_bounty(waves[min(current_wave, waves.size() - 1)].wave_bounty)


func _on_next_wave_requested():
	current_wave += 1
	GameManager.current_wave = current_wave + 1
	EventManager.wave_started.emit(current_wave + 1)
	if endless_mode:
		spawn_endless_wave()
	else:
		spawn_wave(waves[current_wave])
