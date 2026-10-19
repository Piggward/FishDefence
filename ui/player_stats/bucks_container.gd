extends PanelContainer

@onready var bucks_label = %BucksLabel
@onready var bucks_animation = %BucksAnimation
@onready var heart_label = %HeartLabel
@onready var heart_animation = %HeartAnimation


func _ready():
	bucks_label.text = str(GameManager.eco_bucks)
	heart_label.text = str(GameManager.health)
	EventManager.bucks_updated.connect(_on_bucks_updated)
	EventManager.health_updated.connect(_on_health_updated)


func _on_bucks_updated(value: int):
	bucks_label.text = str(value)
	bucks_animation.play("recycle_animation")


func _on_health_updated(value: int):
	heart_label.text = str(value)
	heart_animation.play("health_updated")
