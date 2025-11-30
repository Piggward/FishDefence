class_name SurgeonFish
extends Tower

@export var range_tiles := 2
var FISH_SPIT = load("uid://nekt2j1xfquv")
var SURGEON_DEMO = load("uid://dagtsle1vogl3")

func _ready():
	range.clear()
	for i in range_tiles + 1:
		for j in range_tiles + 1:
			if i == 0 and j == 0:
				continue
			elif i == 0:
				range.append(Vector2(i, -j))
				range.append(Vector2(i, j))
			elif j == 0:
				range.append(Vector2(-i, j))
				range.append(Vector2(i, j))
			else:
				range.append(Vector2(-i, j))
				range.append(Vector2(-i, -j))
				range.append(Vector2(i, -j))
				range.append(Vector2(i, j))
	super();

func _on_range_body_exited(body):
	super(body)
	if targets.size() == 0:
		await get_tree().create_timer(1).timeout
		if targets.size() == 0:
			sprite_2d.scale.y = 1
			sprite_2d.rotation_degrees = 0
	pass # Replace with function body.

	
func get_demo():
	return SURGEON_DEMO.instantiate()

func attack(enemy: Enemy):
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
	proj.speed = 200 * Engine.time_scale
	proj.target_enemy = enemy
	proj.damage_dealt.connect(_on_hit)
	if not is_instance_valid(projectile_container):
		return
	projectile_container.add_child(proj)


func _on_hit(dmg):
	GameManager.on_tower_damage_dealt(self, dmg)
