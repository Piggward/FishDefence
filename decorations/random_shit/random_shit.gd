class_name RandomShit
extends Sprite2D

var speed = 100
@export var moving = true

func _ready():
	self.texture = get_random_item()
	self.speed *= randf_range(0.5, 1.5)
	slow()
	
func slow():
	if not moving:
		return
	self.speed *= 0.9
	await get_tree().create_timer(0.3).timeout
	slow()
	
func get_random_item():
	return GameData.trash_textures().pick_random()

func _process(delta):
	self.position.x += delta * speed
