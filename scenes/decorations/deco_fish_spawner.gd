extends Node2D
const DECO_FISH = preload("uid://cbcqu0yqs375q")
@onready var left = $Left
@onready var right = $Right
const RANDOM_SHIT = preload("uid://ve7g61hrtufu")

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
