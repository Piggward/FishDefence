class_name ASBuff
extends Buff

@export var attack_speed_multiplier: float

func apply(t: Tower):
	print("before: ", t.attack_speed)
	t.attack_speed *= attack_speed_multiplier
	print("with_buff: ", t.attack_speed)
	
	
func remove(t: Tower):
	var reciprocal = 1 / attack_speed_multiplier
	t.attack_speed *= reciprocal
	print("after buff remove; ", t.attack_speed)
