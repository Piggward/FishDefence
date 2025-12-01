class_name Wave
extends Resource

@export var speed: int
@export var health: int
@export var wave_bounty: int
@export var enemy_bounty: int
@export var name: String
@export var amount: int

const CANNED_SOUP = preload("uid://bmj1lduug60as")
const GARBAGE = preload("uid://626io0fn6blk")
const SODA_COKE = preload("uid://me80oqeawbyf")
const SODA_FANTA = preload("uid://rotbfsa4mpd8")
const SODA_PEPSI = preload("uid://ct3hvr3suw6bd")
const SODA_SPRITE = preload("uid://bgfas7k5jabt8")
const SOYMILK_MATCH = preload("uid://qjkoel2faluk")
const WATER_BOTTLED = preload("uid://emesrplrnsbr")
const YOGURT_CUP = preload("uid://pkkn66dbbmnm")


func get_texture():
	match(name):
		"soda_coke":
			return SODA_COKE
		"canned_soup":
			return CANNED_SOUP
		"soda_pepsi":
			return SODA_PEPSI
		"soymilk_match":
			return SOYMILK_MATCH	
		"soda_fanta":
			return SODA_FANTA
		"water_bottled":
			return WATER_BOTTLED
		"soda_sprite":
			return SODA_SPRITE
		"yogurt_cup":
			return YOGURT_CUP		
		"garbage":
			return	GARBAGE		
			
func get_material():
	match(name):
		"soda_coke":
			return "can"
		"canned_soup":
			return "can"
		"soda_pepsi":
			return "can"
		"soymilk_match":
			return "paper"	
		"soda_fanta":
			return "can"
		"water_bottled":
			return "plastic"
		"soda_sprite":
			return "can"
		"yogurt_cup":
			return "plastic"		
		"garbage":
			return	"plastic bag"		
