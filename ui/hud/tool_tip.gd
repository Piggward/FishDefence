class_name ToolTip
extends PanelContainer

var showing_place_tooltip = false
@onready var tooltip_label = $MarginContainer/TooltipText

func _ready():
	self.visible = false
	EventManager.placing_started.connect(_on_start_place)
	EventManager.placing_stopped.connect(_on_stop_place)
	
	
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
