class_name ShopItem
extends MarginContainer

@onready var cost_label = %Cost
@onready var name_label = %NameLabel
@onready var fish_texture = %FishTexture
@onready var panel_container_2 = $MarginContainer/PanelContainer2

@export var tower_scene: PackedScene
## Shown in the tower card while this item is hovered.
@export var demo_scene: PackedScene
var stats: TowerStats
var cost: int


func _ready():
	# Read stats and icon from the tower scene once.
	var tower: Tower = tower_scene.instantiate()
	stats = tower.stats
	fish_texture.texture = tower.fish_texture
	tower.free()
	name_label.text = stats.fish_name
	set_stats()
	EventManager.expert_updated.connect(set_stats)
	EventManager.bucks_updated.connect(_on_bucks_updated)


func set_stats():
	cost = stats.get_cost()
	cost_label.text = str(cost)
	_on_bucks_updated(GameManager.eco_bucks)


func _on_bucks_updated(bucks: int):
	panel_container_2.self_modulate = Color("24b8a0") if cost <= bucks else Color("da6175")


func _on_button_mouse_entered():
	EventManager.shop_item_hovered.emit(self)


## The Button fires on mouse-down (action mode Press): the drag to the map starts here
## and the Placer places the tower on release.
func _on_button_pressed():
	EventManager.shop_item_clicked.emit(self)


func _on_button_mouse_exited():
	EventManager.shop_item_unhovered.emit()
