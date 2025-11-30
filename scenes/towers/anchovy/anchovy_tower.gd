class_name AnchovyTower
extends Tower
var charging = false
var charged_enemies: Array[Enemy] = []
const BUBBLE_PARTICLES = preload("uid://dq2iwrtbcm1d6")
@onready var attack_area: Area2D = $Sprite2D/AttackArea
var ANCHOVY_DEMO = load("uid://b2iwto0ov5ms3")

func attack(target: Enemy):
	charging = true
	charged_enemies.clear()
	for a in attack_area.get_overlapping_areas():
		if a.name == "EnemyArea":
			charge_attack(a)
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
		charge_attack(area)
	pass # Replace with function body.
	
func get_demo():
	return ANCHOVY_DEMO.instantiate()
	
func charge_attack(enemyArea: Area2D):
	var enemy: Enemy = enemyArea.get_parent()
	if charged_enemies.has(enemy):
		return
	deal_damage(enemy)
	charged_enemies.append(enemy)
