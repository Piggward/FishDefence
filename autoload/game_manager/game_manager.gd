extends Node

const START_BUCKS := 250
const START_HEALTH := 100

var eco_bucks = START_BUCKS
var health = START_HEALTH
var skip_intro = false
var easy_mode: bool = true
var has_rotated: bool = false
var tutorial_done: bool = false
var current_wave = 0


## Resets run state and reloads the level. Everything spawned during a run lives in the
## level scene, so reloading it frees all of it.
func restart():
	eco_bucks = START_BUCKS
	health = START_HEALTH
	skip_intro = true
	tutorial_done = true
	current_wave = 0
	Engine.time_scale = 1.0
	get_tree().root.process_mode = Node.PROCESS_MODE_PAUSABLE
	get_tree().reload_current_scene()


func player_damage(damage: int):
	var was_alive = health > 0
	health -= damage
	EventManager.health_updated.emit(health)
	if was_alive and health <= 0:
		EventManager.lose.emit()


func is_lost() -> bool:
	return health <= 0


func can_buy(cost: int) -> bool:
	return tutorial_done and cost <= eco_bucks


func spend(cost: int):
	set_eco_bucks(eco_bucks - cost)


func add_bounty(bounty: int):
	set_eco_bucks(eco_bucks + bounty)


func set_eco_bucks(new_amount):
	eco_bucks = new_amount
	EventManager.bucks_updated.emit(eco_bucks)

