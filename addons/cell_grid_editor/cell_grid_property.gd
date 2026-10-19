@tool
extends EditorProperty
## A grid of toggle buttons for an Array[Vector2] of cell offsets around the owner.
## The centre cell is the owner itself. The grid grows to fit cells already in the array.

const MIN_RADIUS := 3
const BUTTON_SIZE := 20
const ON_COLOR := Color("24b8a0")
const OWNER_COLOR := Color("ff8e58")

var _grid := GridContainer.new()
var _buttons := {}  # Vector2i -> Button
var _radius := -1
var _updating := false


func _init():
	_grid.add_theme_constant_override("h_separation", 2)
	_grid.add_theme_constant_override("v_separation", 2)
	add_child(_grid)
	set_bottom_editor(_grid)


func _update_property():
	var cells: Array = get_edited_object()[get_edited_property()]
	var needed := MIN_RADIUS
	for c in cells:
		needed = maxi(needed, maxi(absi(int(c.x)), absi(int(c.y))))
	if needed != _radius:
		_build(needed)
	_updating = true
	for cell in _buttons:
		if cell != Vector2i.ZERO:
			_buttons[cell].button_pressed = cells.has(Vector2(cell))
	_updating = false


func _build(radius: int):
	_radius = radius
	for child in _grid.get_children():
		child.queue_free()
	_buttons.clear()
	_grid.columns = radius * 2 + 1
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			var cell := Vector2i(x, y)
			var button := Button.new()
			button.custom_minimum_size = Vector2(BUTTON_SIZE, BUTTON_SIZE)
			button.focus_mode = Control.FOCUS_NONE
			if cell == Vector2i.ZERO:
				button.disabled = true
				button.tooltip_text = "The tower itself"
				_set_fill(button, OWNER_COLOR, ["disabled"])
			else:
				button.toggle_mode = true
				button.tooltip_text = "%d, %d" % [x, y]
				_set_fill(button, ON_COLOR, ["pressed", "hover_pressed"])
				button.toggled.connect(_on_toggled.bind(cell))
			_buttons[cell] = button
			_grid.add_child(button)


func _set_fill(button: Button, color: Color, states: Array):
	var style := StyleBoxFlat.new()
	style.bg_color = color
	for state in states:
		button.add_theme_stylebox_override(state, style)


func _on_toggled(pressed: bool, cell: Vector2i):
	if _updating:
		return
	# Typed copy: the property is Array[Vector2] and rejects an untyped Array.
	var cells: Array[Vector2] = []
	cells.assign(get_edited_object()[get_edited_property()])
	var value := Vector2(cell)
	if pressed and not cells.has(value):
		cells.append(value)
	elif not pressed:
		cells.erase(value)
	emit_changed(get_edited_property(), cells)
