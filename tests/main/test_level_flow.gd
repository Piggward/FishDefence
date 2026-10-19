extends TestCase
## The level's flow: title screen → intro → tutorial (first run only) → playing.


func _hud() -> CanvasLayer:
	return tree.current_scene.get_node("HUD")


func _title() -> TitleScreen:
	return tree.current_scene.get_node("TitleScreen")


func _tutorial() -> TutorialContainer:
	return _hud().get_node("TutorialContainer")


func _play_state() -> Dictionary:
	var level: Level = tree.current_scene
	return {
		"camera": level.camera.position,
		"zoom": level.camera.zoom,
		"hud": _hud().visible,
		"wave_button": level.wave_button.visible,
		"title": _title().visible,
		"music": level.music.stream.resource_path.get_file(),
	}


## Clicks Start through the GUI and waits until the intro has handed over.
func _click_start_and_wait_for_intro() -> void:
	var button := _title().start_button
	var pos := screen_pos(button, button.size / 2)
	await mouse_glide(pos + Vector2(0, -40), pos, 3)
	mouse_button(pos, true)
	await frames(2)
	mouse_button(pos, false)
	for f in 20 * 60:
		await tree.process_frame
		if _hud().visible:
			break
	await frames(5)


func test_title_screen_shows_only_the_title_ui():
	await load_level(true)
	check(_title().visible, "title screen shown")
	check(not _hud().visible, "HUD hidden")
	check_eq(tree.current_scene.music.stream.resource_path.get_file(), "island_meet_and_greet.mp3", "title music")


func test_full_intro_ends_in_play_with_tutorial():
	await load_level(true)
	await _click_start_and_wait_for_intro()
	var state := _play_state()
	check(not state["title"], "title hidden")
	check(state["hud"] and state["wave_button"], "HUD and wave button shown")
	check_eq(state["camera"], Vector2(192, 112), "camera at the play position")
	check_eq(state["music"], "march_of_the_spoons.mp3", "main theme playing")
	check(_tutorial().visible, "tutorial shown on the first run")
	check_eq(tree.root.process_mode, Node.PROCESS_MODE_DISABLED, "gameplay paused during the tutorial")


## Skipping the intro (debug flag, or "Play again") must land in exactly the intro's end state.
func test_skipping_matches_the_intro_end():
	await load_level(true)
	await _click_start_and_wait_for_intro()
	var after_intro := _play_state()
	await cleanup()
	await load_level()
	check_eq(_play_state(), after_intro, "state after skipping")
	await cleanup()
	game_manager().intro_seen = false
	var level: Level = load(LEVEL).instantiate()
	level.debug_skip_intro = true
	tree.root.add_child(level)
	tree.current_scene = level
	await frames(10)
	check_eq(_play_state(), after_intro, "state with debug_skip_intro")
	check(game_manager().tutorial_done, "debug skip allows buying without the tutorial")


func test_tutorial_only_on_the_first_run():
	await load_level(true)
	await _click_start_and_wait_for_intro()
	check(_tutorial().visible, "tutorial on the first run")
	for i in _tutorial().steps.size():
		_tutorial().current_tutorial.next.emit()
		await frames(3)
	check_eq(tree.root.process_mode, Node.PROCESS_MODE_PAUSABLE, "game resumes after the tutorial")
	game_manager().restart()
	await frames(30)
	check(_hud().visible and not _title().visible, "play again starts in play")
	check(not _tutorial().visible, "no tutorial on play again")
	check_eq(tree.root.process_mode, Node.PROCESS_MODE_PAUSABLE, "not paused on play again")


## While paused (tutorial), enemies freeze but the tutorial itself keeps working.
func test_pause_freezes_gameplay_but_not_the_hud():
	await load_level()
	var enemy := await spawn_enemy_at(tile_grid().cell_position(tile_grid().start_tile), 3000)
	await physics_frames(5)
	EventManager.tutorial_requested.emit()
	await frames(3)
	var frozen_at := enemy.global_position
	await physics_frames(60)
	check_eq(enemy.global_position, frozen_at, "enemy frozen while paused")
	var first_title := _tutorial().current_tutorial.title
	_tutorial().current_tutorial.next.emit()
	await frames(3)
	check(_tutorial().current_tutorial.title != first_title, "tutorial still advances while paused")
