extends AudioStreamPlayer2D

var range_low = 0.8
var range_high = 1.2

func _ready():
	self.pitch_scale = randf_range(range_low, range_high)
	self.play()
	await finished
	self.queue_free()
