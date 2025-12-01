class_name Tower
extends Area2D

@export var range: Array[Vector2]
@export var damage: float
@export var attack_speed: float
@export var cost: int
@export var fish_name: String
@export var can_rotate: bool = false
@export var demo = false
@export var description: String = ""
@export var is_copy: bool = false
@export var attack_sound: AudioStream = null
var projectile_container: Node2D
var targets: Array[Enemy] = []
var cd = false
var enabled = false
const ROTATE_INFO = " Can be rotated while placing by pressing R."
const PROJECTILE = preload("uid://1ios5h5gj0n8")
@onready var range_area = $Range
@export var fish_texture: Texture
const SQUARE_COLLISION = preload("uid://dsipufjotl8y8")
@onready var sprite_2d = $Sprite2D
signal just_enabled
@onready var buffs = $Buffs
signal dmg_dealt(amount: int)
@onready var place_sound = $PlaceSound
@onready var attack_sound_player = $AttackSound

func _ready():
	if attack_sound:
		attack_sound_player.stream = attack_sound
	if not is_copy:
		for r in range:
			var collision = SQUARE_COLLISION.instantiate()
			range_area.add_child(collision)
			collision.position = r * Vector2(16, 16)
	if not demo:
		projectile_container = get_tree().get_first_node_in_group("ProjectileContainer")
		disable()
	else:
		projectile_container = get_tree().get_first_node_in_group("DemoProjectileContainer")
		enable()
		show_range(false)
		
func load_stats() -> void:
	var file := FileAccess.open("res://data/towers.json", FileAccess.READ)
	if file == null:
		push_error("Could not open %s: %s" % ["res://data/towers.json", error_string(FileAccess.get_open_error())])
		return

	var data = JSON.parse_string(file.get_as_text())
	if !(data is Array):
		push_error("Invalid JSON format (expected array).")
		return

	for item in data:
		if !(item is Dictionary):
			push_warning("Skipping non-dictionary entry in JSON.")
			continue
		
		if not item["Name"] == self.fish_name:
			continue
		
		self.attack_speed = item["AttackSpeed"]
		self.damage = item["Damage"]
		self.description = item["Description"]
		self.cost = item["Cost"]
		
		if not GameManager.easy_mode: 
			self.cost *= 1.3
		
func get_description():
	return "Attack speed: %s
	Damage: %s
	
	%s" % [str(int(attack_speed * 1000)), str(int(damage)), str(description)]
	
func get_demo():
	pass
	
func enable():
	self.z_index = 0
	enabled = true
	modulate = Color(1, 1, 1, 1);
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
	self.z_index = 999
	enabled = false
	modulate = Color(0.5, 0.5, 0.5, 0.35);
	if range_area.is_connected("body_entered", _on_range_body_entered):
		range_area.body_entered.disconnect(_on_range_body_entered)
	if range_area.is_connected("body_exited", _on_range_body_exited):
		range_area.body_exited.disconnect(_on_range_body_exited)
	show_range(true)
	
func deal_damage(e: Enemy):
	var damage_dealt = e.take_damage(self.damage)
	GameManager.on_tower_damage_dealt(self, damage_dealt)
	
func show_range(value: bool):
	for r in range_area.get_children():
		if r is RangeCollision:
			r.toggle_show(value)
	
func _process(delta):
	if targets.size() > 0 and not cd and enabled:
		set_cd()
		#TODO: select target
		attack(targets[randi_range(0, targets.size()-1)])
		
func play_attack_sound(low = 0.8, high = 1.2, volume = 0.0):
	attack_sound_player.pitch_scale = randf_range(low, high)
	attack_sound_player.volume_db = volume
	attack_sound_player.play()
		
func set_cd():
	cd = true
	await get_tree().create_timer(1 / (attack_speed * GameManager.time_scale)).timeout
	cd = false
		
func attack(enemy: Enemy):
	pass
	#var projectile: Projectile = PROJECTILE.instantiate()
	#projectile.target = enemy
	#projectile.damage = self.damage
	#projectile.global_position = self.global_position
	#projectile_container.add_child(projectile)
	#var attack: AttackAnimation = CRAB_ATTACK.instantiate()
	#attack.global_position = enemy.global_position
	#projectile_container.add_child(attack)
	#await attack.hit
	#enemy.take_damage(self.damage)

func _on_enemy_died(enemy: Enemy, killed: bool):
	targets.erase(enemy)

func _on_range_body_entered(body):
	if body is Enemy:
		targets.append(body)
		body.died.connect(_on_enemy_died)
	pass # Replace with function body.


func _on_range_body_exited(body):
	if body is Enemy:
		targets.erase(body)
		if body.is_connected("died", _on_enemy_died):
			body.died.disconnect(_on_enemy_died)
	pass # Replace with function body.

func add_buff(b: Buff):
	buffs.add_child(b)

func remove_buff(b: Buff):
	for c: Buff in buffs.get_children():
		if c.buff_name == b.buff_name:
			c.queue_free()
			return 


func _on_buffs_child_entered_tree(node: Buff):
	var current_buffs = buffs.get_children()
	var has_buff = current_buffs.any(func(c: Buff): return c.buff_name == node.buff_name and c != node)
	if not has_buff:
		print("applying")
		node.apply(self)
	pass # Replace with function body.


func _on_buffs_child_exiting_tree(node: Buff):
	if not buffs.get_children().any(func(c: Buff): return c.buff_name == node.buff_name and node != c):
		print("removing")
		node.remove(self)
