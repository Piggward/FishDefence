class_name Crab
extends Tower

const CRAB_ATTACK = preload("uid://b5l4cb3ausudl")
@onready var gpu_particles_2d = $GPUParticles2D
@onready var sprite_2d = $Sprite2D

func attack(enemy: Enemy):
	gpu_particles_2d.emitting = true
	var diff = rad_to_deg((enemy.global_position - self.global_position).angle()) + 90 - self.rotation_degrees
	
	var vect = Vector2.ONE.rotated(diff)
	var t = Vector2(5, 0) if vect.x > 0 else Vector2(-5, 0)
	tackle(t)
	var attack: AttackAnimation = CRAB_ATTACK.instantiate()
	attack.global_position = enemy.global_position
	projectile_container.add_child(attack)
	await attack.hit
	enemy.take_damage(self.damage)

func tackle(dir):
	var tween = get_tree().create_tween()
	tween.tween_property(sprite_2d, "position", position + dir, 0.15)
	tween.play()
	#await tween.finished
	tween.tween_property(sprite_2d, "position", Vector2(0, 0), 0.2)
	tween.play()
