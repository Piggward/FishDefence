class_name Level
extends Node2D

@onready var animation_player = $AnimationPlayer
var game_start_button: Control
@onready var music = $Music
@onready var deco_fish = $Decorations/DecoFish
var started = false
@export var skip_intro = true
@onready var canvas_layer = $CanvasLayer
@onready var wave_button = $CanvasLayer/WaveButton
@onready var camera_2d = $Camera2D
@onready var game_title = $"CanvasLayer2/Game Title"
@onready var volume_c_ontainer = $CanvasLayer2/VolumeCOntainer
@onready var expert_mode_button = $CanvasLayer2/ExpertModeButton

func _ready():
	game_start_button = get_tree().get_first_node_in_group("GameStartButton")
	if skip_intro or GameManager.skip_intro:
		canvas_layer.visible = true
		wave_button.visible = true
		camera_2d.position.x = 192.0
		game_start_button.visible = false
		game_title.visible = false
		volume_c_ontainer.visible = false
		expert_mode_button.visible = false
		music.play_main_theme()
		game_start_button.pressed.emit()
	else:
		canvas_layer.visible = false
		wave_button.visible = false
		game_start_button.visible = true
		game_title.visible = true
		volume_c_ontainer.visible = true
		expert_mode_button.visible = true
		game_start_button.pressed.connect(_on_start)
		music.play_intro()
		spawn_fish()
	
func spawn_fish():
	deco_fish.spawn_fishes(25)
	await get_tree().create_timer(4).timeout
	if not started:
		spawn_fish()
	
func _on_start():
	animation_player.play("intro")
	started = true
	
func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		Engine.time_scale = 1.5
	else:
		Engine.time_scale = 1.0
