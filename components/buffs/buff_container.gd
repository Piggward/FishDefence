class_name BuffContainer
extends Node2D
## Holds Buff nodes for its parent. Buffs with the same name don't stack: one of them is
## applied at a time, and when it leaves, another one with that name takes over.

## Buff name -> the Buff whose effect is currently applied.
var _applied := {}


func _ready():
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)


func add(b: Buff) -> void:
	add_child(b)


func remove(buff_name: String) -> void:
	for c: Buff in get_children():
		if c.buff_name == buff_name and not c.is_queued_for_deletion():
			c.queue_free()
			return


func _on_child_entered_tree(b: Buff):
	if not _applied.has(b.buff_name):
		_apply(b)


func _on_child_exiting_tree(b: Buff):
	if _applied.get(b.buff_name) != b:
		return
	b.remove(get_parent())
	_applied.erase(b.buff_name)
	for c: Buff in get_children():
		if c != b and c.buff_name == b.buff_name:
			_apply(c)
			return


func _apply(b: Buff):
	_applied[b.buff_name] = b
	b.apply(get_parent())
