extends AudioStreamPlayer2D
const ISLAND_MEET_AND_GREET = preload("uid://gdcfxmg2g8ef")
var slow = false
const MARCH_OF_THE_SPOONS = preload("uid://ds4u0qu5vwmtu")
const TAKE_A_CHANCE = preload("uid://2skpnece60m6")
const END_OF_THE_ERA = preload("uid://dfnjl1n31rmfm")

func _ready():
	EventManager.win.connect(_on_win)
	EventManager.lose.connect(_on_lose)
	EventManager.endless_started.connect(_on_endless)
	
func _on_endless():
	self.stream = MARCH_OF_THE_SPOONS
	self.play()

func _on_win():
	self.stream = TAKE_A_CHANCE
	self.play()

func _on_lose():
	self.stream = END_OF_THE_ERA
	self.play()

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
