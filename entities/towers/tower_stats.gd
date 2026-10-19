class_name TowerStats
extends Resource
## Balance values for one tower type. Each tower folder has one, referenced by its scene.

@export var fish_name: String
## Easy-mode price; expert mode adds EXPERT_COST_MULTIPLIER.
@export var cost: int
@export var damage: int
## Attacks per second. 0 for support towers that never attack.
@export var attack_speed: float
## Tower-specific value: the snail's slow multiplier, the clown's attack speed multiplier.
@export var special: float
@export_multiline var description: String

const EXPERT_COST_MULTIPLIER := 1.3


func get_cost() -> int:
	return cost if GameManager.easy_mode else int(cost * EXPERT_COST_MULTIPLIER)


func get_card_text() -> String:
	if attack_speed <= 0:
		return description
	return "Attack speed: %s\nDamage: %s\n\n%s" % [int(attack_speed * 1000), damage, description]
