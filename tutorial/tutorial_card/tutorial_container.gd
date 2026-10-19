class_name TutorialContainer
extends Control

const PLACE_DEMO = preload("uid://dgemaquj4ifpp")
const SHOP_DEMO = preload("uid://vfjjfdlti3rk")
const START_WAVE_DEMO = preload("uid://b4kgvldngck0c")
const TUTORIAL_DEMO = preload("uid://ba8uppw6gwps3")

const TUTORIAL_CARD = preload("uid://ci2trvukaytw3")
var current_tutorial: TutorialCard


func _ready():
	self.visible = false
	EventManager.tutorial_requested.connect(play_tutorial)

## The tutorial, in order. Add, remove or reorder steps here.
var steps := [
	{
		"title": "Defend the reef!",
		"text": "The reef is under attack from drifting garbage! You need to build a strong defence of elite fishes to eliminate the trash before it reaches the reef.",
		"demo": TUTORIAL_DEMO,
	},
	{
		"title": "Hire defenders!",
		"text": "To the right you find the shop where you can hire fishes that defend against hostile trash. Hover over the fishes to see what they do. Your economy and your reef's health is displayed in the top left corner.",
		"demo": SHOP_DEMO,
	},
	{
		"title": "Place fishes!",
		"text": "Right click to cancel and R to rotate while placing defenders. The fish's attack range is displayed while placing.",
		"demo": PLACE_DEMO,
	},
	{
		"title": "Build mazes!",
		"text": "The trash will find the shortest path to the reef. Place your fish to make their path longer to maximize the damage output. Building mazes is essential for protecting the reef.",
		"demo": TUTORIAL_DEMO,
	},
	{
		"title": "Start the game!",
		"text": "There are 25 waves in total. Earn more recycle-bucks by defeating waves. Press the button in the bottom left corner to start the next wave. Dont forget to purchase and place your defenders first. Good luck!",
		"demo": START_WAVE_DEMO,
	},
]


func play_tutorial():
	visible = true
	GameManager.pause_game()
	show_step(0)


func show_step(index: int):
	if current_tutorial:
		current_tutorial.queue_free()
		current_tutorial = null
	if index >= steps.size():
		_finish()
		return
	var step: Dictionary = steps[index]
	var card: TutorialCard = TUTORIAL_CARD.instantiate()
	card.title = step["title"]
	card.text = step["text"]
	card.packed_scene = step["demo"]
	card.last = index == steps.size() - 1
	card.next.connect(show_step.bind(index + 1))
	current_tutorial = card
	add_child(card)


func _finish():
	GameManager.resume_game()
	visible = false
	GameManager.tutorial_done = true
