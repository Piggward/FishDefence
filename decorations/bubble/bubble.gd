extends Sprite2D

var speed := 60.0                # upward speed
var sway_amplitude := 40.0       # how far left/right
var sway_frequency := 5.0        # how fast it wiggles
var time := 0.0
const AUDIO_ONETIME = preload("uid://dfms11u6nqgkq")
const BUBBLE = preload("uid://p4ls7da1ntch")

func _ready():
	await get_tree().create_timer(1.5).timeout
	var a = AUDIO_ONETIME.instantiate()
	a.stream = BUBBLE
	a.volume_db -= 5
	get_tree().root.add_child(a)
	self.queue_free()

func _process(delta):
	time += delta

	# Vertical rise
	position.y -= speed * delta

	# Horizontal wiggle (sine wave)
	position.x += sin(time * sway_frequency) * sway_amplitude * delta
