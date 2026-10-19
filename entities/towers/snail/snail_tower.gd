class_name Snail
extends Tower

const SLOW_BUFF_NAME = "snail slow"
const SLIME = preload("uid://bv30370oa8nt")
## Speed multiplier for enemies on the slime; set from the tower's TowerStats.special.
var slow_ratio := 0.5
var slimes: Array[Slime]


func load_stats():
	super()
	slow_ratio = special


func enable():
	super()
	play_attack_sound(0.8, 1.2, -3.0)
	for v in range_cells:
		add_slime(v * 16)


func disable():
	super()
	remove_all_slime()


func remove_all_slime():
	for slime: Slime in slimes:
		# Release enemies standing on the slime before it disappears.
		for body in slime.get_overlapping_bodies():
			if body is Enemy:
				_on_slime_exited(body)
		slime.body_entered.disconnect(_on_slime_entered)
		slime.body_exited.disconnect(_on_slime_exited)
		slime.queue_free()
	slimes.clear()


func add_slime(v: Vector2):
	var slime: Slime = SLIME.instantiate()
	slime.position = v
	add_child(slime)
	slimes.append(slime)
	slime.body_entered.connect(_on_slime_entered)
	slime.body_exited.connect(_on_slime_exited)


func _on_slime_entered(enemy: Enemy):
	var slow_debuff = SlowDebuff.new()
	slow_debuff.slow_multiplier = slow_ratio
	slow_debuff.buff_name = SLOW_BUFF_NAME
	enemy.add_debuff(slow_debuff)


func _on_slime_exited(enemy: Enemy):
	enemy.remove_debuff(SLOW_BUFF_NAME)
