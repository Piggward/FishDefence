class_name SlowDebuff
extends Buff

@export var slow_multiplier: float = 0.8


func apply(t: Enemy):
	t.speed *= slow_multiplier


func remove(t: Enemy):
	t.speed /= slow_multiplier
