class_name Tower
extends Area2D

@export var range: Array[Vector2]
@export var damage: float
@export var attack_speed: float
@export var cost: int
@export var fish_name: String
var projectile_container: Node2D
var targets: Array[Enemy] = []
var cd = false
var enabled = false
const PROJECTILE = preload("uid://1ios5h5gj0n8")
@onready var range_area = $Range
@export var fish_texture: Texture
const SQUARE_COLLISION = preload("uid://dsipufjotl8y8")

func _ready():
	for r in range:
		var collision = SQUARE_COLLISION.instantiate()
		range_area.add_child(collision)
		collision.position = r * Vector2(16, 16)
	projectile_container = get_tree().get_first_node_in_group("ProjectileContainer")
	disable()
	
func enable():
	enabled = true
	modulate = Color(1, 1, 1, 1);
	range_area.body_entered.connect(_on_range_body_entered)
	range_area.body_exited.connect(_on_range_body_exited)
	show_range(false)
	targets.clear()
	for b in range_area.get_overlapping_bodies():
		if b is Enemy:
			targets.append(b)
			
func disable():
	enabled = false
	modulate = Color(0.5, 0.5, 0.5, 0.35);
	range_area.body_entered.disconnect(_on_range_body_entered)
	range_area.body_exited.disconnect(_on_range_body_exited)
	show_range(true)
	
func show_range(value: bool):
	for r in range_area.get_children():
		if r is RangeCollision:
			r.toggle_show(value)
	
func _process(delta):
	if targets.size() > 0 and not cd and enabled:
		set_cd()
		#TODO: select target
		attack(targets[0])
		
func set_cd():
	cd = true
	await get_tree().create_timer(1 / attack_speed).timeout
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

func _on_enemy_died(enemy: Enemy):
	targets.erase(enemy)

func _on_range_body_entered(body):
	if body is Enemy:
		targets.append(body)
		body.died.connect(_on_enemy_died)
	pass # Replace with function body.


func _on_range_body_exited(body):
	if body is Enemy:
		targets.erase(body)
		body.died.disconnect(_on_enemy_died)
	pass # Replace with function body.
