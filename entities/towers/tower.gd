class_name Tower
extends Area2D

## Grid offsets (in 16px tower cells) this tower reaches. Edited as a clickable grid by the
## Cell Grid Editor plugin (addons/cell_grid_editor).
@export_custom(PROPERTY_HINT_NONE, "cell_grid") var range_cells: Array[Vector2]
@export var stats: TowerStats
@export var can_rotate: bool = false
@export var demo = false
@export var attack_sound: AudioStream = null
@export var fish_texture: Texture
## Live values, copied from `stats` on ready; buffs change attack_speed at runtime.
var damage: int
var attack_speed: float
var cost: int
var special: float
var fish_name: String:
	get:
		return stats.fish_name
var projectile_container: Node2D
var targets: Array[Enemy] = []
var cd = false
var enabled = false
const SQUARE_COLLISION = preload("uid://dsipufjotl8y8")
@onready var range_area = $Range
@onready var sprite_2d = $Sprite2D
@onready var buffs: BuffContainer = $Buffs
@onready var place_sound = $PlaceSound
@onready var attack_sound_player = $AttackSound
signal just_enabled
signal just_disabled


func _ready():
	load_stats()
	if attack_sound:
		attack_sound_player.stream = attack_sound
	for r in range_cells:
		var collision = SQUARE_COLLISION.instantiate()
		range_area.add_child(collision)
		collision.position = r * Vector2(16, 16)
	projectile_container = _find_in_own_viewport("ProjectileContainer")
	if not demo:
		disable()
	else:
		enable()
		show_range(false)


## Groups span the whole tree; demos run in their own viewports and must not pick up
## another demo's (or the game's) nodes.
func _find_in_own_viewport(group: String) -> Node:
	for n in get_tree().get_nodes_in_group(group):
		if n.get_viewport() == get_viewport():
			return n
	return null


func load_stats() -> void:
	attack_speed = stats.attack_speed
	damage = stats.damage
	special = stats.special
	cost = stats.get_cost()


func enable():
	z_index = 0
	enabled = true
	modulate = Color(1, 1, 1, 1)
	range_area.body_entered.connect(_on_range_body_entered)
	range_area.body_exited.connect(_on_range_body_exited)
	show_range(false)
	targets.clear()
	for b in range_area.get_overlapping_bodies():
		if b is Enemy:
			targets.append(b)
	just_enabled.emit()

	if not demo:
		place_sound.pitch_scale = randf_range(0.8, 1.2)
		place_sound.play()


func disable():
	z_index = 999
	enabled = false
	modulate = Color(0.5, 0.5, 0.5, 0.35)
	if range_area.body_entered.is_connected(_on_range_body_entered):
		range_area.body_entered.disconnect(_on_range_body_entered)
	if range_area.body_exited.is_connected(_on_range_body_exited):
		range_area.body_exited.disconnect(_on_range_body_exited)
	show_range(true)
	just_disabled.emit()


func deal_damage(e: Enemy):
	report_damage(e.take_damage(damage))


func report_damage(amount: int):
	if not demo:
		EventManager.tower_damage_dealt.emit(self, amount)


func show_range(value: bool):
	for r in range_area.get_children():
		if r is RangeCollision:
			r.toggle_show(value)


func _process(_delta):
	# Support towers (attack speed 0) never attack.
	if targets.size() > 0 and not cd and enabled and attack_speed > 0:
		set_cd()
		attack(targets.pick_random())


func play_attack_sound(low = 0.8, high = 1.2, volume = 0.0):
	attack_sound_player.pitch_scale = randf_range(low, high)
	attack_sound_player.volume_db = volume
	attack_sound_player.play()


func set_cd():
	cd = true
	await get_tree().create_timer(1 / attack_speed).timeout
	cd = false


func attack(_enemy: Enemy):
	pass


func _on_enemy_died(enemy: Enemy, _killed: bool):
	targets.erase(enemy)


func _on_range_body_entered(body):
	if body is Enemy:
		targets.append(body)
		if not body.died.is_connected(_on_enemy_died):
			body.died.connect(_on_enemy_died)


func _on_range_body_exited(body):
	if body is Enemy:
		targets.erase(body)
		if body.died.is_connected(_on_enemy_died):
			body.died.disconnect(_on_enemy_died)


func add_buff(b: Buff):
	buffs.add(b)


func remove_buff(buff_name: String):
	buffs.remove(buff_name)
