class_name Shop
extends VBoxContainer
## The shop panel that slides in from the right edge. The shop button opens it; it closes
## when the mouse leaves it and reopens if the mouse comes back while it slides out.
## `open` is the state it is sliding towards, set at once, so a slide can reverse half-way
## and the placer always knows where the shop is going.

const SLIDE_TIME := 0.5

@export var open_position := Vector2(830, 9)
@export var closed_position := Vector2(1159, 9)
var open := false
var _tween: Tween


func _ready() -> void:
	position = closed_position
	mouse_entered.connect(set_open.bind(true))
	mouse_exited.connect(set_open.bind(false))


func set_open(value: bool) -> void:
	if value == open:
		return
	open = value
	EventManager.shop_opened.emit(open)
	var target := open_position if open else closed_position
	if _tween:
		_tween.kill()
	# Scaled by the distance left, so a reversed slide keeps the same speed.
	var duration := SLIDE_TIME * position.distance_to(target) / open_position.distance_to(closed_position)
	# Opening decelerates into place; closing accelerates away.
	_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT if open else Tween.EASE_IN)
	_tween.tween_property(self, "position", target, duration)
