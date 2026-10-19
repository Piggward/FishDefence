@tool
extends EditorInspectorPlugin
## Replaces the inspector editor of properties exported with
## @export_custom(PROPERTY_HINT_NONE, "cell_grid") by a clickable grid.

const HINT := "cell_grid"


func _can_handle(_object) -> bool:
	return true


func _parse_property(_object, type, name, _hint_type, hint_string, _usage, _wide) -> bool:
	if type != TYPE_ARRAY or hint_string != HINT:
		return false
	add_property_editor(name, preload("cell_grid_property.gd").new())
	return true
