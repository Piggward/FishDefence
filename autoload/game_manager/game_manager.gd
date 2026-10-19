extends Node
## Run state (money, health, wave) and game settings that outlive a level reload.

const START_BUCKS := 250
const START_HEALTH := 100
const FAST_MODE_TIME_SCALE := 2.0

var eco_bucks := START_BUCKS
var health := START_HEALTH
var current_wave := 0
var easy_mode := true
## The intro has played once; "Play again" goes straight to playing.
var intro_seen := false
var tutorial_done := false
var has_rotated := false


## Resets run state and reloads the level. Everything spawned during a run lives in the
## level scene, so reloading it frees all of it. intro_seen and tutorial_done stay set,
## so the new run starts in play.
func restart() -> void:
	eco_bucks = START_BUCKS
	health = START_HEALTH
	current_wave = 0
	set_fast_mode(false)
	resume_game()
	get_tree().reload_current_scene()


## Freezes gameplay; nodes set to process "Always" (HUD, tutorial, music) keep running.
## Not SceneTree.paused: that also stops the physics server, which the tutorial's demo
## previews need. Deferred, because win/lose can fire from a physics callback.
func pause_game() -> void:
	get_tree().root.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)


func resume_game() -> void:
	get_tree().root.set_deferred("process_mode", Node.PROCESS_MODE_PAUSABLE)


## Scales every delta, timer, tween, animation and particle at once.
func set_fast_mode(on: bool) -> void:
	Engine.time_scale = FAST_MODE_TIME_SCALE if on else 1.0


func set_expert_mode(on: bool) -> void:
	easy_mode = not on
	EventManager.expert_updated.emit()


func player_damage(damage: int) -> void:
	var was_alive := health > 0
	health -= damage
	EventManager.health_updated.emit(health)
	if was_alive and health <= 0:
		EventManager.lose.emit()


func is_lost() -> bool:
	return health <= 0


func can_buy(cost: int) -> bool:
	return tutorial_done and cost <= eco_bucks


func spend(cost: int) -> void:
	set_eco_bucks(eco_bucks - cost)


func add_bounty(bounty: int) -> void:
	set_eco_bucks(eco_bucks + bounty)


func set_eco_bucks(new_amount: int) -> void:
	eco_bucks = new_amount
	EventManager.bucks_updated.emit(eco_bucks)
