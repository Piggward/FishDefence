class_name Crab
extends Tower

const CRAB_ATTACK = preload("uid://b5l4cb3ausudl")
@onready var gpu_particles_2d = $GPUParticles2D
var CRAB_DEMO = load("uid://be2r40gq4pi5y")

func attack(enemy: Enemy):
	gpu_particles_2d.emitting = true
	var diff = rad_to_deg((enemy.global_position - self.global_position).angle()) + 90 - self.rotation_degrees
	var rot = wrapf(diff, -180, 180)
	var t = Vector2(5, 0) if rot > 0 else Vector2(-5, 0)
	tackle(t)
	var attack: AttackAnimation = CRAB_ATTACK.instantiate()
	attack.position = to_local(enemy.global_position)
	if not is_instance_valid(projectile_container):
		return
	#projectile_container.add_child(attack)
	deal_damage(enemy)
	
func get_demo():
	return CRAB_DEMO.instantiate()

func tackle(dir):
	var tween = get_tree().create_tween()
	tween.tween_property(sprite_2d, "position", position + dir, 0.15)
	tween.play()
	#await tween.finished
	tween.tween_property(sprite_2d, "position", Vector2(0, 0), 0.2)
	tween.play()
