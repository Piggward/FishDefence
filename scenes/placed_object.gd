class_name PlacedObject
extends Area2D

@export var object: Tower

func set_object_enabled(value: bool):
	if value:
		object.enable()
	else:
		object.disable()
		
func rotate_object():
	object.rotation_degrees += 90
	if object.rotation_degrees >= 360: 
		object.rotation_degrees -= 360
	if object.rotation_degrees < 0: 
		object.rotation_degrees += 360
