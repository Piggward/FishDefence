class_name RandomShit
extends Sprite2D

const CANNED_SOUP = preload("uid://bmj1lduug60as")
const GARBAGE = preload("uid://626io0fn6blk")
const SODA_COKE = preload("uid://me80oqeawbyf")
const SODA_FANTA = preload("uid://rotbfsa4mpd8")
const SODA_PEPSI = preload("uid://ct3hvr3suw6bd")
const SODA_SPRITE = preload("uid://bgfas7k5jabt8")
const SOYMILK_MATCH = preload("uid://qjkoel2faluk")
const WATER_BOTTLED = preload("uid://emesrplrnsbr")
const YOGURT_CUP = preload("uid://pkkn66dbbmnm")
var speed = 100
@export var moving = true

const items = [
	CANNED_SOUP,
	GARBAGE,
	SODA_COKE,
	SODA_FANTA,
	SODA_PEPSI,
	SODA_SPRITE,
	SOYMILK_MATCH,
	WATER_BOTTLED,
	YOGURT_CUP,
]

func _ready():
	self.texture = items[randi_range(0, items.size()-1)]
	self.speed *= randf_range(0.5, 1.5)
	slow()
	
func slow():
	if not moving:
		return
	self.speed *= 0.9
	await get_tree().create_timer(0.3).timeout
	slow()

func _process(delta):
	self.position.x += delta * speed
