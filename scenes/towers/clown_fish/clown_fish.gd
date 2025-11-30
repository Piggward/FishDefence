class_name ClownTower
extends Tower

@export var range_tiles := 1
@export var attack_speed_multiplier := 1.2
const KONFETTI = preload("uid://cspd8fsbdje0h")
const KONFETTI_CONSTANT = preload("uid://b7oy52upclir0")
var buff: Buff
var CLOWN_DEMO = load("uid://cmb264p7wubih")

func _ready():
	buff = ASBuff.new()
	buff.attack_speed_multiplier = self.attack_speed_multiplier
	buff.buff_name = "clown tower"
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
	
func enable():
	for c in range_area.get_overlapping_areas():
		if c is Tower:
			add_buff_to_tower(c)
	super()
	
func disable():
	for c in range_area.get_overlapping_areas():
		if c is Tower:
			remove_buff_from_tower(c)
	super()
	
func get_demo():
	return CLOWN_DEMO.instantiate()
	
func _on_range_body_entered(body):
	pass


func _on_range_body_exited(body):
	pass

func add_buff_to_tower(tower: Tower):
	if tower == self:
		return
	print("adding buff")
	tower.add_buff(buff.duplicate())
	var konfetti = KONFETTI.instantiate()
	konfetti.global_position = tower.global_position
	projectile_container.add_child(konfetti)
	var cc = KONFETTI_CONSTANT.instantiate()
	cc.global_position = tower.global_position
	tower.add_child(cc)

func remove_buff_from_tower(tower: Tower):
	if tower == self:
		return
	print("removing buff")

	tower.remove_buff(buff.duplicate())
	for c in tower.get_children():
		if c is ConfettiConstant:
			c.queue_free()
			return

func _on_range_area_entered(area):
	if not area is Tower or not enabled:
		return
	
	if not area.enabled:
		area.just_enabled.connect(add_buff_to_tower.bind(area))


func _on_range_area_exited(area):
	if not area is Tower or not enabled:
		return
	if not area.enabled:
		area.just_enabled.disconnect(add_buff_to_tower.bind(area))
