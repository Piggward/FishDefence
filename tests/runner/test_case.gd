class_name TestCase
extends RefCounted
## Base for test scripts. Every method whose name starts with `test_` runs on a fresh
## instance; methods may `await`. Use check()/check_eq() instead of assert so all failures
## are reported. List error texts a test deliberately triggers in `expected_errors`.

const LEVEL := "res://main/level/level.tscn"

var tree: SceneTree
var failures: Array[String] = []
var expected_errors: Array[String] = []


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func check_eq(actual, expected, message := "") -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [message, expected, actual])


func frames(n := 1) -> void:
	for i in n:
		await tree.process_frame


func physics_frames(n := 1) -> void:
	for i in n:
		await tree.physics_frame


## Loads the level with run state reset; returns the level node. By default the intro and
## tutorial count as seen, so the level starts in play; `first_run` starts at the title.
func load_level(first_run := false) -> Node:
	var gm = game_manager()
	gm.eco_bucks = gm.START_BUCKS
	gm.health = gm.START_HEALTH
	gm.current_wave = 0
	Engine.time_scale = 1.0
	gm.easy_mode = true
	gm.has_rotated = false
	gm.intro_seen = not first_run
	gm.tutorial_done = not first_run
	tree.root.process_mode = Node.PROCESS_MODE_PAUSABLE
	tree.change_scene_to_file(LEVEL)
	await frames(30)
	return tree.current_scene


## Called after each test; frees the level so the next test starts clean.
func cleanup() -> void:
	tree.root.process_mode = Node.PROCESS_MODE_PAUSABLE
	if tree.current_scene:
		tree.unload_current_scene()
	await frames(3)


# Node access for tests, kept in one place so scene wiring changes only touch these.
func game_manager() -> Node:
	return tree.root.get_node("GameManager")


func game_data() -> Node:
	return tree.root.get_node("GameData")


func tile_grid() -> TileGrid:
	return tree.current_scene.get_node("TileGrid")


func placer() -> Placer:
	return tree.current_scene.get_node("PlacerLayer/Placer")


func enemy_container() -> EnemyContainer:
	return tree.current_scene.get_node("EnemyContainer")


func tower_card() -> TowerCard:
	return tree.current_scene.get_node("HUD/TowerDescriptionContainer/TowerCard")


func next_wave_button() -> NextWaveButton:
	return tree.current_scene.get_node("HUD/WaveButton")


func shop_items() -> Array:
	return tree.root.find_children("*", "", true, false).filter(func(n): return n is ShopItem and n.visible)


# Building blocks

func free_tiles() -> Array:
	var tiles := []
	for row in tile_grid().grid_array:
		for t in row:
			if t.is_free():
				tiles.append(t)
	return tiles


## Tiles where a 2x2 tower fits right now, without blocking anyone.
func placeable_tiles() -> Array:
	var g := tile_grid()
	var tiles := []
	for t in free_tiles():
		if g.can_place(t):
			g._set_solid(g._footprint(t), false)
			tiles.append(t)
	return tiles


## Buys and places a tower through the Placer, as a click would. Returns the tower or null.
func place_tower(scene: PackedScene, tile: Tile) -> Tower:
	var p := placer()
	p.hover_tile = tile
	p._spawn_ghost(scene)
	p.mouse_entered_tile(tile)
	await physics_frames(3)
	var placed: bool = p.try_place()
	p.end_placing()
	await physics_frames(3)
	return tile.object.object if placed else null


## Picks up the tower on `from` and drops it on `to`, as a drag would.
func move_tower(from: Tile, to: Tile) -> bool:
	var p := placer()
	p.hover_tile = from
	p.try_pickup()
	await physics_frames(2)
	p.mouse_entered_tile(to)
	await physics_frames(2)
	return p.try_place()


## A standing enemy on the grid, for placement and buff tests.
func spawn_enemy_at(position: Vector2, speed := 0.0) -> Enemy:
	var enemy: Enemy = load("res://entities/enemies/enemy.tscn").instantiate()
	enemy.speed = speed
	enemy.health = 100000
	var container := enemy_container()
	enemy.tile_grid = container.tile_grid
	# Position first: the enemy picks its start cell from where it is when added.
	enemy.position = container.to_local(position)
	container.add_child(enemy)
	enemy.on_start_reached()
	container.alive_enemies.append(enemy)
	await physics_frames(3)
	return enemy


# Mouse input, for tests that go through the real GUI and physics picking

func screen_pos(ci: CanvasItem, local := Vector2.ZERO) -> Vector2:
	return tree.root.get_final_transform() * (ci.get_global_transform_with_canvas() * local)


func mouse_move(pos: Vector2) -> void:
	var e := InputEventMouseMotion.new()
	e.position = pos
	e.global_position = pos
	Input.parse_input_event(e)
	tree.root.push_input(e)


func mouse_button(pos: Vector2, pressed: bool, button := MOUSE_BUTTON_LEFT) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = button
	e.pressed = pressed
	e.position = pos
	e.global_position = pos
	Input.parse_input_event(e)
	tree.root.push_input(e)


## Clicks the "Next wave" button through the GUI.
func press_next_wave() -> void:
	var button := next_wave_button()
	var pos := screen_pos(button, button.size / 2)
	await mouse_glide(pos + Vector2(0, -30), pos, 3)
	mouse_button(pos, true)
	await frames(2)
	mouse_button(pos, false)
	await frames(2)


func mouse_glide(from: Vector2, to: Vector2, steps := 6) -> void:
	for i in steps + 1:
		mouse_move(from.lerp(to, float(i) / steps))
		await frames(2)
