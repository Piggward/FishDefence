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

func play_tutorial():
	self.visible = true
	var tutorial: TutorialCard = TUTORIAL_CARD.instantiate()
	tutorial.title = "Defend the reef!"
	tutorial.text = "The reef is under attack from drifting garbage! You need to build a strong defence of elite fishes to eliminate the trash before it reaches the reef."
	tutorial.has_viewport = true
	tutorial.zoom = Vector2(3, 3)
	tutorial.last = false
	tutorial.packed_scene = TUTORIAL_DEMO
	tutorial.next.connect(shop_tutorial)
	current_tutorial = tutorial
	add_child(tutorial)

func shop_tutorial():
	current_tutorial.queue_free()
	var tutorial: TutorialCard = TUTORIAL_CARD.instantiate()
	tutorial.title = "Hire defenders!"
	tutorial.text = "To the right you find the shop where you can hire fishes that defend against hostile trash. Hover over the fishes to see what they do. Your economy and your reef's health is displayed in the top left corner."
	tutorial.has_viewport = true
	tutorial.packed_scene = SHOP_DEMO
	tutorial.last = false
	tutorial.zoom = Vector2(4, 4)
	tutorial.next.connect(place_tutorial)
	add_child(tutorial)
	current_tutorial = tutorial
	
func place_tutorial():
	current_tutorial.queue_free()
	var tutorial: TutorialCard = TUTORIAL_CARD.instantiate()
	tutorial.title = "Place fishes!"
	tutorial.text = "Right click to cancel and R to rotate while placing defenders. The fish's attack range is displayed while placing."
	tutorial.has_viewport = true
	tutorial.packed_scene = PLACE_DEMO
	tutorial.last = false
	tutorial.zoom = Vector2(3, 3)
	tutorial.next.connect(maze_tutorial)
	add_child(tutorial)
	current_tutorial = tutorial
	
func maze_tutorial():
	current_tutorial.queue_free()
	var tutorial: TutorialCard = TUTORIAL_CARD.instantiate()
	tutorial.title = "Build mazes!"
	tutorial.text = "The trash will find the shortest path to the reef. Place your fish to make their path longer to maximize the damage output. Building mazes is essential for protecting the reef."
	tutorial.has_viewport = true
	tutorial.packed_scene = TUTORIAL_DEMO
	tutorial.last = false
	tutorial.zoom = Vector2(3, 3)
	tutorial.next.connect(next_wave_tutorial)
	add_child(tutorial)
	current_tutorial = tutorial
	
func next_wave_tutorial():
	current_tutorial.queue_free()
	var tutorial: TutorialCard = TUTORIAL_CARD.instantiate()
	tutorial.title = "Start the game!"
	tutorial.text = "There are 25 waves in total. Earn more recycle-bucks by defeating waves. Press the button in the bottom left corner to start the next wave. Dont forget to purchase and place your defenders first. Good luck!"
	tutorial.has_viewport = true
	tutorial.packed_scene = START_WAVE_DEMO
	tutorial.last = true
	tutorial.zoom = Vector2(1.4, 1.4)
	tutorial.next.connect(on_tutorial_done)
	add_child(tutorial)
	current_tutorial = tutorial

func on_tutorial_done():
	get_tree().root.process_mode = Node.PROCESS_MODE_PAUSABLE
	self.visible = false
	GameManager.tutorial_done = true
	
