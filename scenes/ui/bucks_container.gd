extends PanelContainer

@onready var bucks_label = $HBoxContainer/MarginContainer/BucksLabel
@onready var animation_player = $AnimationPlayer

func _ready():
	bucks_label.text = str(GameManager.eco_bucks)
	GameManager.bucks_updated.connect(func(a): bucks_label.text = str(a))
	GameManager.bucks_updated.connect(func(a): animation_player.play("recycle_animation"))
