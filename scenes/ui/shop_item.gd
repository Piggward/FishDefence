class_name ShopItem
extends MarginContainer

@onready var cost = $MarginContainer/PanelContainer2/VBoxContainer/PanelContainer/HBoxContainer/Cost
@onready var name_label = $MarginContainer/PanelContainer2/VBoxContainer/PanelContainer2/Name
@onready var fish_texture = $MarginContainer/PanelContainer2/VBoxContainer/MarginContainer/FishTexture
const TOWER_CARD = preload("uid://bxmg00ne8giic")

@export var tower_type: TowerType
var tower_card_container: Control

enum TowerType { CRAB, SURGEON, ANCHOVY, PUFFER, CLOWN, SNAIL, DISCUS }

const ANCHOVY_TOWER = preload("uid://ru86gcsabmxc")
const CLOWN_TOWER = preload("uid://pv46cph2glos")
const DISCUS_TOWER = preload("uid://drtd5a4mjfa2j")
const PUFFER_TOWER = preload("uid://jdasnkkeyv3u")
const SURGEON_TOWER = preload("uid://c4f6gt4tdgpwo")
const SNAIL = preload("uid://b4q4obpovd6jh")
const CRAB_TOWER = preload("uid://38eeivo1kv68")

func _ready():
	var t: Tower = get_tower(tower_type)
	t.load_stats()
	fish_texture.texture = t.fish_texture
	name_label.text = t.fish_name
	cost.text = str(t.cost)
	tower_card_container = get_tree().get_first_node_in_group("TowerCardContainer")
	
func get_tower(t: TowerType) -> Tower:
	match(t):
		TowerType.CRAB:
			return CRAB_TOWER.instantiate()
		TowerType.SURGEON:
			return SURGEON_TOWER.instantiate()
		TowerType.CLOWN:
			return CLOWN_TOWER.instantiate()
		TowerType.SNAIL:
			return SNAIL.instantiate()
		TowerType.ANCHOVY:
			return ANCHOVY_TOWER.instantiate()
		TowerType.PUFFER:
			return PUFFER_TOWER.instantiate()
		TowerType.DISCUS:
			return DISCUS_TOWER.instantiate()
	return null

func _on_panel_container_2_mouse_entered():
	print("hovering over shopitem: ", self.name)
	var t = get_tower(self.tower_type)
	var tower_card = TOWER_CARD.instantiate()
	tower_card.tower = t
	tower_card_container.add_child(tower_card)
	pass # Replace with function body.


func _on_panel_container_2_gui_input(event):
	if event.is_action_pressed("left_click"):
		EventManager.shop_item_clicked.emit(self)
	pass # Replace with function body.


func _on_panel_container_2_mouse_exited():
	for child in tower_card_container.get_children():
		child.free()
	pass # Replace with function body.
