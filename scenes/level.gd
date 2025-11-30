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

func _ready():
	game_start_button = get_tree().get_first_node_in_group("GameStartButton")
	if skip_intro:
		canvas_layer.visible = true
		wave_button.visible = true
		camera_2d.position.x = 192.0
		game_start_button.visible = false
		game_title.visible = false
	else:
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
		Engine.time_scale = 2.0
	else:
		Engine.time_scale = 1.0
