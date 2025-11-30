class_name DemoViewPort
extends SubViewport

@onready var camera_2d = $Camera2D
var zoom: Vector2

func _ready():
	camera_2d.zoom = zoom / 2

func add_demo(d: Demo):
	zoom = d.get_zoom()
	add_child(d)
