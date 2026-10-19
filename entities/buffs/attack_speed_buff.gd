class_name ASBuff
extends Buff

@export var attack_speed_multiplier: float


func apply(t: Tower):
	t.attack_speed *= attack_speed_multiplier


func remove(t: Tower):
	t.attack_speed /= attack_speed_multiplier
