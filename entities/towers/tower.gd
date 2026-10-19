class_name Tower
extends Area2D
## Base for all towers. A tower does nothing until enabled (placed on the grid, or set up by
## a demo); then it attacks a random enemy in range whenever its AttackTimer allows.
## Subclasses override attack(), and support towers (attack speed 0) never attack.

signal just_enabled
signal just_disabled

## Size of one tower cell in pixels; range_cells are measured in these.
const CELL_SIZE := 16
const RANGE_CELL = preload("uid://dsipufjotl8y8")

## Grid offsets (in tower cells) this tower reaches. Edited as a clickable grid by the
## Cell Grid Editor plugin (addons/cell_grid_editor).
@export_custom(PROPERTY_HINT_NONE, "cell_grid") var range_cells: Array[Vector2]
@export var stats: TowerStats
@export var can_rotate := false
@export var attack_sound: AudioStream
@export var fish_texture: Texture

## Live values, copied from `stats` on ready; buffs change attack_speed at runtime.
var damage: int
var attack_speed: float
var cost: int
var fish_name: String:
	get:
		return stats.fish_name
var enabled := false
var projectile_container: Node2D
## The cooldown has run out; attack the next enemy that is in range.
var _ready_to_attack := true

@onready var range_area: Area2D = $Range
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var buffs: BuffContainer = $Buffs
@onready var place_sound: AudioStreamPlayer2D = $PlaceSound
@onready var attack_sound_player: AudioStreamPlayer2D = $AttackSound
@onready var attack_timer: Timer = $AttackTimer


func _ready() -> void:
	load_stats()
	if attack_sound:
		attack_sound_player.stream = attack_sound
	for cell in range_cells:
		var collision: RangeCollision = RANGE_CELL.instantiate()
		range_area.add_child(collision)
		collision.position = cell * CELL_SIZE
	show_range(false)
	projectile_container = _find_in_own_viewport("ProjectileContainer")
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	# Deferred: body_entered fires during the physics step, where attacks can't add
	# projectiles or other collision objects.
	range_area.body_entered.connect(func(_body): _try_attack.call_deferred())


func load_stats() -> void:
	attack_speed = stats.attack_speed
	damage = stats.damage
	cost = stats.get_cost()


func enable() -> void:
	enabled = true
	# Bodies already in range are reported as entering on the next physics step.
	range_area.monitoring = true
	place_sound.pitch_scale = randf_range(0.8, 1.2)
	place_sound.play()
	just_enabled.emit()


## Stops attacking. The cooldown keeps running, so picking a tower up and putting it back
## doesn't skip it.
func disable() -> void:
	enabled = false
	range_area.monitoring = false
	just_disabled.emit()


func enemies_in_range() -> Array:
	return range_area.get_overlapping_bodies().filter(func(b): return b is Enemy and not b.dead)


## Overridden by each tower with its attack.
func attack(_enemy: Enemy) -> void:
	pass


func deal_damage(e: Enemy) -> void:
	report_damage(e.take_damage(damage))


func report_damage(amount: int) -> void:
	# Only the game's own viewport counts; demo previews run in their own.
	if get_viewport() == get_tree().root:
		EventManager.tower_damage_dealt.emit(self, amount)


func show_range(value: bool) -> void:
	for r in range_area.get_children():
		if r is RangeCollision:
			r.toggle_show(value)


func play_attack_sound(low := 0.8, high := 1.2, volume := 0.0) -> void:
	attack_sound_player.pitch_scale = randf_range(low, high)
	attack_sound_player.volume_db = volume
	attack_sound_player.play()


func add_buff(b: Buff) -> void:
	buffs.add(b)


func remove_buff(buff_name: String) -> void:
	buffs.remove(buff_name)


func _on_attack_timer_timeout() -> void:
	_ready_to_attack = true
	_try_attack()


func _try_attack() -> void:
	if not _ready_to_attack or not enabled or attack_speed <= 0:
		return
	var enemies := enemies_in_range()
	if enemies.is_empty():
		return
	_ready_to_attack = false
	attack(enemies.pick_random())
	attack_timer.start(1.0 / attack_speed)


## Groups span the whole tree; demos run in their own viewports and must not pick up
## another demo's (or the game's) nodes.
func _find_in_own_viewport(group: String) -> Node:
	for n in get_tree().get_nodes_in_group(group):
		if n.get_viewport() == get_viewport():
			return n
	return null
