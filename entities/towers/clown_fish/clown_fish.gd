class_name ClownTower
extends Tower
## Boosts the attack speed of placed towers in range. Tracks which towers it buffed so
## every buff it adds is removed again when either tower is picked up.

const BUFF_NAME = "clown tower"
const KONFETTI = preload("uid://cspd8fsbdje0h")
const KONFETTI_CONSTANT = preload("uid://b7oy52upclir0")
## Attack speed multiplier; set from the tower's TowerStats.special.
var attack_speed_multiplier := 1.5
## Tower in range -> [on_enabled, on_disabled] callables connected to it.
var towers_in_range := {}
## Buffed tower -> the constant confetti shown on it.
var buffed := {}


func _ready():
	super()
	range_area.area_entered.connect(_on_range_area_entered)
	range_area.area_exited.connect(_on_range_area_exited)


func load_stats():
	super()
	attack_speed_multiplier = special


func enable():
	play_attack_sound(0.95, 1.05, 3.0)
	super()
	for t in towers_in_range.keys():
		if t.enabled:
			buff_tower(t)


func disable():
	for t in buffed.keys():
		unbuff_tower(t)
	super()


func buff_tower(tower: Tower):
	if tower == self or buffed.has(tower):
		return
	var b := ASBuff.new()
	b.buff_name = BUFF_NAME
	b.attack_speed_multiplier = attack_speed_multiplier
	tower.add_buff(b)
	var cc = KONFETTI_CONSTANT.instantiate()
	tower.add_child(cc)
	buffed[tower] = cc
	if is_instance_valid(projectile_container):
		var konfetti = KONFETTI.instantiate()
		konfetti.global_position = tower.global_position
		projectile_container.add_child(konfetti)


func unbuff_tower(tower: Tower):
	if not buffed.has(tower):
		return
	tower.remove_buff(BUFF_NAME)
	buffed[tower].queue_free()
	buffed.erase(tower)


func _on_tower_enabled(tower: Tower):
	if enabled:
		buff_tower(tower)


func _on_range_area_entered(area):
	if area is Tower and area != self and not towers_in_range.has(area):
		var on_enabled := _on_tower_enabled.bind(area)
		var on_disabled := unbuff_tower.bind(area)
		area.just_enabled.connect(on_enabled)
		area.just_disabled.connect(on_disabled)
		towers_in_range[area] = [on_enabled, on_disabled]
		if area.enabled and enabled:
			buff_tower(area)


func _on_range_area_exited(area):
	if not area is Tower or not towers_in_range.has(area):
		return
	area.just_enabled.disconnect(towers_in_range[area][0])
	area.just_disabled.disconnect(towers_in_range[area][1])
	towers_in_range.erase(area)
	unbuff_tower(area)
