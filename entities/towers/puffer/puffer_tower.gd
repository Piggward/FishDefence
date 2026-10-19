class_name PufferTower
extends Tower

var SPIKE = load("uid://uev6q476kg4a")
var attacking = false


func puff():
	play_attack_sound(0.7, 1.0)
	attacking = true
	var tween = get_tree().create_tween()
	var y_scale = sprite_2d.scale.y
	tween.tween_property(sprite_2d, "scale", Vector2(1.4, 1.4 * y_scale), 0.1 / attack_speed)
	tween.play()
	tween.tween_property(sprite_2d, "scale", Vector2(1, sign(y_scale)), 0.4 / attack_speed)
	tween.play()
	await tween.finished
	attacking = false


func attack(_enemy: Enemy):
	if attacking or not is_instance_valid(projectile_container):
		return
	puff()
	for p in range_cells:
		var spike: Projectile = SPIKE.instantiate()
		spike.damage = self.damage
		spike.target_position = self.global_position + Vector2(24, 24) * p
		spike.hit_on_collision = true
		spike.damage_dealt.connect(report_damage)
		projectile_container.add_child(spike)
		spike.global_position = self.global_position + (p * Vector2(2, 2))
