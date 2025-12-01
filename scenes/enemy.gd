class_name Enemy
extends EnemyNavigator

@export var bounty: int = 10
@export var damage: int
@export var health: int
@export var texture: Texture2D
@export var demo = false
@export var recycle_material: String
const GOAL_LAYER := 10
var dead = false
@onready var sprite_2d = $Sprite2D
signal died(enemy: Enemy, killed: bool)
@onready var progress_bar = $ProgressBar
@onready var debuffs = $Debuffs
@onready var enemy_area = $EnemyArea
@onready var collision_shape_2d = $CollisionShape2D
const CAN_DIE = preload("uid://degalk0n5xp1h")
const PAPER_CRUSH = preload("uid://fww72qtj7aqg")
const PLASTIC_BAG_CRUSH = preload("uid://di2rvh1keh6gy")
const PLASTIC_CRUSH = preload("uid://4dbjhmnhfi08")
const AUDIO_ONETIME = preload("uid://dfms11u6nqgkq")

func _ready():
	if not demo:
		super()
		enemy_area.monitorable = false
		collision_shape_2d.disabled = true
	sprite_2d.texture = texture
	progress_bar.max_value = health
	progress_bar.value = health


func reached_goal():
	# Deal damage
	GameManager.player_damage(damage)
	die(false)
	
func on_start_reached():
	super()
	enemy_area.monitorable = true
	collision_shape_2d.disabled = false
	
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
	spawn_audio()
	died.emit(self, killed)
	self.queue_free()
	
func spawn_audio():
	var a = AUDIO_ONETIME.instantiate()
	match(recycle_material):
		"plastic":
			a.stream = PLASTIC_CRUSH
		"plastic bag":
			a.stream = PLASTIC_BAG_CRUSH
		"can":
			a.stream = CAN_DIE
		"paper":
			a.stream = PAPER_CRUSH
			
	get_tree().root.add_child(a)
	
func take_damage(dmg: int) -> int:
	if dead or health < 0:
		return 0
	var overkill_dmg = clamp(dmg - self.health, 0, dmg)
	var dmg_dealt = dmg - overkill_dmg
	self.health -= dmg
	progress_bar.value = health
	if self.health <= 0:
		die()
	return dmg_dealt
		
func add_debuff(b: Buff):
	debuffs.add_child(b)

func remove_debuff(b: Buff):
	for c: Buff in debuffs.get_children():
		if c.buff_name == b.buff_name:
			c.queue_free()
			c.reparent(get_tree().root)
			break;
	var has_more_duplicates = debuffs.get_children().any(func(c: Buff): return c.buff_name == b.buff_name and b != c)
	if has_more_duplicates:
		return
	else:
		b.remove(self)

func _on_debuffs_child_entered_tree(node):
	var current_buffs = debuffs.get_children()
	var has_buff = current_buffs.any(func(c: Buff): return c.buff_name == node.buff_name and c != node)
	if not has_buff:
		node.apply(self)
	pass # Replace with function body.
