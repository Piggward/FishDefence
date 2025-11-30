class_name TowerDamageRow
extends HBoxContainer

@export var texture: Texture
@onready var tower_texture = $TowerTexture
@onready var tower_damage_dealt = $TowerDamageDealt
var damage_dealt = 0

func _ready():
	tower_texture.texture = texture
	
func update_damage(dmg: int):
	damage_dealt += dmg
	tower_damage_dealt.text = str(damage_dealt)
