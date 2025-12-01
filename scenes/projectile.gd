class_name Projectile
extends Area2D

var target_position: Vector2
var target_enemy: Enemy = null
var follows_enemy: bool = false
var speed: float = 200
var damage: int = 10
@export var hit_on_collision: bool = false
signal damage_dealt(amount: int)

func _ready():
	await get_tree().create_timer(2).timeout
	self.queue_free()
	pass
	
func _process(delta):
	if follows_enemy:
		follow_enemy(target_enemy, delta)
		
	else: 
		look_at(target_position)
		var dir = (target_position - self.global_position).normalized()
		self.global_position += speed * dir * delta * GameManager.time_scale
		if abs((self.global_position - target_position).length()) < 4:
			self.queue_free()
			return
		
func follow_enemy(target, delta):
	if not is_instance_valid(target) or target == null:
		self.queue_free()
		return
		
	look_at(target.global_position)
	var dir = (target.global_position - self.global_position).normalized()
	self.global_position += speed * dir * delta * GameManager.time_scale
	if abs((self.global_position - target.global_position).length()) < 15:
		hit_target(target)
			
func hit_target(enemy: Enemy):
	var dmg = enemy.take_damage(damage)
	damage_dealt.emit(dmg)
	self.queue_free()

func _on_area_entered(area):
	if (hit_on_collision):
		if area.name == "EnemyArea":
			hit_target(area.get_parent())
	pass # Replace with function body.
