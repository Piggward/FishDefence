extends TestCase
## The HUD reacts to gameplay only through EventManager signals; these check each link.


func _hud(path: String) -> Node:
	return tree.current_scene.get_node("HUD/" + path)


func test_money_and_health_labels_follow_the_game():
	await load_level()
	game_manager().set_eco_bucks(1234)
	game_manager().player_damage(7)
	await frames()
	check_eq(_hud("BucksContainer").bucks_label.text, "1234", "money label")
	check_eq(_hud("BucksContainer").heart_label.text, str(game_manager().START_HEALTH - 7), "health label")


func test_tooltip_shows_while_placing():
	await load_level()
	game_manager().eco_bucks = 100000
	var tooltip := _hud("ToolTip")
	placer().hover_tile = free_tiles()[0]
	placer()._spawn_ghost(load("res://entities/towers/crab/crab_tower.tscn"))
	check(tooltip.visible, "tooltip visible while placing")
	placer().end_placing()
	check(not tooltip.visible, "tooltip hidden after placing ends")


func test_wave_counter_and_damage_meter_follow_the_wave():
	await load_level()
	game_manager().eco_bucks = 100000
	game_manager().health = 100000
	var meter := _hud("DamageDealt")
	check(not meter.visible, "damage meter hidden before any damage")
	var tiles := placeable_tiles()
	for i in 4:
		await place_tower(load("res://entities/towers/surgeon_fish/surgeon_tower.tscn"), tiles[i * 13 % tiles.size()])
	await press_next_wave()
	await frames(5)
	check_eq(tree.current_scene.get_node("HUD/WaveDisplay").label.text, "Wave: 1", "wave counter")
	for f in 3000:
		await tree.process_frame
		if meter.visible:
			break
	check(meter.visible, "damage meter shown once a tower deals damage")
	check(meter.damage_row_container.get_child_count() > 0, "damage meter has a row for the tower")


func test_hovering_a_shop_item_shows_its_card():
	await load_level()
	var item: ShopItem = shop_items()[0]
	EventManager.shop_item_hovered.emit(item)
	await frames(5)
	check(tower_card().visible, "card shown")
	check_eq(tower_card().tower_name.text, item.stats.fish_name, "card title")
	EventManager.shop_item_unhovered.emit()
	await frames(3)
	check(not tower_card().visible, "card hidden")


func test_tutorial_starts_on_request():
	await load_level()
	var tutorial: TutorialContainer = _hud("TutorialContainer")
	EventManager.tutorial_requested.emit()
	await frames(5)
	check(tutorial.visible, "tutorial shown")
	check(tutorial.current_tutorial != null and tutorial.current_tutorial.preview.visible, "first step shows its demo")

