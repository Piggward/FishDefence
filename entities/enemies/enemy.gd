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
@onready var debuffs: BuffContainer = $Debuffs
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
	if dead:
		return
	GameManager.player_damage(damage)
	die(false)


func on_start_reached():
	super()
	enemy_area.monitorable = true
	collision_shape_2d.disabled = false


func _on_enemy_area_area_entered(area: Area2D):
	if area.get_collision_layer_value(GOAL_LAYER):
		reached_goal()


func die(killed: bool = true):
	dead = true
	spawn_audio()
	died.emit(self, killed)
	queue_free()


func spawn_audio():
	# Demo previews are silent; a player there would also never finish and free itself.
	if demo:
		return
	var a = AUDIO_ONETIME.instantiate()
	match recycle_material:
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
	var overkill_dmg = clamp(dmg - health, 0, dmg)
	var dmg_dealt = dmg - overkill_dmg
	health -= dmg
	progress_bar.value = health
	if health <= 0:
		die()
	return dmg_dealt


func add_debuff(b: Buff):
	debuffs.add(b)


func remove_debuff(buff_name: String):
	debuffs.remove(buff_name)
