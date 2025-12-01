class_name EnemyContainer
extends Node2D

const TEST_ENEMY = preload("uid://wqreiq6q3r7x")

@export var waves: Array[Wave]
@export var start: Marker2D
var alive_enemies : Array[Enemy] = []
var unstarted_enemies : Array[Enemy] = []
var current_wave: int = -1
var next_wave_button: NextWaveButton
signal wave_cleared
@onready var enemy_spawn_rect = $EnemySpawnArea/CollisionShape2D
var wave_animation: WaveAnimation
var endless_mode = false
signal wave_start(number: int)
@onready var wave_clear = $WaveClear
var last_wave_health: int = 0

func _ready(): 
	next_wave_button = get_tree().get_first_node_in_group("NextWaveButton")
	wave_animation = get_tree().get_first_node_in_group("WaveAnimation")
	next_wave_button.pressed.connect(_on_next_wave_pressed)
	load_waves("res://data/waves.json")
	EventManager.endless_started.connect(_on_endless_started)
	
func _on_endless_started():
	endless_mode = true
	last_wave_health = waves[waves.size() - 1].health
	
func spawn_endless_wave():
	var wave_no = wrap(current_wave, 0,  waves.size())
	var wave = waves[wave_no]
	var waves_over = current_wave + 1 - waves.size()
	wave.health = last_wave_health * pow(1.07, waves_over)
	spawn_wave(wave)
	
func spawn_wave(wave: Wave):
	var total_enemis = wave.amount

	for i in total_enemis:
		var enemy: Enemy = TEST_ENEMY.instantiate()
		enemy.queue_number = i + 1
		set_enemy_stats(wave, enemy)
		set_enemy_position(enemy)
		wave_animation.add_enemy(enemy)
		alive_enemies.append(enemy)
		unstarted_enemies.append(enemy)
		enemy.died.connect(_on_enemy_died)
		
	wave_animation.play_wave()
	await wave_animation.wave_reached
	for child in wave_animation.get_enemies():
		if child is Enemy:
			child.reparent(self)
			child.can_start = true
			child.set_start_speed()
		
		
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
	enemy.texture = wave.get_texture()
	enemy.bounty = wave.enemy_bounty
	enemy.recycle_material = wave.get_material()
	if GameManager.easy_mode:
		enemy.health *= 0.7
		enemy.speed *= 0.8
		
func _on_enemy_died(e: Enemy, killed: bool = true):
	alive_enemies.erase(e)
	if killed:
		GameManager.add_bounty(e.bounty)
	if alive_enemies.size() == 0:
		wave_cleared.emit()
		on_wave_cleared()
		
func on_wave_cleared():
	if current_wave == waves.size() -1 and not endless_mode:
		EventManager.win.emit()
		return
	wave_clear.play()
	next_wave_button.visible = true
	if not endless_mode:
		GameManager.add_bounty(waves[current_wave].wave_bounty)
	else:
		GameManager.add_bounty(waves[waves.size() - 1].wave_bounty)
	
func _on_next_wave_pressed():
	next_wave_button.visible = false
	current_wave += 1 
	GameManager.current_wave = current_wave + 1
	var wds = get_tree().get_first_node_in_group("CurrentWaveDisplay")
	wds.show_new_wave(current_wave + 1)
	#wds.get_child(0).text = "Wave: " + str(current_wave + 1)
	if endless_mode:
		spawn_endless_wave()
	else:
		spawn_wave(waves[current_wave])
	wave_start.emit(current_wave + 1)
	

func load_waves(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return

	var data = JSON.parse_string(file.get_as_text())
	if !(data is Array):
		push_error("Invalid JSON format (expected array).")
		return

	waves.clear()

	for item in data:
		if !(item is Dictionary):
			push_warning("Skipping non-dictionary entry in JSON.")
			continue

		var wave := Wave.new()		
		
		wave.speed = item["speed"]
		wave.health = item["health"]
		wave.enemy_bounty = item["enemy_bounty"]
		wave.wave_bounty = item["wave_bounty"]
		wave.name = item["texture"]
		wave.amount = item["amount"]
			
		waves.append(wave)
