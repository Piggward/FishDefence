extends PanelContainer

@onready var bucks_label = $HBoxContainer2/HBoxContainer/MarginContainer/BucksLabel
@onready var heart_label = $HBoxContainer2/HBoxContainer2/MarginContainer/HeartLabel
@onready var heart_animation = $HBoxContainer2/HBoxContainer2/HeartAnimation
@onready var animation_player = $HBoxContainer2/HBoxContainer/AnimationPlayer

func _ready():
	bucks_label.text = str(GameManager.eco_bucks)
	GameManager.bucks_updated.connect(func(a): bucks_label.text = str(a))
	GameManager.bucks_updated.connect(func(a): animation_player.play("recycle_animation"))
	heart_label.text = str(GameManager.health)
	GameManager.health_updated.connect(func(a): heart_label.text = str(a))
	GameManager.health_updated.connect(func(a): heart_animation.play("health_updated"))
