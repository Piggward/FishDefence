extends Node2D

@onready var path: Line2D = $Path
const TEST_ENEMY = preload("uid://wqreiq6q3r7x")
var path_follows = []

func _ready():
	add_enemy()
	start_loop()
	
func start_loop():
	if not is_instance_valid(self) or not is_instance_valid(get_tree()):
		return
	await get_tree().create_timer(0.75).timeout
	add_enemy()
	start_loop()
	
func get_zoom():
	return Vector2(3, 3)

func add_enemy():
	var e: Enemy = TEST_ENEMY.instantiate()
	e.demo = true
	e.health = 999
	var enemy_path = Path2D.new()
	enemy_path.curve = Curve2D.new()
	var path_follow = PathFollow2D.new()
	for p in path.points:
		enemy_path.curve.add_point(p)
		
	enemy_path.add_child(path_follow)
	path_follow.add_child(e)
	path_follow.rotates = false
	path_follows.append(path_follow)
	add_child(enemy_path)
	
func _process(delta):
	for p:PathFollow2D in path_follows:
		p.progress_ratio = clamp(p.progress_ratio + 0.00085, 0.0, 1.0)
		if p.progress_ratio == 1.0:
			p.queue_free()
			path_follows.erase(p)
		
	
