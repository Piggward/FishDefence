extends TestCase
## Clickable panels act on a full click, like Godot Buttons: mouse-down alone, or a press
## dragged off before release, does nothing (so a drag from the shop can't fire them), and
## the keyboard can't re-trigger them after a click.


## Presses on `control`, then moves to `release_at` and releases there.
func _press_and_drag_off(control: Control, release_at: Vector2) -> void:
	var pos := screen_pos(control, control.size / 2)
	await mouse_glide(pos + Vector2(0, -30), pos, 3)
	mouse_button(pos, true)
	await frames(3)
	await mouse_glide(pos, release_at, 3)
	mouse_button(release_at, false)
	await frames(3)


func _press_key(keycode: Key) -> void:
	for pressed in [true, false]:
		var e := InputEventKey.new()
		e.keycode = keycode
		e.physical_keycode = keycode
		e.pressed = pressed
		tree.root.push_input(e)
		await frames(2)


func test_start_button_needs_a_full_click():
	await load_level(true)
	var level: Level = tree.current_scene
	var start := level.title_screen.start_button
	await _press_and_drag_off(start, Vector2(5, 5))
	check(not level.intro_player.is_playing(), "press dragged off the button does not start")
	await click(start)
	check(level.intro_player.is_playing(), "a full click starts the intro")


func test_wave_button_needs_a_full_click():
	await load_level()
	var button := next_wave_button()
	await _press_and_drag_off(button, Vector2(5, 5))
	check_eq(game_manager().current_wave, 0, "press dragged off does not start a wave")
	check(button.visible, "button still shown")
	check_eq(button.content.modulate, button.normal_color, "hover colour cleared after leaving")
	await press_next_wave()
	check_eq(game_manager().current_wave, 1, "a full click starts wave 1")


func test_checkbox_toggles_on_click_only():
	await load_level()
	var box: CheckBoxButton = tree.current_scene.fast_mode_button
	await click(box.button)
	check(box.checked, "checked after a click")
	check_eq(Engine.time_scale, GameManager.FAST_MODE_TIME_SCALE, "fast mode on")
	check_eq(box.texture_rect.texture, box.CHECK_SQUARE_GREY_CHECKMARK, "box shows the checkmark")
	for key in [KEY_SPACE, KEY_ENTER]:
		await _press_key(key)
		check(box.checked, "%s after a click doesn't toggle it again" % OS.get_keycode_string(key))
	await click(box.button)
	check(not box.checked, "unchecked after a second click")
	check_eq(Engine.time_scale, 1.0, "fast mode off")
	check_eq(box.texture_rect.texture, box.CHECK_SQUARE_GREY, "box shows the empty square")


## Each checkbox instance shows its own label and tooltip (the copies used to share one).
func test_checkboxes_show_their_own_text_and_tooltip():
	await load_level(true)
	var fast: CheckBoxButton = tree.current_scene.fast_mode_button
	var expert: CheckBoxButton = tree.current_scene.title_screen.expert_mode_button
	check_eq(fast.label.text, "Fast mode", "fast mode label")
	check(fast.label.tooltip_text.contains("double speed"), "fast mode tooltip: %s" % fast.label.tooltip_text)
	check_eq(expert.label.text, "Expert mode", "expert mode label")
	check(expert.label.tooltip_text.contains("expert"), "expert mode tooltip: %s" % expert.label.tooltip_text)
