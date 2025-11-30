class_name WaveDisplay
extends PanelContainer
@onready var label = $Label
@onready var animation_player = $AnimationPlayer

func _ready():
	visible = false

func show_new_wave(wave_number: int):
	label.text = "Wave: " + str(wave_number)
	animation_player.play("show")
