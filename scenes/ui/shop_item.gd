class_name ShopItem
extends MarginContainer

@export var tower: PackedScene
@onready var cost = $MarginContainer/PanelContainer2/VBoxContainer/PanelContainer/HBoxContainer/Cost
@onready var name_label = $MarginContainer/PanelContainer2/VBoxContainer/PanelContainer2/Name
@onready var fish_texture = $MarginContainer/PanelContainer2/VBoxContainer/MarginContainer/FishTexture

func _ready():
	var t: Tower = tower.instantiate()
	fish_texture.texture = t.fish_texture
	name_label.text = t.fish_name
	cost.text = str(t.cost)
	

func _on_panel_container_2_mouse_entered():
	print("hovering over shopitem: ", self.name)
	pass # Replace with function body.


func _on_panel_container_2_gui_input(event):
	if event.is_action_pressed("left_click"):
		EventManager.shop_item_clicked.emit(self)
	pass # Replace with function body.
