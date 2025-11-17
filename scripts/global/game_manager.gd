extends Node

var eco_bucks = 30000

signal bucks_updated

func transaction_requested(tower: Tower) -> bool:
	var cost = tower.cost
	if cost > eco_bucks:
		return false
		
	set_eco_bucks(eco_bucks - cost)
	return true
	
func can_afford(tower: Tower) -> bool:
	if tower.cost > eco_bucks:
		return false
	return true
	
func add_bounty(bounty: int):
	set_eco_bucks(eco_bucks + bounty)
	
func set_eco_bucks(new_amount):
	eco_bucks = new_amount
	bucks_updated.emit(eco_bucks)
