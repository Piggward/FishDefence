class_name TowerCard
extends Control

@export var tower: Tower
@onready var sub_viewport_container = $SubViewportContainer
@onready var tower_name = $PanelContainer/VBoxContainer/TitleContainer/Name
@onready var texture_rect = $PanelContainer/VBoxContainer/MarginContainer/BodyContainer/VBoxContainer/TextureContainer/TextureRect
@onready var description_label = $PanelContainer/VBoxContainer/MarginContainer/BodyContainer/VBoxContainer/PanelContainer/MarginContainer/DescriptionLabel
const DEMO_VIEWPORT = preload("uid://besqxivag63uh")

func _ready():
	var sub_viewport = DEMO_VIEWPORT.instantiate()
	tower.load_stats()
	var demo = tower.get_demo()
	sub_viewport.add_demo(demo)
	sub_viewport_container.add_child(sub_viewport)
	texture_rect.texture.set_viewport_path_in_scene("SubViewportContainer/SubViewport")
	tower_name.text = tower.fish_name
	description_label.text = tower.get_description()
	
