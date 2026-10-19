class_name SurgeonFish
extends Tower

var FISH_SPIT = load("uid://nekt2j1xfquv")

func _ready() -> void:
	super()
	range_area.body_exited.connect(_on_enemy_left_range)


## Turn back to the resting pose a second after the last enemy leaves.
func _on_enemy_left_range(_body) -> void:
	await get_tree().create_timer(1).timeout
	if enemies_in_range().is_empty():
		sprite_2d.scale.y = 1
		sprite_2d.rotation_degrees = 0


func attack(enemy: Enemy):
	if not is_instance_valid(projectile_container):
		return
	sprite_2d.look_at(enemy.global_position)
	var direction = enemy.global_position - global_position
	var angle_deg = rad_to_deg(direction.angle())
	angle_deg += 90
	if (angle_deg < 0 and angle_deg > -180) or (angle_deg > 180 and angle_deg < 360):
		sprite_2d.scale.y = -1
	else:
		sprite_2d.scale.y = 1
	var proj: Projectile = FISH_SPIT.instantiate()
	proj.global_position = self.global_position
	proj.follows_enemy = true
	proj.damage = self.damage
	proj.speed = 200
	proj.target_enemy = enemy
	proj.damage_dealt.connect(report_damage)
	projectile_container.add_child(proj)
	play_attack_sound()
