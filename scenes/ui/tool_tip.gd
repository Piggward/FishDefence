class_name ToolTip
extends PanelContainer

var showing_place_tooltip = false
@onready var tooltip_label = $MarginContainer/TooltipText
var should_show_basic_tooltip = true

func _ready():
	self.visible = false
	PlaceManager.start_placing.connect(_on_start_place)
	PlaceManager.stop_placing.connect(_on_stop_place)
	var xc = get_tree().get_first_node_in_group("EnemyContainer")
	xc.wave_start.connect(_on_wave_start)
	
func _on_wave_start(n):
	if n == 1:
		await get_tree().create_timer(5).timeout
		self.visible = true
		tooltip_label.text = "";
		tooltip_label.text = "Press space to speed up time." 
		await get_tree().create_timer(5).timeout
		if tooltip_label.text == "Press space to speed up time.":
			self.visible = false
	if n == 3:
		should_show_basic_tooltip = false
	
	
func _on_start_place(t: Tower):
	if should_show_basic_tooltip:
		showing_place_tooltip = true
		self.visible = true
		tooltip_label.text = "Left click to place, right click to cancel." 
		if t.can_rotate:
			tooltip_label.text += " Press R to rotate."
		
func _on_stop_place():
	if showing_place_tooltip:
		self.visible = false
