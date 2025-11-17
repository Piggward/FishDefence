class_name PufferTower
extends Tower

const PUFFER_TOWER = preload("uid://jdasnkkeyv3u")
@onready var sprite_2d = $Sprite2D
const SPIKE = preload("uid://uev6q476kg4a")

func puff():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite_2d, "scale", Vector2(2.1, 2.1), 0.1)
	tween.play()
	#await tween.finished
	tween.tween_property(sprite_2d, "scale", Vector2(1, 1), 0.2)
	tween.play()

func attack(enemy: Enemy):
	puff()
	for p in range:
		var spike: Projectile = SPIKE.instantiate()
		spike.damage = self.damage
		spike.target_position = self.global_position + Vector2(24, 24) * p
		spike.hit_on_collision = true
		spike.global_position = self.global_position + (p * Vector2(2, 2))
		projectile_container.add_child(spike)
