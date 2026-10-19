extends AudioStreamPlayer

func _ready():
	EventManager.error.connect(play)
