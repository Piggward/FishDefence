class_name Enemy
extends EnemyNavigator

@export var bounty: int = 10
@export var damage: int
@export var health: int
const GOAL_LAYER := 10
var dead = false
signal died(enemy: Enemy)
@onready var progress_bar = $ProgressBar

func _ready():
	super()
	progress_bar.max_value = health

func reached_goal():
	# Deal damage
	GameManager.player_damage(damage)
	die(false)
	
func _on_enemy_area_area_entered(area: Area2D):
	if area.get_collision_layer_value(GOAL_LAYER):
		reached_goal()
	pass # Replace with function body.
	
func _on_path_updated():
	if self.start_reached and tile_grid.new_enemy_paths.has(self):
		_path = tile_grid.new_enemy_paths[self]
	#var close_tile = tile_grid.get_closest_tile(self.global_position)
	#find_path(Vector2(close_tile.pos), Vector2i(tile_grid.finish_position))
	
func die(killed: bool = true):
	dead = true
	died.emit(self, killed)
	self.queue_free()
	
func take_damage(dmg: int):
	if dead or health < 0:
		return
	self.health -= dmg
	progress_bar.value = health
	print("hp: ", health)
	if self.health <= 0:
		die()
	
