class_name Snail
extends Tower

@export var slow_ratio: float = 0.1
const SLIME = preload("uid://bv30370oa8nt")
var enemy_dict = {}
var slimes: Array[Slime]
var SNAIL_DEMO = load("uid://cqiql3ofhwmaj")

func _ready():
	super()

func enable():
	super()
	play_attack_sound(0.8, 1.2, -3.0)
	for v in range:
		add_slime(v * 16)
	
func disable():
	super()
	remove_all_slime()
	
func get_demo():
	return SNAIL_DEMO.instantiate()
	
func remove_all_slime():
	for slime: Slime in slimes:
		if slime.is_connected("body_entered", _on_slime_entered):
			slime.body_entered.disconnect(_on_slime_entered)
		if slime.is_connected("body_exited", _on_slime_exited):
			slime.body_exited.disconnect(_on_slime_exited)
		slime.queue_free()
	for e in enemy_dict:
		e.speed += enemy_dict[e]
		enemy_dict.erase(e)
	slimes.clear()
	
	
func add_slime(v: Vector2):
	var slime: Slime = SLIME.instantiate()
	slime.position = v
	add_child(slime)
	slimes.append(slime)
	slime.body_entered.connect(_on_slime_entered)
	slime.body_exited.connect(_on_slime_exited)
	
func _on_slime_entered(enemy: Enemy):
	enemy.add_debuff(get_debuff())
		
func _on_slime_exited(enemy: Enemy):
	enemy.remove_debuff(get_debuff())
	
func get_debuff():
	var slow_debuff = SlowDebuff.new()
	slow_debuff.slow_multiplier = self.slow_ratio
	slow_debuff.buff_name = "snail slow"
	return slow_debuff
