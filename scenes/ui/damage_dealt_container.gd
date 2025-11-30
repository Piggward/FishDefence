extends Control

const TOWER_DAMAGE_ROW = preload("uid://clu7lueyxlr8e")
var tower_damages = {}
@onready var damage_row_container = $PanelContainer/MarginContainer/VBoxContainer2/DamageRowContainer


func _ready():
	GameManager.damage_dealt_container = self
	self.visible = false
	
func damage_dealt(tower: Tower, damage: int):
	self.visible = true
	var tower_row: TowerDamageRow
	if tower_damages.has(tower.fish_name):
		tower_row = tower_damages[tower.fish_name]
	else:
		var new_row: TowerDamageRow = TOWER_DAMAGE_ROW.instantiate()
		new_row.texture = tower.fish_texture
		damage_row_container.add_child(new_row)
		tower_row = new_row
		tower_damages[tower.fish_name] = new_row
	tower_row.update_damage(damage)
	
	sort_children()
	
func sort_children():
	var children = damage_row_container.get_children()
	children.sort_custom(func(a, b): return a.damage_dealt > b.damage_dealt)
	
	for i in children.size():
		damage_row_container.move_child(children[i], i)
		
