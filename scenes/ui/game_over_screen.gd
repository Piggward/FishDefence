class_name GameOverScreen
extends PanelContainer

@export var won: bool = false
@onready var label = $VBoxContainer/MarginContainer/Label
@onready var animated_sprite_2d = $VBoxContainer/AnimatedSprite2D
@onready var play_again: Button = $VBoxContainer/PlayAgain
@onready var exit: Button = $VBoxContainer/Exit
const TEST_NAVIGATION_WITH_TILESET = preload("uid://drkhpej01r8vi")
@onready var play_again_expert = $VBoxContainer/PlayAgainExpert
@onready var endless = $VBoxContainer/Endless

func _ready():
	self.visible = false
	EventManager.win.connect(_on_win)
	EventManager.lose.connect(_on_lose)
	exit.pressed.connect(_on_exit_pressed)
	play_again.pressed.connect(_on_play_again_pressed)
	play_again_expert.pressed.connect(_on_play_again_expert_pressed)
	endless.pressed.connect(_on_endless_pressed)
	
func _on_endless_pressed():
	get_tree().root.process_mode = Node.PROCESS_MODE_PAUSABLE
	EventManager.endless_started.emit()
	self.visible = false
	
func _on_play_again_expert_pressed():
	GameManager.easy_mode = false
	_on_play_again_pressed()
	
func _on_win():
	self.visible = true
	get_tree().root.process_mode = Node.PROCESS_MODE_DISABLED
	label.text = "Congratulations! You won!!"
	animated_sprite_2d.play("Win")

func _on_lose():
	self.visible = true
	get_tree().root.process_mode = Node.PROCESS_MODE_DISABLED
	label.text = "Game over! You lost on wave " + str(GameManager.current_wave)
	animated_sprite_2d.play("Lose")
	
func _on_exit_pressed():
	get_tree().quit()
	
func _on_play_again_pressed():
	GameManager.reset()
	get_tree().root.process_mode = Node.PROCESS_MODE_PAUSABLE
	for child in get_tree().root.get_children():
		if child.name.contains("Manager") or child is Level:
			continue
		child.queue_free()
	get_tree().change_scene_to_file("res://scenes/test_navigation_with_tileset.tscn")
