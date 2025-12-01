class_name Crab
extends Tower

const CRAB_ATTACK = preload("uid://b5l4cb3ausudl")
var CRAB_DEMO = load("uid://be2r40gq4pi5y")
const CLICK_2 = preload("uid://c06cqe6phiv7t")
const CLICK_1 = preload("uid://ca618kk4jqnwg")

func attack(enemy: Enemy):
	attack_sound_player.stream = CLICK_2 if randi_range(0, 1) == 1 else CLICK_1
	play_attack_sound(0.9, 1.1, 0)
	var diff = rad_to_deg((enemy.global_position - self.global_position).angle()) + 90 - self.rotation_degrees
	var rot = wrapf(diff, -180, 180)
	var t = Vector2(5, 0) if rot > 0 else Vector2(-5, 0)
	tackle(t)
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
