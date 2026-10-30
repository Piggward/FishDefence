class_name Level
extends Node2D
## The level's flow: title screen → intro → tutorial (first run only) → playing.
## The intro animation drives the camera, music cues and decorations and calls
## _on_intro_finished() at its end; this script decides which UI is visible.

## Start in play, without title, intro or tutorial (for running the scene while developing).
@export var debug_skip_intro := false

@onready var title_screen: TitleScreen = $TitleScreen
@onready var hud: CanvasLayer = $HUD
@onready var wave_button: NextWaveButton = $HUD/WaveButton
@onready var fast_mode_button: CheckBoxButton = $HUD/FastModeButton
@onready var intro_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera2D = $Camera2D
@onready var music: Music = $Music
@onready var deco_fish: DecoFishSpawner = $Decorations/DecoFish


func _ready() -> void:
	fast_mode_button.toggled.connect(GameManager.set_fast_mode)
	if title_screen != null:
		title_screen.start_pressed.connect(_on_title_start_pressed)
	if debug_skip_intro:
		GameManager.tutorial_done = true
	if debug_skip_intro or GameManager.intro_seen:
		_start_playing()
	else:
		_show_title()


func _show_title() -> void:
	hud.hide()
	title_screen.show()
	music.play_intro()
	deco_fish.start_spawning()


func _on_title_start_pressed() -> void:
	title_screen.hide()
	deco_fish.stop_spawning()
	intro_player.play("intro")


## Called by the intro animation's last key.
func _on_intro_finished() -> void:
	GameManager.intro_seen = true
	_start_playing()
	if not GameManager.tutorial_done:
		EventManager.tutorial_requested.emit()


func _start_playing() -> void:
	if title_screen:
		title_screen.hide()
	hud.show()
	wave_button.show()
	music.play_main_theme()
	# The camera's resting place is the intro's last keyframe, so skipping can't drift from it.
	#var intro := intro_player.get_animation("intro")
	#camera.position = _last_key(intro, ".:position")
	#camera.zoom = _last_key(intro, ".:zoom")


func _last_key(animation: Animation, path: String) -> Variant:
	var track := animation.find_track(NodePath(path), Animation.TYPE_VALUE)
	return animation.track_get_key_value(track, animation.track_get_key_count(track) - 1)
