class_name GameOverScreen
extends PanelContainer

@export var won: bool = false
@onready var label = %ResultLabel
@onready var animated_sprite_2d = $VBoxContainer/AnimatedSprite2D
@onready var play_again: Button = $VBoxContainer/PlayAgain
@onready var exit: Button = $VBoxContainer/Exit
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
	GameManager.resume_game()
	EventManager.endless_started.emit()
	self.visible = false
	
func _on_play_again_expert_pressed():
	GameManager.easy_mode = false
	_on_play_again_pressed()
	
func _on_win():
	self.visible = true
	endless.visible = true
	GameManager.pause_game()
	label.text = "Congratulations! You won!!"
	animated_sprite_2d.play("Win")

func _on_lose():
	self.visible = true
	endless.visible = false
	GameManager.pause_game()
	label.text = "Game over! You lost on wave " + str(GameManager.current_wave)
	animated_sprite_2d.play("Lose")
	
func _on_exit_pressed():
	get_tree().quit()
	
func _on_play_again_pressed():
	GameManager.restart()
