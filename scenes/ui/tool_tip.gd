class_name ToolTip
extends PanelContainer

var showing_place_tooltip = false
@onready var tooltip_label = $MarginContainer/TooltipText
var should_show_basic_tooltip = true

func _ready():
	self.visible = false
	PlaceManager.start_placing.connect(_on_start_place)
	PlaceManager.stop_placing.connect(_on_stop_place)
	
	
func _on_start_place(t: Tower):
	if not GameManager.has_rotated:
		showing_place_tooltip = true
		self.visible = true
		tooltip_label.text = "Left click to place, right click to cancel." 
		if t.can_rotate:
			tooltip_label.text = "Press R to rotate."
		
func _on_stop_place():
	if showing_place_tooltip:
		self.visible = false
