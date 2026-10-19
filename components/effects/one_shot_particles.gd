extends GPUParticles2D

func _ready():
	self.emitting = true
	await finished
	self.queue_free()
