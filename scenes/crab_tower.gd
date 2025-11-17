class_name Crab
extends Tower

const CRAB_ATTACK = preload("uid://b5l4cb3ausudl")
@onready var gpu_particles_2d = $GPUParticles2D

func attack(enemy: Enemy):
	gpu_particles_2d.emitting = true
	var t = Vector2(5, 0) if (enemy.global_position - self.global_position).x > 0 else Vector2(-5, 0)
	tackle(t)
	var attack: AttackAnimation = CRAB_ATTACK.instantiate()
	attack.global_position = enemy.global_position
	projectile_container.add_child(attack)
	await attack.hit
	enemy.take_damage(self.damage)
