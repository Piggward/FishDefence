class_name TowerCard
extends Control

@export var tower: Tower
@onready var sub_viewport_container = $SubViewportContainer
@onready var tower_name = $PanelContainer/VBoxContainer/TitleContainer/Name
@onready var texture_rect = $PanelContainer/VBoxContainer/MarginContainer/BodyContainer/VBoxContainer/TextureContainer/TextureRect
@onready var description_label = $PanelContainer/VBoxContainer/MarginContainer/BodyContainer/VBoxContainer/PanelContainer/MarginContainer/DescriptionLabel
const DEMO_VIEWPORT = preload("uid://besqxivag63uh")

const ANCHOVY_TOWER = preload("uid://ru86gcsabmxc")
const CLOWN_TOWER = preload("uid://pv46cph2glos")
const DISCUS_TOWER = preload("uid://drtd5a4mjfa2j")
const PUFFER_TOWER = preload("uid://jdasnkkeyv3u")
const SURGEON_TOWER = preload("uid://c4f6gt4tdgpwo")
const CRAB_TOWER = preload("uid://38eeivo1kv68")

func _ready():
	#var t = CRAB_TOWER.instantiate()
	#var vp = t.get_attack_subviewport()
	#sub_viewport_container.add_child(vp)
	#tower_name = t.fish_name
	#texture_rect.texture.set_viewport_path_in_scene("SubViewportContainer/SubViewport")
	#description_label.text = t.get_description()
	
	var sub_viewport = DEMO_VIEWPORT.instantiate()
	tower.load_stats()
	var demo = tower.get_demo()
	sub_viewport.add_demo(demo)
	
	sub_viewport_container.add_child(sub_viewport)
	tower_name.text = tower.fish_name
	texture_rect.texture.set_viewport_path_in_scene("SubViewportContainer/SubViewport")
	description_label.text = tower.get_description()
	
