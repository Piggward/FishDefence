class_name SlowDebuff
extends Buff

@export var slow_multiplier: float = 0.8

func apply(t: Enemy):
	print("before: ", t.speed)
	t.speed *= slow_multiplier
	print("with_buff: ", t.speed)
	
	
func remove(t: Enemy):
	var reciprocal = 1 / slow_multiplier
	t.speed *= reciprocal
	print("after buff remove; ", t.speed)
