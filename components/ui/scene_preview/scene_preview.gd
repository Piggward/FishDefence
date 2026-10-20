class_name ScenePreview
extends TextureRect
## Shows a live 2D scene inside UI. The scene frames itself with its own Camera2D.
## The viewport has its own 2D world and no audio listener, so the scene can't touch the
## game's physics and its 2D sounds are silent.
##
## The viewport renders at the preview's on-screen pixel size (UI size × parent scales ×
## window stretch), so it is as sharp as the game around it. A SubViewportContainer
## renders at the UI size and stretches that image up, which blurs it.

@onready var viewport: SubViewport = $SubViewport
var _scene: PackedScene
var _instance: Node


func _ready() -> void:
	texture = viewport.get_texture()
	resized.connect(_fit_viewport)
	get_tree().root.size_changed.connect(_fit_viewport)
	_fit_viewport()


func show_scene(scene: PackedScene) -> void:
	if scene == _scene and is_instance_valid(_instance):
		return
	clear()
	_scene = scene
	_instance = scene.instantiate()
	viewport.add_child(_instance)
	_fit_viewport()


func clear() -> void:
	if is_instance_valid(_instance):
		_instance.queue_free()
	_instance = null
	_scene = null


func _fit_viewport() -> void:
	var screen_scale := (get_viewport().get_final_transform() * get_global_transform_with_canvas()).get_scale()
	viewport.size = Vector2i((size * screen_scale).round()).maxi(1)
	# The scene still sees a UI-sized area, so its camera framing doesn't change.
	viewport.size_2d_override = Vector2i(size.round()).maxi(1)
	viewport.size_2d_override_stretch = true
