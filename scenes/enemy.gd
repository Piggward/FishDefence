class_name Enemy
extends EnemyNavigator

@export var bounty: int = 10
@export var damage: int
@export var health: int
const GOAL_LAYER := 10
var dead = false
signal died(enemy: Enemy)

func reached_goal():
	# Deal damage
	die()
	
func _on_enemy_area_area_entered(area: Area2D):
	if area.get_collision_layer_value(GOAL_LAYER):
		reached_goal()
	pass # Replace with function body.
	
func die():
	dead = true
	died.emit(self)
	self.queue_free()
	
func take_damage(dmg: int):
	if dead or health < 0:
		return
	self.health -= dmg
	print("hp: ", health)
	if self.health <= 0:
		die()
	
