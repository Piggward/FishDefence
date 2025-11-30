extends AudioStreamPlayer2D
const ISLAND_MEET_AND_GREET = preload("uid://gdcfxmg2g8ef")
var slow = false
const MARCH_OF_THE_SPOONS = preload("uid://ds4u0qu5vwmtu")

func play_intro():
	self.stream = ISLAND_MEET_AND_GREET
	self.play()

func play_main_theme():
	slow = false
	self.pitch_scale = 1.0
	stream = MARCH_OF_THE_SPOONS
	self.play()

func slow_down():
	slow = true
	
func _process(delta):
	if slow:
		self.pitch_scale -= 0.0005
	if pitch_scale <= 0:
		slow = false
