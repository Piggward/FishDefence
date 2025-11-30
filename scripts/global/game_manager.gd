extends Node

var eco_bucks = 250
var health = 10
var skip_intro = false
var damage_dealt_container: Control
var easy_mode: bool = true
var can_speed_up: bool = false 
var has_rotated: bool = false
var has_placed: bool = false

signal bucks_updated(value: int)
signal health_updated(value: int)

func reset():
	eco_bucks = 250
	health = 100
	skip_intro = true

func player_damage(damage: int):
	health -= damage
	health_updated.emit(health)
	if health <= 0:
		EventManager.lose.emit()
		return

func transaction_requested(tower: Tower) -> bool:
	var cost = tower.cost
	if cost > eco_bucks:
		return false
		
	set_eco_bucks(eco_bucks - cost)
	return true
	
func can_afford(tower: Tower) -> bool:
	tower.load_stats()
	if tower.cost > eco_bucks:
		return false
	return true
	
func can_afford_cost(cost: int) -> bool:
	if cost > eco_bucks:
		return false
	return true
	
func add_bounty(bounty: int):
	set_eco_bucks(eco_bucks + bounty)
	
func set_eco_bucks(new_amount):
	eco_bucks = new_amount
	bucks_updated.emit(eco_bucks)

func on_tower_damage_dealt(tower: Tower, damage: int):
	if tower.demo:
		return
	damage_dealt_container.damage_dealt(tower, damage)
	
