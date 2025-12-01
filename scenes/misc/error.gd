extends AudioStreamPlayer2D

func _ready():
	EventManager.error.connect(play)
