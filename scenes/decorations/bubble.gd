extends Sprite2D

var speed := 60.0                # upward speed
var sway_amplitude := 40.0       # how far left/right
var sway_frequency := 5.0        # how fast it wiggles
var time := 0.0

func _ready():
	await get_tree().create_timer(1.5).timeout
	self.queue_free()

func _process(delta):
	time += delta

	# Vertical rise
	position.y -= speed * delta

	# Horizontal wiggle (sine wave)
	position.x += sin(time * sway_frequency) * sway_amplitude * delta
