class_name ScenePreview
extends SubViewportContainer
## Shows a live 2D scene inside UI. The scene frames itself with its own Camera2D.
## The viewport has its own 2D world and no audio listener, so the scene can't touch the
## game's physics and its 2D sounds are silent.

@onready var viewport: SubViewport = $SubViewport
var _scene: PackedScene
var _instance: Node


func show_scene(scene: PackedScene) -> void:
	if scene == _scene and is_instance_valid(_instance):
		return
	clear()
	_scene = scene
	_instance = scene.instantiate()
	viewport.add_child(_instance)


func clear() -> void:
	if is_instance_valid(_instance):
		_instance.queue_free()
	_instance = null
	_scene = null
