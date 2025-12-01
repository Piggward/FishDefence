class_name PufferTower
extends Tower

const PUFFER_TOWER = preload("uid://jdasnkkeyv3u")
var SPIKE = load("uid://uev6q476kg4a")
var attacking = false
var PUFFER_DEMO = load("uid://pd7xpsbcprrs")


func puff():
	play_attack_sound(0.7, 1.0)
	attacking = true
	var tween = get_tree().create_tween()
	var y_scale = sprite_2d.scale.y
	tween.tween_property(sprite_2d, "scale", Vector2(1.4, 1.4 * y_scale), 0.1)
	tween.play()
	tween.tween_property(sprite_2d, "scale", Vector2(1, sign(y_scale)), 0.2)
	tween.play()
	await tween.finished
	attacking = false
	
func get_demo():
	return PUFFER_DEMO.instantiate()

func attack(enemy: Enemy):
	if attacking:
		return
	puff()
	for p in range:
		var spike: Projectile = SPIKE.instantiate()
		spike.damage = self.damage
		spike.target_position = self.global_position + Vector2(24, 24) * p
		spike.hit_on_collision = true
		spike.damage_dealt.connect(_on_hit)
		if not is_instance_valid(projectile_container):
			return
		projectile_container.add_child(spike)
		spike.global_position = self.global_position + (p * Vector2(2, 2))

func _on_hit(dmg):
	GameManager.on_tower_damage_dealt(self, dmg)
