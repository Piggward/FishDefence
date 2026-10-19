extends TestCase
## Whole-game flows, driven through the real GUI and physics where it matters.


## Dragging an item from the shop onto the map places the tower and charges its cost.
func test_dragging_from_shop_places_and_charges():
	await load_level()
	game_manager().eco_bucks = 100000
	var shop_button: Control = tree.root.find_children("ShopButton", "", true, false)[0]
	var tiles := placeable_tiles()
	var items := shop_items()
	var placed := 0
	var spent := 0
	for i in 4:
		await mouse_glide(Vector2(10, 10), screen_pos(shop_button, shop_button.size / 2), 3)
		await frames(30)
		var item: ShopItem = items[i]
		var panel: Control = item.get_node("MarginContainer/PanelContainer2")
		var from := screen_pos(panel, panel.size / 2)
		await mouse_glide(from + Vector2(0, 20), from, 3)
		mouse_button(from, true)
		await frames(3)
		var tile: Tile = tiles[i * 9 % tiles.size()]
		var to := screen_pos(tile, tile.size / 2)
		await mouse_glide(from, to, 8)
		var bucks_before: int = game_manager().eco_bucks
		mouse_button(to, false)
		await frames(4)
		if tile.object != null:
			placed += 1
			spent += bucks_before - game_manager().eco_bucks
			check_eq(bucks_before - game_manager().eco_bucks, item.cost, "cost charged for %s" % item.stats.fish_name)
		mouse_button(to, true, MOUSE_BUTTON_RIGHT)
		mouse_button(to, false, MOUSE_BUTTON_RIGHT)
		await frames(4)
		check_eq(placer().state, Placer.State.IDLE, "placer idle after cancelling drag %d" % i)
	check(placed >= 3, "at least 3 of 4 drags placed a tower (placed %d)" % placed)


## A wave is cleared even when towers are moved around while it runs.
func test_wave_clears_while_towers_are_moved():
	await load_level()
	var gm = game_manager()
	gm.eco_bucks = 100000
	gm.health = 100000
	var tiles := placeable_tiles()
	for i in 6:
		await place_tower(load("res://entities/towers/surgeon_fish/surgeon_tower.tscn"), tiles[i * 11 % tiles.size()])
	var container := enemy_container()
	await press_next_wave()
	check(not next_wave_button().visible, "the button hides while the wave runs")
	for f in 6000:
		await tree.process_frame
		if f % 600 == 300:
			var occupied := tiles.filter(func(t): return t.object != null)
			var free := placeable_tiles()
			if not occupied.is_empty() and not free.is_empty():
				await move_tower(occupied.pick_random(), free.pick_random())
		if next_wave_button().visible:
			break
	check(container.alive_enemies.is_empty(), "every enemy is gone (%d left)" % container.alive_enemies.size())
	check(next_wave_button().visible, "the next wave can be started")


## Losing while holding a tower, then "Play again", must leave the placer usable (F1).
func test_play_again_after_losing_while_placing():
	await load_level()
	var gm = game_manager()
	gm.eco_bucks = 100000
	var p := placer()
	p.hover_tile = free_tiles()[0]
	p._spawn_ghost(load("res://entities/towers/crab/crab_tower.tscn"))
	check_eq(p.state, Placer.State.PLACING, "holding a tower")
	gm.player_damage(gm.health)
	await frames(5)
	gm.restart()
	await frames(30)
	check_eq(placer().state, Placer.State.IDLE, "placer idle after play again")
	var tile: Tile = free_tiles()[5]
	var pos := screen_pos(tile, tile.size / 2)
	await mouse_glide(Vector2(50, 50), pos)
	mouse_button(pos, true)
	await frames(3)
	mouse_button(pos, false)
	await frames(5)


## Losing to an enemy at the goal shows the lose screen only: no win, no endless option.
func test_losing_mid_wave_shows_only_the_lose_screen():
	await load_level()
	game_manager().health = 1
	var won := [false]
	var on_win := func(): won[0] = true
	EventManager.win.connect(on_win)
	await press_next_wave()
	check(not next_wave_button().visible, "the button hides while the wave runs")
	for f in 6000:
		await tree.process_frame
		if tree.root.process_mode == Node.PROCESS_MODE_DISABLED:
			break
	await frames(3)
	EventManager.win.disconnect(on_win)
	var screen: GameOverScreen = tree.root.find_children("GameOverScreen", "", true, false)[0]
	check(tree.root.process_mode == Node.PROCESS_MODE_DISABLED, "the game is paused")
	check(not won[0], "win was not emitted")
	check(screen.visible and screen.label.text.begins_with("Game over"), "lose screen shown")
	check(not screen.endless.visible, "endless is not offered after a loss")


func _set_fast_mode(on: bool):
	var button: CheckBoxButton = tree.current_scene.get_node("CanvasLayer/FastModeButton")
	if button.checked != on:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = true
		button._on_texture_rect_gui_input(click)


## Fast mode doubles enemy speed and tower attack rate.
func test_fast_mode_doubles_game_speed():
	await load_level()
	var results := {}
	for fast in [false, true]:
		_set_fast_mode(fast)
		var enemy := await spawn_enemy_at(tile_grid().cell_position(tile_grid().start_tile), 3000)
		# Distance along the path, summed per frame: the enemy may turn corners.
		var moved := 0.0
		var last := enemy.global_position
		for i in 60:
			await physics_frames()
			moved += enemy.global_position.distance_to(last)
			last = enemy.global_position
		enemy.queue_free()
		container_cleanup()
		var tower: Tower = load("res://entities/towers/surgeon_fish/surgeon_tower.tscn").instantiate()
		tree.current_scene.add_child(tower)
		await frames()
		tower.set_cd()
		var cooldown_frames := 0
		while tower.cd:
			await tree.process_frame
			cooldown_frames += 1
		tower.queue_free()
		results[fast] = [moved, cooldown_frames]
	check(absf(results[true][0] / results[false][0] - 2.0) < 0.1,
		"enemy moves twice as far in fast mode (%s vs %s)" % [results[true][0], results[false][0]])
	check(absf(float(results[false][1]) / results[true][1] - 2.0) < 0.15,
		"tower cooldown is half as long in fast mode (%d vs %d frames)" % [results[false][1], results[true][1]])
	_set_fast_mode(false)


func container_cleanup():
	enemy_container().alive_enemies.clear()
