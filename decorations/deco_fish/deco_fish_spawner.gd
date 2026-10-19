class_name DecoFishSpawner
extends Node2D
## Background fish and trash. While spawning (title screen) a school of fish swims in every
## `interval` seconds.

const DECO_FISH = preload("uid://cbcqu0yqs375q")
const RANDOM_SHIT = preload("uid://ve7g61hrtufu")
const SCHOOL_SIZE := 25

@export var interval := 4.0
var _timer := Timer.new()

@onready var left = $Left
@onready var right = $Right


func _ready() -> void:
	_timer.wait_time = interval
	_timer.timeout.connect(spawn_fishes.bind(SCHOOL_SIZE))
	add_child(_timer)


func start_spawning() -> void:
	spawn_fishes(SCHOOL_SIZE)
	_timer.start()


func stop_spawning() -> void:
	_timer.stop()


func spawn_fish():
	var f: DecoFish = DECO_FISH.instantiate()
	var cf = randi_range(1, 2)
	if cf == 1:
		f.direction = -1
		f.position = right.position
		f.position.y += randi_range(-100, 100)
		f.position.x += randi_range(0, 150)
		add_child(f)
	else:
		f.direction = 1
		f.position = left.position
		f.position.y += randi_range(-100, 100)
		f.position.x += randi_range(-150, 0)
		add_child(f)

func spawn_random_shit():
	var s = RANDOM_SHIT.instantiate()
	s.position = left.position
	s.position.y += randi_range(-100, 100)
	s.position.x += randi_range(-50, 0)
	add_child(s)
	
func spawn_rs(i):
	for j in i:
		spawn_random_shit()

func spawn_fishes(i):
	for j in i:
		spawn_fish()
	
func kill_fishes():
	for child in get_children():
		if child is DecoFish:
			child.die()
