class_name ClownTower
extends Tower

@export var range_tiles := 1
const KONFETTI = preload("uid://cspd8fsbdje0h")
const KONFETTI_CONSTANT = preload("uid://b7oy52upclir0")

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
	
func enable():
	for c in range_area.get_overlapping_areas():
		if c is Tower:
			add_buff(c)
	super()
	
func disable():
	for c in range_area.get_overlapping_areas():
		if c is Tower:
			remove_buff(c)
	super()
	
func _process(delta):
	if targets.size() > 0 and not cd and enabled:
		set_cd()
		#TODO: select target
		attack(targets[0])

func _on_range_body_entered(body):
	pass


func _on_range_body_exited(body):
	pass

func add_buff(tower: Tower):
	if tower == self:
		return
	tower.attack_speed *= 2
	var konfetti = KONFETTI.instantiate()
	konfetti.global_position = tower.global_position
	projectile_container.add_child(konfetti)
	var cc = KONFETTI_CONSTANT.instantiate()
	tower.add_child(cc)

func remove_buff(tower: Tower):
	if tower == self:
		return
	tower.attack_speed /= 2
	for c in tower.get_children():
		if c is ConfettiConstant:
			c.queue_free()
			return

func _on_range_area_entered(area):
	if area is Tower and enabled and area.enabled:
		add_buff(area)
		pass


func _on_range_area_exited(area):
	if area is Tower and enabled and area.enabled:
		remove_buff(area)
		pass
