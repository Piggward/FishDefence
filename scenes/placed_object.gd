class_name PlacedObject
extends Area2D

@export var object: Tower

func set_object_enabled(value: bool):
	if value:
		object.enable()
	else:
		object.disable()
