class_name AnchovyTower
extends Tower
@onready var sprite_2d = $Sprite2D
var charging = false
var charged_enemies: Array[Enemy] = []
const BUBBLE_PARTICLES = preload("uid://dq2iwrtbcm1d6")

func attack(target: Enemy):
	charging = true
	charged_enemies.clear()
	var bub = BUBBLE_PARTICLES.instantiate()
	sprite_2d.add_child(bub)
	bub.emitting = true
	var tween = get_tree().create_tween()
	tween.tween_property(sprite_2d, "position", Vector2.RIGHT * (16 * range.size()), (1 / (attack_speed * 6)))
	tween.play()
	await tween.finished
	charging = false
	sprite_2d.scale.x = -1
	tween = get_tree().create_tween()
	tween.tween_property(sprite_2d, "position", Vector2.ZERO, (1 / (attack_speed * 3)))
	tween.play()
	await tween.finished
	sprite_2d.scale.x = 1
	bub.queue_free()


func _on_attack_area_area_entered(area):
	if area.name == "EnemyArea" and charging:
		var enemy: Enemy = area.get_parent()
		if charged_enemies.has(enemy):
			return
		enemy.take_damage(self.damage)
		charged_enemies.append(enemy)
	pass # Replace with function body.
